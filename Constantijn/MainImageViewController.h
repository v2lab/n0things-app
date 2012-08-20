//
//  ViewController.h
//  Constantijn
//
//  Created by Jan Misker on 08-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageProcessing.h"

@interface MainImageViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate> {
    CGPoint selectionOrigin;
    ImageProcessing *imageProcessor;
    NSOperationQueue *queue;
    UIAlertView *submitWaiting;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *selectionBox;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *submitIndicator;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *submitButton;

- (IBAction)showCamera:(id)sender;
- (IBAction)submitImage:(id)sender;
- (IBAction)panGesture:(UIGestureRecognizer *)sender;

@end
