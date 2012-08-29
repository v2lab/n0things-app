//
//  CollectionManager.h
//  Constantijn
//
//  Created by Jan Misker on 13-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>
//#import <UIKit/UIBezierPath.h>
#import "Shape.h"
#import "Cluster.h"
#import <AWSiOSSDK/SimpleDB/AmazonSimpleDBClient.h>
#import "ShapeRecord.h"
#import "ISO8601DateFormatter.h"

@protocol CollectionManagerDelegate <NSObject>

@optional
- (void)collectionLoadSucces;
- (void)shapeSubmitSuccesObjectId:(Shape *)shape;
- (void)connectionFailure:(NSError *)error;

@end

@interface CollectionManager : NSObject {
    NSArray *clusters;
    NSMutableArray *shapes;
    NSManagedObjectContext *managedObjectContext;
    NSArray *currentGenerationWeights;
    NSString *currentGenerationTimestamp;
    NSString *uuid;
    AmazonSimpleDBClient *simpleDBClient;
    NSOperationQueue *queue;
    NSDateFormatter *dateFormatter;
}

@property (atomic, readonly) NSArray *clusters;
@property (atomic, readonly) NSArray *shapes;
@property (atomic, strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, readonly) NSArray *currentGenerationWeights;
@property (atomic, readonly) NSString *currentGenerationTimestamp;

- (id)init;
- (void)loadShapesAndClusters;
- (void)submitShapeRecord:(ShapeRecord *)shapeRecord delegate:(id<CollectionManagerDelegate>)delegate;
- (void)checkForNewGeneration;

// singleton
+ (CollectionManager *)sharedInstance;

@end
