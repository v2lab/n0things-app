//
//  ImageProcessing.m
//  Constantijn
//
//  Created by Jan Misker on 13-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import "ImageProcessing.h"

@interface ImageProcessing ()

- (void)done;

@end


@implementation ImageProcessing

+ (void)detectContourForImage:(UIImage *)img selection:(CGRect)rect delegate:(id<ImageProcessingDelegate>)delegate {
    UIColor *color = [UIColor colorWithRed:1. green:0. blue:0. alpha:1.];
    NSArray *vertices = [NSArray array];
    
    [delegate finishedContourDetection:img shape:vertices color:color];
}

+ (NSArray *)calculate12DShapeForContour:(NSArray *)vertices color:(UIColor *)color weights:(NSArray *)weights {
    
    return [NSArray array];
}

+ (NSString *)findClosestClusterForShape:(NSArray *)shape12D clusterCentroids:(NSDictionary *)centroids {
    
    return @"";
}

@end
