//
//  Shape.h
//  Constantijn
//
//  Created by Jan Misker on 20-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Cluster;

@interface Shape : NSManagedObject

@property (nonatomic, retain) NSString * collectionId;
@property (nonatomic, retain) NSString * color;
@property (nonatomic) int16_t defectsCount;
@property (nonatomic, retain) NSString * huMoments;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * contour;
@property (nonatomic) int16_t vertexCount;
@property (nonatomic, retain) id shapeRecord;
@property (nonatomic, retain) Cluster *cluster;

@end
