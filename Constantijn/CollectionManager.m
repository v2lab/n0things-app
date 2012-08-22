//
//  CollectionManager.m
//  Constantijn
//
//  Created by Jan Misker on 13-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import "CollectionManager.h"
#include <xlocale.h>                                    // for strptime_l
#import "Constants.h"
#import "ImageProcessing.h"

@interface CollectionManager ()

@property (atomic, readwrite) NSArray *clusters;
@property (atomic, readwrite) NSArray *shapes;
@property (atomic, readwrite) NSArray *currentGenerationWeights;
@property (atomic, readwrite) NSString *currentGenerationTimestamp;

+ (NSString *)generateUUID;
- (Cluster *)classifyShape:(Shape *)shape inClusters:(NSArray *)clusters withWeights:(NSArray *)weights;
- (NSString *)simpleDBItem:(SimpleDBItem *)item attributeValue:(NSString *)attributeName;
- (Shape *)createShapeFromSimpleDBItem:(SimpleDBItem *)item;
- (void)mapSimpleDBItem:(SimpleDBItem *)item toObject:(NSObject *)object withMapping:(NSDictionary *)mapping;

@end

@implementation CollectionManager

static NSDictionary *shapeMapping;

@synthesize clusters, shapes, currentGenerationTimestamp, currentGenerationWeights, managedObjectContext;

- (void)submitShapeRecord:(ShapeRecord *)shapeRecord delegate:(id<CollectionManagerDelegate>)delegate {
#pragma mark ToDo put this in an NSOperation
    NSLog(@"submitShapeRecord for uuid %@", uuid);
    NSString *contourJSON = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:shapeRecord.vertices options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *huMomentsJSON = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:shapeRecord.huMoments options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *colorJSON = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:shapeRecord.color options:0 error:nil] encoding:NSUTF8StringEncoding];
    int red = [[shapeRecord.color objectAtIndex:0] intValue];
    int green = [[shapeRecord.color objectAtIndex:1] intValue];
    int blue = [[shapeRecord.color objectAtIndex:2] intValue];
    
    Shape *s = [NSEntityDescription insertNewObjectForEntityForName:@"Shape" inManagedObjectContext:self.managedObjectContext];
    s.id = [CollectionManager generateUUID];
    s.contour = shapeRecord.vertices;
    s.vertexCount = shapeRecord.vertices.count;
    s.color = [UIColor colorWithRed:red/255. green:green/255. blue:blue/255. alpha:1.];
    s.huMoments = shapeRecord.huMoments;
    s.defectsCount = shapeRecord.defectsCount;
    s.collectionId = uuid;
    [shapes addObject:s];

    [self classifyShape:s inClusters:self.clusters withWeights:self.currentGenerationWeights];
    NSError *err;
    [self.managedObjectContext save:&err];

    NSMutableArray *attributes = [NSMutableArray array];
    [attributes addObject:[[SimpleDBReplaceableAttribute alloc] initWithName:@"CollectionId" andValue:uuid andReplace:YES]];
    [attributes addObject:[[SimpleDBReplaceableAttribute alloc] initWithName:@"Contour" andValue:contourJSON andReplace:YES]];
    [attributes addObject:[[SimpleDBReplaceableAttribute alloc] initWithName:@"VertexCount" andValue:[[NSNumber numberWithInt:s.vertexCount] stringValue] andReplace:YES]];
    [attributes addObject:[[SimpleDBReplaceableAttribute alloc] initWithName:@"Color" andValue:colorJSON andReplace:YES]];
    [attributes addObject:[[SimpleDBReplaceableAttribute alloc] initWithName:@"HuMoments" andValue:huMomentsJSON andReplace:YES]];
    [attributes addObject:[[SimpleDBReplaceableAttribute alloc] initWithName:@"VertexCount" andValue:[[NSNumber numberWithInt:s.defectsCount] stringValue] andReplace:YES]];
    SimpleDBPutAttributesRequest *req = [[SimpleDBPutAttributesRequest alloc] initWithDomainName:@"Shape" andItemName:s.id andAttributes:attributes];
    @try {
        [simpleDBClient putAttributes:req];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception putting aws items %@", [exception description]);
    }
    [delegate shapeSubmitSuccesObjectId:s.id];
}

- (void)checkForNewGeneration {
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        @try {
            NSString *selectExpr = [NSString stringWithFormat:@"SELECT * FROM `Generation` WHERE Timestamp >= '%@' ORDER BY Timestamp DESC LIMIT 1", self.currentGenerationTimestamp];
            SimpleDBSelectRequest *req = [[SimpleDBSelectRequest alloc] initWithSelectExpression:selectExpr];
            SimpleDBSelectResponse *resp = [simpleDBClient select:req];
            NSLog(@"req: %@ \nresponse: %@", req, resp);
            if (resp.items.count) {
                SimpleDBItem *newGenerationItem = [resp itemsObjectAtIndex:0];
                NSString *timestamp = nil;
                NSArray *weights = nil;
                for (SimpleDBAttribute *attr in newGenerationItem.attributes) {
                    if ([attr.name isEqualToString:@"Timestamp"]) {
                        timestamp = attr.value;
                    }
                    if ([attr.name isEqualToString:@"Weights"]) {
                        NSError *err;
                        weights = [NSJSONSerialization JSONObjectWithData:[attr.value dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err];
                    }
                }
                if (timestamp && timestamp.length && weights && [weights isKindOfClass:[NSArray class]] && weights.count == 12) {
                    selectExpr = [NSString stringWithFormat:@"SELECT * FROM Cluster WHERE Generation = '%@'", timestamp];
                    req = [[SimpleDBSelectRequest alloc] initWithSelectExpression:selectExpr];
                    SimpleDBSelectResponse *clusterResponse = [simpleDBClient select:req];
                    //load all the representatives
                    NSMutableArray *representativeIDs = [NSMutableArray arrayWithCapacity:clusterResponse.items.count];
                    for (SimpleDBItem *clusterItem in clusterResponse.items) {
                        NSString *reprId = [self simpleDBItem:clusterItem attributeValue:@"Representative"];
                        if (reprId)
                            [representativeIDs addObject:[NSString stringWithFormat:@"'%@'", reprId]];
                    }
                    NSMutableDictionary *representativeShapes = [NSMutableDictionary dictionaryWithCapacity:representativeIDs.count];
                    if (representativeIDs.count) {
                        req = [[SimpleDBSelectRequest alloc] initWithSelectExpression:[NSString stringWithFormat:@"SELECT * FROM Shape WHERE itemName() IN (%@)", [representativeIDs componentsJoinedByString:@","]]];
                        SimpleDBSelectResponse *representativeResponse = [simpleDBClient select:req];
                        for (SimpleDBItem *reprItem in representativeResponse.items) {
                            //create Shape
                            Shape *s = [self createShapeFromSimpleDBItem:reprItem];
                            [representativeShapes setObject:s forKey:s.id];
                        }
                    }
                    //store all the clusters in db
                    NSMutableArray *newClusters = [NSMutableArray arrayWithCapacity:clusterResponse.items.count];
                    for (SimpleDBItem *clusterItem in clusterResponse.items) {
                        Cluster *cluster = [NSEntityDescription insertNewObjectForEntityForName:@"Cluster" inManagedObjectContext:self.managedObjectContext];
                        cluster.id = clusterItem.name;
                        for (SimpleDBAttribute *attr in clusterItem.attributes) {
                            if ([attr.name isEqualToString:@"Representative"]) {
                                cluster.representative = [representativeShapes objectForKey:attr.value];
                            } 
                        }
                        [newClusters addObject:cluster];
                    }
                    self.clusters = [NSArray arrayWithArray:newClusters];

                    //re-classify
                    for (Shape *shape in self.shapes) {
                        [self classifyShape:shape inClusters:clusters withWeights:weights];
                    }
                    
                    NSLog(@"found this data %@ %@", timestamp, [[weights objectAtIndex:1] class]);
                    self.currentGenerationWeights = weights;
                    self.currentGenerationTimestamp = timestamp;
                    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
                    [defs setObject:currentGenerationTimestamp forKey:@"currentGenerationTimestamp"];
                    [defs setObject:currentGenerationWeights forKey:@"currentGenerationWeights"];
                    [defs synchronize];
                    NSError *err;
                    [self.managedObjectContext save:&err];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception calling Amazon %@", [exception description]);
        }
    }];
    [queue addOperation:op];
}

- (Cluster *)classifyShape:(Shape *)shape inClusters:(NSArray *)_clusters withWeights:(NSArray *)weights {
    double closestDistance = DBL_MAX;
    Cluster *closestCluster = nil;
    NSArray *shape12D = [ImageProcessing mapShapeRecord:shape.shapeRecord withWeights:weights];
    for (Cluster *cluster in _clusters) {
        double distance = [ImageProcessing distanceBetweenPointA:shape12D andPointB:cluster.centroid];
        if (!closestCluster || (distance < closestDistance)) {
            closestCluster = cluster;
            closestDistance = distance;
        }
    }
    shape.cluster = closestCluster;
    return shape.cluster;
}

- (NSString *)simpleDBItem:(SimpleDBItem *)item attributeValue:(NSString *)attributeName {
    int idx = [item.attributes indexOfObjectPassingTest:^BOOL(SimpleDBAttribute *obj, NSUInteger idx, BOOL *stop) {
        return [obj.name isEqualToString:attributeName];
    }];
    if (idx == NSNotFound)
        return nil;
    SimpleDBAttribute *attr = [item.attributes objectAtIndex:idx];
    return attr.value;
}

- (Shape *)createShapeFromSimpleDBItem:(SimpleDBItem *)item {
#pragma mark ToDo check whether shape already exists
    Shape *shape = [NSEntityDescription insertNewObjectForEntityForName:@"Shape" inManagedObjectContext:self.managedObjectContext];
    shape.id = item.name;
    [self mapSimpleDBItem:item toObject:shape withMapping:shapeMapping];
    for (SimpleDBAttribute *attr in item.attributes) {
        if ([attr.name isEqualToString:@"VertexCount"]) {
            shape.vertexCount = [attr.value intValue];
        } else if ([attr.name isEqualToString:@"DefectsCount"]) {
            shape.defectsCount = [attr.value intValue];
        }
    }
    return shape;
}

- (void)mapSimpleDBItem:(SimpleDBItem *)item toObject:(NSObject *)object withMapping:(NSDictionary *)mapping {
    for (SimpleDBAttribute *attr in item.attributes) {
        NSString *key = [mapping objectForKey:attr.name];
        if (key) {
            [object setValue:attr.value forKey:key];
        }
    }
}

+ (NSString *)generateUUID {
    CFUUIDRef _uuid = CFUUIDCreate(NULL);
    NSString *result = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, _uuid);
    return result;
}

- (void)loadShapesAndClusters {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Cluster" inManagedObjectContext:self.managedObjectContext];
    req.predicate = [NSPredicate predicateWithFormat:@"generation = %@", self.currentGenerationTimestamp];
    NSError *err;
    self.clusters = [self.managedObjectContext executeFetchRequest:req error:&err];
    req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Shape" inManagedObjectContext:self.managedObjectContext];
    req.predicate = [NSPredicate predicateWithFormat:@"collectionId = %@", uuid];
    self.shapes = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:req error:&err]];
    [self checkForNewGeneration];
}

- (id)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        uuid = [defs stringForKey:@"uuid"];
        if (!uuid.length) {
            uuid = [CollectionManager generateUUID];
            [defs setObject:uuid forKey:@"uuid"];
            [defs synchronize];
        }
        self.currentGenerationTimestamp = [defs stringForKey:@"currentGenerationTimestamp"];
        self.currentGenerationWeights = [defs arrayForKey:@"currentGenerationWeights"];
        shapeMapping = [NSDictionary dictionaryWithObjectsAndKeys:@"contour", @"Contour", nil];
        simpleDBClient = [[AmazonSimpleDBClient alloc] initWithAccessKey:AWS_KEY withSecretKey:AWS_SECRET];
        queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

+ (CollectionManager *)sharedInstance {
    static dispatch_once_t pred;
    static CollectionManager *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[CollectionManager alloc] init];
    });
    return shared;
}

@end
