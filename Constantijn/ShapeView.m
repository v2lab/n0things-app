    //
    //  ShapeView.m
    //  Constantijn
    //
    //  Created by Jan Misker on 23-08-12.
    //  Copyright (c) 2012 V2_. All rights reserved.
    //

#import "ShapeView.h"
#import <QuartzCore/QuartzCore.h>
#import "Cluster.h"

@interface ShapeView ()

- (CGPoint)pointForArray:(NSArray *)arr;

@end

@implementation ShapeView

@synthesize shape, path, representsCluster;

- (CGPoint)pointForArray:(NSArray *)arr {
    int x = [(NSNumber *)[arr objectAtIndex:0] floatValue];
    int y = [(NSNumber *)[arr objectAtIndex:1] floatValue];
    return CGPointMake(x, y);
}

- (void)doubleTapped {
    if (!self.representsCluster) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShapeDoubleTapped" object:self];
    }
}

- (id)initWithShape:(Shape *)_shape
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.bounds = CGRectMake(0, 0, 40, 40);
        [self addObserver:self forKeyPath:@"shape" options:0 context:NULL];
        self.shape = _shape;
        self.clipsToBounds = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped)];
        tap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    path = [UIBezierPath bezierPath];
    CGPoint origin = [self pointForArray:[shape.contour objectAtIndex:0]];
    [path moveToPoint:origin];
    for (int i = 1; i < [shape.contour count]; ++i) {
        CGPoint p = [self pointForArray:[shape.contour objectAtIndex:i]];
        [path addLineToPoint:p];
    }
    [path closePath];
    path.lineWidth = 1.;
}


- (void)drawRect:(CGRect)rect
{
    CGFloat scaleX = self.bounds.size.height / path.bounds.size.height;
    CGFloat scaleY = self.bounds.size.width / path.bounds.size.width;
    CGFloat scaleFactor = MIN(scaleX, scaleY) * 0.95;
    CGAffineTransform scale = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    [path applyTransform:scale];
    if (self.representsCluster && (scaleY < scaleX)) {
        [path applyTransform:CGAffineTransformMakeRotation(M_PI_2)];
        CGAffineTransform translate = CGAffineTransformMakeTranslation(-path.bounds.origin.x + (self.bounds.size.width - path.bounds.size.width)/2., -path.bounds.origin.y + (self.bounds.size.height - path.bounds.size.height)/2.);
        [path applyTransform:translate];
    } else {
        CGAffineTransform translate = CGAffineTransformMakeTranslation(-path.bounds.origin.x + (self.bounds.size.width - path.bounds.size.width)/2., -path.bounds.origin.y + (self.bounds.size.height - path.bounds.size.height)/2.);
        [path applyTransform:translate];
    }
    if (self.representsCluster) {
        NSNumber *num = [self.shape.representativeForCluster.shapes valueForKeyPath:@"@min.distanceToCentroid"];
            //NSLog(@"minimal distances %@ sigma %f", num, self.shape.representativeForCluster.sigma);
        double closestDistance = [num doubleValue];
        double visibleRatio = 0.;
        if (closestDistance > 0) {
            double sigma = self.shape.representativeForCluster.sigma;
            visibleRatio = MAX(0, MIN(1, 1 - ((closestDistance - 0.1 * sigma) / (2 * sigma))));
        }
            //NSLog(@"  => ratio %f", visibleRatio);
        [[UIColor colorWithWhite:.8 alpha:1.] setFill];
        [[UIColor colorWithWhite:0. alpha:.2] setStroke];
            //[path fill];
        CGFloat dashPatern[2] = {2.0, 2.0};
        [path setLineDash:dashPatern count:2 phase:0.0];
        [path stroke];
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextClipToRect(ctx, CGRectMake(0, self.bounds.size.height * (1 - visibleRatio), self.bounds.size.width, self.bounds.size.height));
        [shape.color setFill];
        [[UIColor blackColor] setStroke];
        [path setLineDash:NULL count:0 phase:0];
        [path fill];
        [path stroke];
    } else {
        [shape.color setFill];
        [[UIColor blackColor] setStroke];
        [path fill];
        [path stroke];
    }
}

- (void)dealloc {
    self.shape = nil;
    path = nil;
    [self removeObserver:self forKeyPath:@"shape"];
}


@end
