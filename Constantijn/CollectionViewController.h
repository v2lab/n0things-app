//
//  CollectionViewController.h
//  Constantijn
//
//  Created by Jan Misker on 22-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *collectionContainer;
@property (strong, nonatomic) NSString *latestShape;

- (IBAction)backTapped:(id)sender;

@end
