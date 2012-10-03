//
//  Shape.h
//  Constantijn
//
//  Created by Jan Misker on 02-10-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Cluster;

@interface Shape : NSManagedObject

@property (nonatomic, retain) NSString * collectionId;
@property (nonatomic, retain) id color;
@property (nonatomic, retain) id contour;
@property (nonatomic) int16_t defectsCount;
@property (nonatomic, retain) id huMoments;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) id shapeRecord;
@property (nonatomic) NSTimeInterval submittedDate;
@property (nonatomic) int16_t vertexCount;
@property (nonatomic) double distanceToCentroid;
@property (nonatomic, retain) Cluster *cluster;
@property (nonatomic, retain) Cluster *representativeForCluster;

@end
