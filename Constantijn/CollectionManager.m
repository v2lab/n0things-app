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

- (Cluster *)classifyShape:(Shape *)shape inClusters:(NSArray *)clusters;
- (NSString *)simpleDBItem:(SimpleDBItem *)item attributeValue:(NSString *)attributeName;
- (Shape *)createShapeFromSimpleDBItem:(SimpleDBItem *)item;

@end

@implementation CollectionManager

@synthesize classes, objects;

- (void)loadRemoteCollection {
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uuid"];
    NSLog(@"loadRemoteCollection for uuid %@", uuid);
}

- (void)submitShapeRecord:(ShapeRecord *)shapeRecord {
    
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uuid"];
    NSLog(@"submitShapeRecord for uuid %@", uuid);
    Shape *s = [NSEntityDescription insertNewObjectForEntityForName:@"Shape" inManagedObjectContext:self.managedObjectContext];
    s.vertexCount = shapeRecord.vertices.count;
    s.defectsCount = shapeRecord.defectsCount;
    NSMutableArray *attributes = [NSMutableArray array];
    [attributes addObject:[[SimpleDBAttribute alloc] initWithName:@"CollectionId" andValue:uuid]];
    [attributes addObject:[[SimpleDBAttribute alloc] initWithName:@"VertexCount" andValue:[[NSNumber numberWithInt:s.vertexCount] stringValue]]];
    SimpleDBPutAttributesRequest *req = [[SimpleDBPutAttributesRequest alloc] initWithDomainName:@"Shape" andItemName:s.id andAttributes:attributes];
    [simpleDBClient putAttributes:req];
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
                    req = [[SimpleDBSelectRequest alloc] initWithSelectExpression:[NSString stringWithFormat:@"SELECT * FROM Shape WHERE itemName() IN (%@)", [representativeIDs componentsJoinedByString:@","]]];
                    SimpleDBSelectResponse *representativeResponse = [simpleDBClient select:req];
                    NSMutableDictionary *representativeShapes = [NSMutableDictionary dictionaryWithCapacity:representativeResponse.items.count];
                    for (SimpleDBItem *reprItem in representativeResponse.items) {
                        //create Shape
                        Shape *s = [self createShapeFromSimpleDBItem:reprItem];
                        [representativeShapes setObject:s forKey:s.id];
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
    for (SimpleDBAttribute *attr in item.attributes) {
        if ([attr.name isEqualToString:@"Contour"]) {
            shape.contour = attr.value;
        } else if ([attr.name isEqualToString:@"VertexCount"]) {
            shape.vertexCount = [attr.value intValue];
        }
    }
    return shape;
}

- (id)init {
    self = [super init];
    if (self) {
        classes = [NSArray array];
        objects = [NSDictionary dictionary];
        simpleDBClient = [[AmazonSimpleDBClient alloc] initWithAccessKey:AWS_KEY withSecretKey:AWS_SECRET];
        queue = [[NSOperationQueue alloc] init];
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        currentGenerationTimestamp = [defs stringForKey:@"currentGenerationTimestamp"];
        currentGenerationWeights = [defs arrayForKey:@"currentGenerationWeights"];
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
