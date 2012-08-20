//
//  Object.h
//  Constantijn
//
//  Created by Jan Misker on 19-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Object : NSManagedObject

@property (nonatomic, retain) NSString * collectionId;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * shape;
@property (nonatomic, retain) NSNumber * vertexCount;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * huMoments;
@property (nonatomic, retain) NSNumber * defectsCount;
@property (nonatomic, retain) NSManagedObject *cluster;

@end
