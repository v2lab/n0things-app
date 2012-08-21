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

+ (NSString *)generateUUID;
- (Cluster *)classifyShape:(Shape *)shape inClusters:(NSArray *)clusters;
- (NSString *)simpleDBItem:(SimpleDBItem *)item attributeValue:(NSString *)attributeName;
- (Shape *)createShapeFromSimpleDBItem:(SimpleDBItem *)item;
- (void)mapSimpleDBItem:(SimpleDBItem *)item toObject:(NSObject *)object withMapping:(NSDictionary *)mapping;

@end

@implementation CollectionManager

static NSDictionary *shapeMapping;

@synthesize classes, objects;

- (void)loadRemoteCollection {
    NSLog(@"loadRemoteCollection for uuid %@", uuid);
}

- (void)submitShapeRecord:(ShapeRecord *)shapeRecord delegate:(id<CollectionManagerDelegate>)delegate {
    //ToDo put in Operation
    
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
            NSString *selectExpr = [NSString stringWithFormat:@"SELECT * FROM `Generation` WHERE Timestamp > '%@' ORDER BY Timestamp DESC LIMIT 1", currentGenerationTimestamp];
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
                    for (SimpleDBItem *clusterItem in clusterResponse.items) {
                        Cluster *cluster = [NSEntityDescription insertNewObjectForEntityForName:@"Cluster" inManagedObjectContext:self.managedObjectContext];
                        //cluster.id =
                        for (SimpleDBAttribute *attr in clusterItem.attributes) {
                            if ([attr.name isEqualToString:@"Representative"]) {
                                cluster.representative = [representativeShapes objectForKey:attr.value];
                            }
                        }
                    }
                    //re-classify
                    
                    
                    NSLog(@"found this data %@ %@", timestamp, [[weights objectAtIndex:1] class]);
                    currentGenerationWeights = weights;
                    currentGenerationTimestamp = timestamp;
                    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
                    [defs setObject:currentGenerationTimestamp forKey:@"currentGenerationTimestamp"];
                    [defs setObject:currentGenerationWeights forKey:@"currentGenerationWeights"];
                    [defs synchronize];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception calling Amazon %@", [exception description]);
        }
    }];
    [queue addOperation:op];
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
    Shape *shape = [NSEntityDescription insertNewObjectForEntityForName:@"Shape" inManagedObjectContext:self.managedObjectContext];
    shape.id = item.name;
    [self mapSimpleDBItem:item toObject:shape withMapping:shapeMapping];
    for (SimpleDBAttribute *attr in item.attributes) {
        if ([attr.name isEqualToString:@"VertexCount"]) {
            shape.vertexCount = [attr.value intValue];
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
        currentGenerationTimestamp = [defs stringForKey:@"currentGenerationTimestamp"];
        currentGenerationWeights = [defs arrayForKey:@"currentGenerationWeights"];
        shapeMapping = [NSDictionary dictionaryWithObjectsAndKeys:@"contour", @"Contour", nil];
        classes = [NSArray array];
        objects = [NSDictionary dictionary];
        simpleDBClient = [[AmazonSimpleDBClient alloc] initWithAccessKey:AWS_KEY withSecretKey:AWS_SECRET];
        queue = [[NSOperationQueue alloc] init];
        [self checkForNewGeneration];
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
