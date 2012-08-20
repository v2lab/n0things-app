//
//  ImageProcessingOperation.h
//  Constantijn
//
//  Created by Jan Misker on 20-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageProcessing.h"

@interface ImageProcessingOperation : NSOperation {
    UIImage *_image;
    CGRect _selection;
    ShapeRecord *_shapeRecord;
}

@property (copy, readonly) UIImage *image;
@property (assign, readonly) CGRect selection;
@property (copy, readonly) ShapeRecord *shapeRecord;

- (id)initWithImage:(UIImage *)image selection:(CGRect)rect;
- (void)main;

@end
