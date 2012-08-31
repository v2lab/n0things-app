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
    Shape *shape;
    UIBezierPath *path;
}

@property (nonatomic, strong) Shape *shape;
@property (nonatomic, strong) UIBezierPath *path;

- (id)initWithShape:(Shape *)shape;

@end
