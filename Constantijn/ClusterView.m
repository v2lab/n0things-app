//
//  ClusterView.m
//  Constantijn
//
//  Created by Jan Misker on 22-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import "ClusterView.h"
#import "Shape.h"
#import "ShapeView.h"

@implementation ClusterView

@synthesize cluster;

- (id)init {
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"cluster" options:0 context:NULL];
    }
    return self;
}

- (id)initWithCluster:(Cluster *)_cluster {
    self = [self init];
    if (self) {
        self.cluster = _cluster;
        self.bounds = CGRectMake(0., 0., 60., 300.);
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    for (UIView *sub in self.subviews) {
        [sub removeFromSuperview];
    }
    int i = 0;
    for (Shape *shape in cluster.shapes) {
        ShapeView *shapeView = [[ShapeView alloc] initWithShape:shape];
        shapeView.center = CGPointMake(30, 300 - i++ * 50);
        [self addSubview:shapeView];
    }
    if (cluster.representative) {
        ShapeView *shapeView = [[ShapeView alloc] initWithShape:cluster.representative];
        shapeView.center = CGPointMake(30, 300);
        [self addSubview:shapeView];
    }
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
}

/*
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    for (Shape *shape in self.cluster.shapes) {
        //CGPathRef p = CGPathCreateMutable();
        
    }
}
*/

@end
