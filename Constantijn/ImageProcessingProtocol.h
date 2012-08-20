//
//  ImageProcessingProtocol.h
//  Constantijn
//
//  Created by Jan Misker on 13-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageProcessingDelegate <NSObject>

/**
 * called when the contour is found, can be called on the same thread
 */
- (void)finishedContourDetection:(UIImage *)originalImage shape:(NSArray *)vertices color:(UIColor *)color;

@end

@protocol ImageProcessingProtocol <NSObject>

/**
 * detect the contour, this takes some time so will be called on a separate thread
 * the delegate should be called on the main thread
 */
+ (void)detectContourForImage:(UIImage *)img selection:(CGRect)rect delegate:(id<ImageProcessingDelegate>)delegate;

/**
 * returns the 12D array of doubles (NSNumber *) that represent the provided vertices and color
 */
+ (NSArray *)calculate12DShapeForContour:(NSArray *)vertices color:(UIColor *)color weights:(NSArray *)weights;

/**
 * shape12D is an array of doubles (NSNumber *)
 * centroids is a dictionary with clusterIDs (NSString *) as key and centroid as value, centroids represented as 12D array of doubles (NSNumber *)
 * returns the clusterID (key) of the appropriate cluster
 */
+ (NSString *)findClosestClusterForShape:(NSArray *)shape12D clusterCentroids:(NSDictionary *)centroids;

@end

