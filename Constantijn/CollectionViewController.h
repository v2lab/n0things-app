//
//  CollectionViewController.h
//  Constantijn
//
//  Created by Jan Misker on 22-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shape+CD.h"
#import <AVFoundation/AVFoundation.h>

@interface CollectionViewController : UIViewController <UIScrollViewDelegate> {
    AVAudioPlayer *audioSuccess;
}

@property (strong, nonatomic) Shape *latestShape;

@property (strong, nonatomic) IBOutlet UIView *collectionContainer;
@property (strong, nonatomic) IBOutlet UIScrollView *collectionScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *clustersScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *clustersPageControl;

- (IBAction)backTapped:(id)sender;
- (IBAction)changePage:(id)sender;

@end
