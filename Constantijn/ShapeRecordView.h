//
//  ShapeRecordView.h
//  Constantijn
//
//  Created by Jan Misker on 23-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShapeRecord.h"

@interface ShapeRecordView : UIView {
    UIBezierPath *path;
    ShapeRecord *shapeRecord;
}

- (id)initWithShapeRecord:(ShapeRecord *)_shapeRecord;

@end
