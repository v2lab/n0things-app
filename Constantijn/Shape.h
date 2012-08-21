//
//  Shape.h
//  Constantijn
//
//  Created by Jan Misker on 21-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ShapeRecord.h"

@class Cluster;

@interface Shape : NSManagedObject

@property (nonatomic, retain) NSString * collectionId;
@property (nonatomic, retain) UIColor * color;
@property (nonatomic) int16_t defectsCount;
@property (nonatomic, retain) NSArray * huMoments;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSArray * contour;
@property (nonatomic) int16_t vertexCount;
@property (nonatomic, retain) ShapeRecord * shapeRecord;
@property (nonatomic, retain) Cluster *cluster;

@end
