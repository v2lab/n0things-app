//
//  ImageProcessingOperation.m
//  Constantijn
//
//  Created by Jan Misker on 20-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import "ImageProcessingOperation.h"

@interface ImageProcessingOperation ()
@property (copy, readwrite) ShapeRecord *shapeRecord;
@end

@implementation ImageProcessingOperation

@synthesize image = _image;
@synthesize selection = _selection;
@synthesize shapeRecord = _shapeRecord;

- (id)initWithImage:(UIImage *)image selection:(CGRect)rect {
    self = [super init];
    if (self) {
        self->_image = [image copy];
        self->_selection = rect;
    }
    return self;
}

- (void)main {
    self.shapeRecord = [ImageProcessing detectContourForImage:self.image selection:self.selection];
}

@end
