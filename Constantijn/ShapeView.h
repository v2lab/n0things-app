//
//  ShapeView.h
//  Constantijn
//
//  Created by Jan Misker on 23-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shape+CD.h"

@interface ShapeView : UIView {
}

@property (nonatomic, strong) Shape *shape;
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, assign) BOOL representsCluster;

- (id)initWithShape:(Shape *)shape;

@end
