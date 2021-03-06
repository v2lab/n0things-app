//
//  ViewController.h
//  Constantijn
//
//  Created by Jan Misker on 08-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageProcessing.h"
#import "CollectionManager.h"
#import "ShapeRecordView.h"
#import "CaptureSessionManager.h"

@interface MainImageViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, CollectionManagerDelegate> {
    CGPoint selectionOrigin;
    ImageProcessing *imageProcessor;
    NSOperationQueue *queue;
    UIAlertView *submitWaiting;
    ShapeRecord *currentShapeRecord;
    ShapeRecordView *currentShapeRecordView;
    AVAudioPlayer *audioSelectOk;
    AVAudioPlayer *audioSelectError;
    AVAudioPlayer *audioPhotoClick;
    AVAudioPlayer *audioSendShape;
}

@property (strong, nonatomic) IBOutlet UIView *capturePreview;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *selectionBox;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *submitIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *titleImage;

@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) IBOutlet UIImageView *pleaseWaitImage;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIImageView *selectShapePopup;

@property (strong) CaptureSessionManager *captureManager;

- (IBAction)showCamera:(id)sender;
- (IBAction)submitImage:(id)sender;
- (IBAction)panGesture:(UIGestureRecognizer *)sender;
- (IBAction)backTapped:(id)sender;

@end
