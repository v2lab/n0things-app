//
//  Shape+CD.h
//  Constantijn
//
//  Created by Jan Misker on 27-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import "Shape.h"
#import "ShapeRecord.h"

@interface Shape (CD)

@property (nonatomic, retain) UIColor * color;
@property (nonatomic, retain) NSArray * contour;
@property (nonatomic, retain) ShapeRecord * shapeRecord;

- (void)addShapeRecord;

@end
