//
//  ClusterView.h
//  Constantijn
//
//  Created by Jan Misker on 22-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cluster.h"

@interface ClusterView : UIView {
    Cluster *cluster;
}

@property (nonatomic, strong) Cluster *cluster;

@end
