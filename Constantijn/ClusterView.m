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
#import <QuartzCore/QuartzCore.h>

@implementation ClusterView

@synthesize cluster, latestShape;

- (void)flashScrollIndicators {
    [scrollView flashScrollIndicators];
}

- (id)init {
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"cluster" options:0 context:NULL];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(80., size.height);
}

- (id)initWithCluster:(Cluster *)_cluster {
    self = [self init];
    if (self) {
        //self.bounds = CGRectMake(0., 0., 60., 300.);
        scrollView = [[UIScrollView alloc] init];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        scrollView.frame = CGRectMake(0, 0, 80, self.bounds.size.height);
        scrollView.contentInset = UIEdgeInsetsMake(0., 10., 0., 10.);
        scrollView.showsHorizontalScrollIndicator = YES;
        [self addSubview:scrollView];
        containerView = [[UIView alloc] init];
        [scrollView addSubview:containerView];
        self.cluster = _cluster;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    for (UIView *sub in [containerView.subviews copy]) {
        [sub removeFromSuperview];
    }
    int cnt = cluster.shapes.count;
    CGFloat height = MAX((cnt) * 50. + 55., scrollView.bounds.size.height);
    scrollView.contentSize = CGSizeMake(60., height);
    containerView.frame = CGRectMake(0, 0, 60, height);
    CGFloat yOffset = height - 33.;
    for (Shape *shape in cluster.shapes) {
        ShapeView *shapeView = [[ShapeView alloc] initWithShape:shape];
        shapeView.center = CGPointMake(30, yOffset);
        yOffset -= 50;
        if (shape == latestShape) {
            //shapeView.backgroundColor = [UIColor redColor];
            UIImageView *plus1View = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feedback-+1"]];
            plus1View.frame = CGRectMake(0, yOffset - 30, 60, 60);
            plus1View.contentMode = UIViewContentModeCenter;
            plus1View.alpha = 0.;
            [containerView addSubview:plus1View];
            /*
            [UIView animateWithDuration:1. delay:0. options:UIViewAnimationOptionAutoreverse animations:^{
                shapeView.path
            } completion:^(BOOL finished) {
                
            }];
             */
            shapeView.layer.shadowColor = [UIColor yellowColor].CGColor;
            shapeView.layer.shadowRadius = 8.;
            shapeView.layer.shadowOpacity = .8;
            shapeView.layer.shadowOffset = CGSizeMake(0., 0.);
            shapeView.transform = CGAffineTransformMakeScale(.1, .1);
            shapeView.alpha = 0.;
            [UIView animateWithDuration:.5 delay:.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                shapeView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                shapeView.alpha = 1.;
            } completion:^(BOOL finished) {
                plus1View.alpha = 1.;
                [UIView animateWithDuration:.2 animations:^{
                    shapeView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                }];
            }];
            yOffset -= 50;
        }
        [containerView addSubview:shapeView];
    }
     /*
    int cnt = random() % 10;
    self.backgroundColor = [UIColor colorWithRed:cnt/15. green:0. blue:0. alpha:1.];
    CGFloat height = MAX(cnt * 50., scrollView.bounds.size.height - 20.);
    scrollView.contentSize = CGSizeMake(60., height);
    CGFloat yOffset = height - 50;
    for (int i = 0; i < cnt; ++i) {
        UILabel *v = [[UILabel alloc] initWithFrame:CGRectMake(0, yOffset, 60, 50)];
        v.text = [NSString stringWithFormat:@"%d", i];
        v.backgroundColor = [UIColor colorWithHue:(i / 15.) saturation:1. brightness:1. alpha:1.];
        [scrollView addSubview:v];
        yOffset -= 50;
    }
      */
    /*
    if (cluster.representative) {
        ShapeView *shapeView = [[ShapeView alloc] initWithShape:cluster.representative];
        shapeView.center = CGPointMake(30, 300);
        [self addSubview:shapeView];
    }
     */
    //[self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)dealloc {
    self.cluster = nil;
    [self removeObserver:self forKeyPath:@"cluster"];
}

- (void)layoutSubviews {
    self.cluster = cluster;
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
