//
//  CollectionManager.m
//  Constantijn
//
//  Created by Jan Misker on 13-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import "CollectionManager.h"
#include <xlocale.h>                                    // for strptime_l
#import "Constants.h"

@implementation CollectionManager

@synthesize classes, objects;

- (void)loadRemoteCollection {
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uuid"];
    NSLog(@"loadRemoteCollection for uuid %@", uuid);
}

- (void)submitShape:(UIBezierPath *)path color:(UIColor *)color {
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uuid"];
    NSLog(@"loadRemoteCollection for uuid %@", uuid);
}

- (void)checkForNewGeneration {
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        @try {
            NSString *selectExpr = [NSString stringWithFormat:@"SELECT * FROM `Generation` WHERE Timestamp > '%@' ORDER BY Timestamp DESC LIMIT 1", currentGenerationTimestamp];
            SimpleDBSelectRequest *req = [[SimpleDBSelectRequest alloc] initWithSelectExpression:selectExpr];
            SimpleDBSelectResponse *resp = [simpleDBClient select:req];
            NSLog(@"req: %@ \nresponse: %@", req, resp);
            if (resp.items.count) {
                SimpleDBItem *newGenerationItem = [resp itemsObjectAtIndex:0];
                NSString *timestamp = nil;
                NSArray *weights = nil;
                for (SimpleDBAttribute *attr in newGenerationItem.attributes) {
                    if ([attr.name isEqualToString:@"Timestamp"]) {
                        timestamp = attr.value;
                    }
                    if ([attr.name isEqualToString:@"Weights"]) {
                        NSError *err;
                        weights = [NSJSONSerialization JSONObjectWithData:[attr.value dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err];
                    }
                }
                if (timestamp && timestamp.length && weights && [weights isKindOfClass:[NSArray class]] && weights.count == 12) {
                    NSLog(@"found this data %@ %@", timestamp, [[weights objectAtIndex:1] class]);
                    currentGenerationWeights = weights;
                    currentGenerationTimestamp = timestamp;
                    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
                    [defs setObject:currentGenerationTimestamp forKey:@"currentGenerationTimestamp"];
                    [defs setObject:currentGenerationWeights forKey:@"currentGenerationWeights"];
                    [defs synchronize];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception calling Amazon %@", [exception description]);
        }
    }];
    [queue addOperation:op];
}

- (id)init {
    self = [super init];
    if (self) {
        classes = [NSArray array];
        objects = [NSDictionary dictionary];
        simpleDBClient = [[AmazonSimpleDBClient alloc] initWithAccessKey:AWS_KEY withSecretKey:AWS_SECRET];
        queue = [[NSOperationQueue alloc] init];
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        currentGenerationTimestamp = [defs stringForKey:@"currentGenerationTimestamp"];
        currentGenerationWeights = [defs arrayForKey:@"currentGenerationWeights"];
        [self checkForNewGeneration];
    }
    return self;
}

+ (CollectionManager *)sharedInstance {
    static dispatch_once_t pred;
    static CollectionManager *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[CollectionManager alloc] init];
    });
    return shared;
}

@end
