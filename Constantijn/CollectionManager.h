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

@protocol CollectionManagerDelegate <NSObject>

@optional
- (void)collectionLoadSucces;
- (void)shapeSubmitSuccesObjectId:(NSString *)objectId;
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
