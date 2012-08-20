//
//  ImageProcessingOperation.h
//  Constantijn
//
//  Created by Jan Misker on 20-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageProcessing.h"

@interface ImageProcessingOperation : NSOperation <ImageProcessingDelegate> {
    UIImage *_image;
    CGRect _selection;
    NSArray *_vertices;
    UIColor *_color;
}

@property (copy, readonly) UIImage *image;
@property (assign, readonly) CGRect selection;
@property (copy, readonly) NSArray *vertices;
@property (strong, readonly) UIColor *color;

- (id)initWithImage:(UIImage *)image selection:(CGRect)rect;
- (void)main;

@end
