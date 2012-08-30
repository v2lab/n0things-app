//
//  Shape+CD.m
//  Constantijn
//
//  Created by Jan Misker on 27-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import "Shape+CD.h"

@implementation Shape (CD)

@dynamic contour;
@dynamic color;
@dynamic shapeRecord;

- (void)addShapeRecord {
    if (self.shapeRecord)
        return;
    ShapeRecord *sr = [[ShapeRecord alloc] init];
    
    CGFloat r,g,b,a;
    if ([self.color getRed:&r green:&g blue:&b alpha:&a]) {
        sr.color = [NSArray arrayWithObjects:[NSNumber numberWithInt:r * 255], [NSNumber numberWithInt:g * 255], [NSNumber numberWithInt:b * 255], nil];
    }
    sr.vertices = [self.contour copy];
    sr.huMoments = [self.huMoments copy];
    sr.defectsCount = self.defectsCount;
    
    self.shapeRecord = sr;
}

@end
