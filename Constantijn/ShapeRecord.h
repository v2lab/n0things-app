//
//  ShapeRecord.h
//  Constantijn
//
//  Created by Jan Misker on 20-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShapeRecord : NSObject {
    NSArray *vertices;
    NSArray *color;
    NSArray *huMoments;
    NSInteger defectsCount;
}

@property (nonatomic, strong) NSArray *vertices;
@property (nonatomic, strong) NSArray *color;
@property (nonatomic, strong) NSArray *huMoments;
@property (nonatomic, assign) NSInteger defectsCount;

@end
