//
//  ImageProcessingOperation.m
//  Constantijn
//
//  Created by Jan Misker on 20-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import "ImageProcessingOperation.h"

@interface ImageProcessingOperation ()
@property (copy, readwrite) NSArray *vertices;
@property (strong, readwrite) UIColor *color;
@end

@implementation ImageProcessingOperation

@synthesize image = _image;
@synthesize selection = _selection;
@synthesize vertices = _vertices;
@synthesize color = _color;

- (id)initWithImage:(UIImage *)image selection:(CGRect)rect {
    self = [super init];
    if (self) {
        self->_image = [image copy];
        self->_selection = rect;
    }
    return self;
}

- (void)finishedContourDetection:(UIImage *)originalImage shape:(NSArray *)vertices color:(UIColor *)color {
    self.vertices = vertices;
    self.color = color;
}

- (void)main {
    [ImageProcessing detectContourForImage:self.image selection:self.selection delegate:self];
}

@end
