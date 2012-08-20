//
//  Cluster.h
//  Constantijn
//
//  Created by Jan Misker on 19-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Object;

@interface Cluster : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * centroid;
@property (nonatomic, retain) NSString * generation;
@property (nonatomic, retain) NSSet *objects;
@property (nonatomic, retain) NSSet *representatives;
@end

@interface Cluster (CoreDataGeneratedAccessors)

- (void)addObjectsObject:(Object *)value;
- (void)removeObjectsObject:(Object *)value;
- (void)addObjects:(NSSet *)values;
- (void)removeObjects:(NSSet *)values;

- (void)addRepresentativesObject:(Object *)value;
- (void)removeRepresentativesObject:(Object *)value;
- (void)addRepresentatives:(NSSet *)values;
- (void)removeRepresentatives:(NSSet *)values;

@end
