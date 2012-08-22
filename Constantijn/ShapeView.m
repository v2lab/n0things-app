//
//  ShapeView.m
//  Constantijn
//
//  Created by Jan Misker on 23-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import "ShapeView.h"

@interface ShapeView ()

- (CGPoint)pointForArray:(NSArray *)arr;

@end

@implementation ShapeView

@synthesize shape;

- (CGPoint)pointForArray:(NSArray *)arr {
    int x = [(NSNumber *)[arr objectAtIndex:0] floatValue];
    int y = [(NSNumber *)[arr objectAtIndex:1] floatValue];
    return CGPointMake(x, y);
}

- (id)initWithShape:(Shape *)_shape
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.bounds = CGRectMake(0, 0, 40, 40);
        [self addObserver:self forKeyPath:@"shape" options:0 context:NULL];
        self.shape = _shape;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    path = [UIBezierPath bezierPath];
    CGPoint origin = [self pointForArray:[shape.contour objectAtIndex:0]];
    [path moveToPoint:origin];
    for (int i = 1; i < shape.contour.count; ++i) {
        CGPoint p = [self pointForArray:[shape.contour objectAtIndex:i]];
        [path addLineToPoint:p];
    }
    [path closePath];
    path.lineWidth = 1.;
}


- (void)drawRect:(CGRect)rect
{
    CGRect pathBounds = path.bounds;
    CGAffineTransform translate = CGAffineTransformMakeTranslation(-pathBounds.origin.x, -pathBounds.origin.y);
    [path applyTransform:translate];
    CGFloat scaleX = self.bounds.size.height / pathBounds.size.height;
    CGFloat scaleY = self.bounds.size.width / pathBounds.size.width;
    CGFloat scaleFactor = MIN(scaleX, scaleY);
    CGAffineTransform scale = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    [path applyTransform:scale];
    
    [shape.color setFill];
    [[UIColor blackColor] setStroke];
    [path fill];
    [path stroke];
}


@end
