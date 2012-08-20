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

+ (ShapeRecord *)detectContourForImage:(UIImage *)img selection:(CGRect)rect {
    UIColor *color = [UIColor colorWithRed:1. green:0. blue:0. alpha:1.];
    NSArray *vertices = [NSArray array];
    
    ShapeRecord *result = [[ShapeRecord alloc] init];
    result.vertices = vertices;
    result.color = color;
    return result;
}

+ (NSArray *)mapShapeRecord:(ShapeRecord *)shape withWeights:(NSArray *)weights {
    
    return [NSArray array];
}


@end
