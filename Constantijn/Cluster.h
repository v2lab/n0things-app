//
//  Cluster.h
//  Constantijn
//
//  Created by Jan Misker on 21-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Shape;

@interface Cluster : NSManagedObject

@property (nonatomic, retain) NSString * centroid;
@property (nonatomic, retain) NSString * generation;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSSet *objects;
@property (nonatomic, retain) Shape *representative;
@end

@interface Cluster (CoreDataGeneratedAccessors)

- (void)addObjectsObject:(Shape *)value;
- (void)removeObjectsObject:(Shape *)value;
- (void)addObjects:(NSSet *)values;
- (void)removeObjects:(NSSet *)values;

@end
