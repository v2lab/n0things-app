//
//  Cluster.h
//  Constantijn
//
//  Created by Jan Misker on 22-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Shape;

@interface Cluster : NSManagedObject

@property (nonatomic, retain) NSArray * centroid;
@property (nonatomic, retain) NSString * generation;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSSet *shapes;
@property (nonatomic, retain) Shape *representative;
@end

@interface Cluster (CoreDataGeneratedAccessors)

- (void)addShapesObject:(Shape *)value;
- (void)removeShapesObject:(Shape *)value;
- (void)addShapes:(NSSet *)values;
- (void)removeShapes:(NSSet *)values;

@end
