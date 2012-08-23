//
//  ShapeRecordView.m
//  Constantijn
//
//  Created by Jan Misker on 23-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import "ShapeRecordView.h"

@implementation ShapeRecordView

- (CGPoint)pointForArray:(NSArray *)arr {
    int x = [(NSNumber *)[arr objectAtIndex:0] floatValue];
    int y = [(NSNumber *)[arr objectAtIndex:1] floatValue];
    return CGPointMake(x, y);
}

- (id)initWithShapeRecord:(ShapeRecord *)_shapeRecord {
    self = [super init];
    if (self) {
        shapeRecord = _shapeRecord;
        path = [UIBezierPath bezierPath];
        self.backgroundColor = [UIColor clearColor];
        NSArray *contour = shapeRecord.vertices;
        CGPoint origin = [self pointForArray:[contour objectAtIndex:0]];
        [path moveToPoint:origin];
        for (int i = 1; i < contour.count; ++i) {
            CGPoint p = [self pointForArray:[contour objectAtIndex:i]];
            [path addLineToPoint:p];
        }
        [path closePath];
        NSLog(@"shaperecord path bounds %f,%f %f,%f", path.bounds.origin.x, path.bounds.origin.y, path.bounds.size.width, path.bounds.size.height);
        [path applyTransform:CGAffineTransformMakeTranslation(-path.bounds.origin.x, -path.bounds.origin.y)];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //[self.backgroundColor setFill];
    UIColor *color = [UIColor colorWithRed:[(NSNumber *)[shapeRecord.color objectAtIndex:0] intValue] / 255. green:[(NSNumber *)[shapeRecord.color objectAtIndex:1] intValue] / 255. blue:[(NSNumber *)[shapeRecord.color objectAtIndex:2] intValue] / 255. alpha:.5];
    [color setFill];
    [[UIColor blackColor] setStroke];
    [path fill];
    [path stroke];
}

@end
