//
//  Cluster.h
//  Constantijn
//
//  Created by Jan Misker on 30-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Shape;

@interface Cluster : NSManagedObject

@property (nonatomic, retain) id centroid;
@property (nonatomic, retain) NSString * generation;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) Shape *representative;
@property (nonatomic, retain) NSOrderedSet *shapes;
@end

@interface Cluster (CoreDataGeneratedAccessors)

- (void)insertObject:(Shape *)value inShapesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromShapesAtIndex:(NSUInteger)idx;
- (void)insertShapes:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeShapesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInShapesAtIndex:(NSUInteger)idx withObject:(Shape *)value;
- (void)replaceShapesAtIndexes:(NSIndexSet *)indexes withShapes:(NSArray *)values;
- (void)addShapesObject:(Shape *)value;
- (void)removeShapesObject:(Shape *)value;
- (void)addShapes:(NSOrderedSet *)values;
- (void)removeShapes:(NSOrderedSet *)values;
@end
