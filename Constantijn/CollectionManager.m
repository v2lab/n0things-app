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
            SimpleDBSelectRequest *req = [[SimpleDBSelectRequest alloc] initWithSelectExpression:@"select * from `Generations` ORDER BY Timestamp LIMIT 1"];
            SimpleDBSelectResponse *resp = [simpleDBClient select:req];
            NSLog(@"response: %@", resp);
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
        [self checkForNewGeneration];
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        //self.currentGenerationTimestamp = [defs objectForKey:@"currentGenerationTimestamp"];
        struct tm  sometime;
        const char *formatString = "%Y%m%dT%H%M%S%Z";
        (void) strptime_l("20050701T120000Z", formatString, &sometime, NULL);
        NSLog(@"NSDate is %@", [NSDate dateWithTimeIntervalSince1970: mktime(&sometime)]);
        // Output: NSDate is 2005-07-01 12:00:00 -0700
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
