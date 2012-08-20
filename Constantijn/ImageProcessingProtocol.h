//
//  ImageProcessingProtocol.h
//  Constantijn
//
//  Created by Jan Misker on 13-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShapeRecord.h"

@protocol ImageProcessingProtocol <NSObject>

/**
 * detect the contour, this takes some time so will be called on a separate thread
 * the delegate should be called on the main thread
 */
+ (ShapeRecord *)detectContourForImage:(UIImage *)img selection:(CGRect)rect;

/**
 * returns the 12D array of doubles (NSNumber *) that represent the provided vertices and color
 */
+ (NSArray *)mapShapeRecord:(ShapeRecord *)shape withWeights:(NSArray *)weights;

+ (double)distanceBetweenPointA:(NSArray *)a andPointB:(NSArray *)b;

@end

