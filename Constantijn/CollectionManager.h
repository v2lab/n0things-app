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
#import "ShapeObject.h"
#import "Cluster.h"
#import <AWSiOSSDK/SimpleDB/AmazonSimpleDBClient.h>

@protocol CollectionManagerDelegate <NSObject>

- (void)collectionLoadSucces;
- (void)shapeSubmitSuccesObjectId:(NSString *)objectId;
- (void)connectionFailure:(NSError *)error;

@end

@interface CollectionManager : NSObject {
    NSArray *classes;
    NSDictionary *objects;
    NSManagedObjectContext *managedObjectContext;
    NSArray *currentGenerationWeights;
    NSDate *currentGenerationTimestamp;
    AmazonSimpleDBClient *simpleDBClient;
    NSOperationQueue *queue;
}

@property (nonatomic, readonly) NSArray *classes;
@property (nonatomic, readonly) NSDictionary *objects;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSArray *currentGenerationWeights;
@property (nonatomic, readonly) NSDate *currentGenerationTimestamp;

- (id)init;
- (void)loadRemoteCollection;
- (void)submitShape:(NSArray *)vertices color:(UIColor *)color shape12D:(NSArray *)array;
- (void)checkForNewGeneration;

// singleton
+ (CollectionManager *)sharedInstance;

@end
