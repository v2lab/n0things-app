//
//  ViewController.m
//  Constantijn
//
//  Created by Jan Misker on 08-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import "MainImageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageProcessingOperation.h"
#import "CollectionViewController.h"

#define ANIMATION_DURATION 1.0

@interface MainImageViewController ()

- (void)contourDetectionDone:(ImageProcessingOperation *)operation;
- (void)imageCaptured;
- (AVAudioPlayer *)loadAudioPlayer:(NSString *)filename;

@end

@implementation MainImageViewController
@synthesize capturePreview;
@synthesize titleImage;
@synthesize pleaseWaitImage;
@synthesize cameraButton;
@synthesize submitButton;
@synthesize submitIndicator, selectionBox, imageView;
@synthesize captureManager;

- (void)shapeSubmitSuccesObjectId:(Shape *)shape {
    NSLog(@"shapeSubmitSuccesObjectId %@", shape);
    [submitIndicator stopAnimating];
    //[submitWaiting dismissWithClickedButtonIndex:0 animated:YES];
    [self performSegueWithIdentifier:@"presentCollectionWithNewShape" sender:shape];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"presentCollectionWithNewShape"]) {
        ((CollectionViewController *)segue.destinationViewController).latestShape = sender;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[ImageProcessingOperation class]]) {
        ImageProcessingOperation *op = (ImageProcessingOperation *)object;
        [self performSelectorOnMainThread:@selector(contourDetectionDone:) withObject:op waitUntilDone:NO];
    }
}

- (void)contourDetectionDone:(ImageProcessingOperation *)operation {
    currentShapeRecord = operation.shapeRecord;
    [currentShapeRecordView removeFromSuperview];
    if (currentShapeRecord) {
        [audioSelectOk play];
        //NSLog(@"finishedProcessingImage %@, %@", [currentShapeRecord.vertices description], currentShapeRecord.color);
        self.titleImage.image = [UIImage imageNamed:@"title-submit-shape"];
        self.submitButton.hidden = NO;
        self.pleaseWaitImage.hidden = YES;
        self.imageView.userInteractionEnabled = YES;
        [self.submitIndicator stopAnimating];
        currentShapeRecordView = [[ShapeRecordView alloc] initWithShapeRecord:currentShapeRecord];
        //CGRect f;
        //f.origin = CGPointZero;
        //f.size = imageView.image.size;
        
        //CGRect scaledImageRect = CGRectMake(0, 0, 480., 480. * self.imageView.image.size.height / self.imageView.image.size.width);
        CGSize scaledImageSize = self.imageView.image.size;
        
        CGFloat scaleX = scaledImageSize.width / self.imageView.bounds.size.width;
        CGFloat scaleY = scaledImageSize.height / self.imageView.bounds.size.height;
        CGFloat scale = MIN(scaleX, scaleY); // because image is set to aspect fill
        CGFloat offsetX = (self.imageView.bounds.size.width * scale - scaledImageSize.width) / 2.;
        CGFloat offsetY = (self.imageView.bounds.size.height * scale - scaledImageSize.height) / 2.;
        CGRect f;
        f.origin = CGPointZero;
        f.size = scaledImageSize;
        currentShapeRecordView.frame = f;
        //currentShapeRecordView.layer.anchorPoint = CGPointZero;
        currentShapeRecordView.userInteractionEnabled = NO;
        currentShapeRecordView.transform = CGAffineTransformMakeScale(1./scale, 1./scale);
        CGRect f1 = currentShapeRecordView.frame;
        f1.origin = CGPointZero;
        currentShapeRecordView.frame = f1;
        currentShapeRecordView.transform = CGAffineTransformConcat(currentShapeRecordView.transform, CGAffineTransformMakeTranslation(offsetX / scale, offsetY / scale));
        
        [self.view addSubview:currentShapeRecordView];
    } else {
        NSLog(@"no contour found"); //ToDO something
        [audioSelectError play];
        self.selectionBox.layer.borderColor = [[UIColor redColor] colorWithAlphaComponent:.5].CGColor;
        self.imageView.userInteractionEnabled = YES;
        [self.submitIndicator stopAnimating];
        self.pleaseWaitImage.hidden = YES;
        self.titleImage.image = [UIImage imageNamed:@"title-select-shape"];
    }
}

- (void)imageCaptured {
    self.imageView.image = self.captureManager.stillImage;
    self.titleImage.image = [UIImage imageNamed:@"title-select-shape"];
    self.cameraButton.hidden = YES;
    self.imageView.userInteractionEnabled = YES;
    [UIView animateWithDuration:.5 delay:.1 options:0 animations:^{
        self.selectShapePopup.alpha = 1.;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.5 delay:.5 options:0 animations:^{
            self.selectShapePopup.alpha = 0.;
        } completion:NULL];
    }];
    [self.captureManager.captureSession stopRunning];
}

- (AVAudioPlayer *)loadAudioPlayer:(NSString *)filename {
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:filename ofType: @"wav"];
    if (!soundFilePath) {
        return nil;
    }
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    if (fileURL) {
        AVAudioPlayer *result = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        [result prepareToPlay];
        return result;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    audioPhotoClick = [self loadAudioPlayer:@"foto klik"];
    audioSendShape = [self loadAudioPlayer:@"send shape"];
    audioSelectOk = [self loadAudioPlayer:@"select shape success"];
    audioSelectError = [self loadAudioPlayer:@"error selection v2"];

    self.selectShapePopup.alpha = 0.;
    self.selectShapePopup.layer.cornerRadius = 5.;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageCaptured) name:kImageCapturedSuccessfully object:nil];
	// Do any additional setup after loading the view, typically from a nib.
    self.selectionBox.layer.borderWidth = 3.;
    self.selectionBox.layer.borderColor = [UIColor colorWithWhite:1. alpha:.5].CGColor;
    self.selectionBox.layer.shadowColor = [UIColor blackColor].CGColor;
    self.selectionBox.layer.shadowOffset = CGSizeMake(2., 2.);
    self.selectionBox.layer.shadowOpacity = 0.5;
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
	self.captureManager = [[CaptureSessionManager alloc] init];
    
	[[self captureManager] addVideoInput];
    
	[[self captureManager] addVideoPreviewLayer];
	CGRect layerRect = self.capturePreview.layer.bounds;
	[[[self captureManager] previewLayer] setBounds:layerRect];
	[[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                  CGRectGetMidY(layerRect))];
	[self.capturePreview.layer addSublayer:[[self captureManager] previewLayer]];
    [[self captureManager] addStillImageOutput];
	[[captureManager captureSession] startRunning];
}
- (void)viewWillAppear:(BOOL)animated {
    //[self showCamera:nil];
    selectionOrigin = CGPointZero;
    
    return;
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    cameraController.allowsEditing = NO;
        //cameraController.navigationItem.title = @"Nothings";
    cameraController.delegate = self;
    [self presentModalViewController:cameraController animated:YES];

}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"picker finish %@", [info description]);
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    /* Make sure displayed image is always in default orientation, so it's easy on us
       FIXME Jan do we have to release img here?
     */
    UIImageOrientation ori = img.imageOrientation;
    if (ori != UIImageOrientationUp) {
        UIGraphicsBeginImageContext(img.size);
        [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
        img = UIGraphicsGetImageFromCurrentImageContext();
    }
    
    self.imageView.image = img;
    [self dismissModalViewControllerAnimated: YES];
    self.titleImage.image = [UIImage imageNamed:@"title-select-shape"];
    self.cameraButton.hidden = YES;
    self.imageView.userInteractionEnabled = YES;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated: YES];
    //self.titleImage.image = [UIImage imageNamed:@"title-select-shape"];
    //self.cameraButton.hidden = YES;
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setSelectionBox:nil];
    [self setSubmitIndicator:nil];
    [self setSubmitButton:nil];
    [self setCameraButton:nil];
    [self setSubmitButton:nil];
    [self setTitleImage:nil];
    [self setPleaseWaitImage:nil];
    [self setCapturePreview:nil];
    [self setSelectShapePopup:nil];
    [super viewDidUnload];
    queue = nil;
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.submitIndicator stopAnimating];
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self performSegueWithIdentifier:@"presentCollectionWithNewShape" sender:nil];
    }
}

- (IBAction)showCamera:(id)sender {
    self.cameraButton.enabled = NO;
    [self.captureManager captureStillImage];
    return;
    
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    cameraController.allowsEditing = NO;
    //cameraController.navigationItem.title = @"Nothings";
    cameraController.delegate = self;
    [self presentModalViewController:cameraController animated:YES];
}

- (IBAction)submitImage:(id)sender {
    //submitWaiting = [[UIAlertView alloc] initWithTitle:@"Submitting" message:@"Your image is being processed" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"<debug>", nil];
    [self.submitIndicator startAnimating];
    [audioSendShape play];
    self.submitButton.hidden = YES;
    self.imageView.userInteractionEnabled = NO;
    //[submitWaiting show];
    self.navigationItem.prompt = nil;
    [[CollectionManager sharedInstance] submitShapeRecord:currentShapeRecord delegate:self];
}

- (IBAction)panGesture:(UIGestureRecognizer *)sender {
    CGPoint p = [sender locationInView:self.view];
    if (sender.state == UIGestureRecognizerStateBegan) {
        selectionOrigin = p;
        self.selectionBox.bounds = CGRectZero;
        self.selectionBox.hidden = NO;
        self.submitButton.hidden = YES;
        self.selectionBox.layer.borderColor = [UIColor colorWithWhite:1. alpha:.5].CGColor;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat x1 = selectionOrigin.x;
        CGFloat x2 = p.x;
        CGFloat y1 = selectionOrigin.y;
        CGFloat y2 = p.y;
        CGFloat x = MIN(x1, x2);
        CGFloat y = MIN(y1, y2);
        CGRect r = CGRectMake(x, y, ABS(x1 - x2), ABS(y1 - y2));
        self.selectionBox.frame = r;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"panGesture done %f,%f %f,%f", self.selectionBox.frame.origin.x, self.selectionBox.frame.origin.y, self.selectionBox.frame.size.width, self.selectionBox.frame.size.height);
        
        UIImage *targetImage = self.imageView.image;
        UIImageOrientation ori = targetImage.imageOrientation;
        if (ori != UIImageOrientationUp) {
            UIGraphicsBeginImageContext(targetImage.size);
            [targetImage drawInRect:CGRectMake(0, 0, targetImage.size.width, targetImage.size.height)];
            targetImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        NSLog(@"photo size %f,%f", targetImage.size.width, targetImage.size.height);
        self.titleImage.image = [UIImage imageNamed:@"title-detecting-shape"];
        self.imageView.userInteractionEnabled = NO;
        self.pleaseWaitImage.hidden = NO;
        [self.submitIndicator startAnimating];
        CGRect r = self.selectionBox.frame;
        CGFloat scaleX = targetImage.size.width / self.imageView.bounds.size.width;
        CGFloat scaleY = targetImage.size.height / self.imageView.bounds.size.height;
        CGFloat scale = MIN(scaleX, scaleY); // because image is set to aspect fill
        CGFloat offsetX = (self.imageView.bounds.size.width * scale - targetImage.size.width) / 2.;
        CGFloat offsetY = (self.imageView.bounds.size.height * scale - targetImage.size.height) / 2.;
        r = CGRectMake(r.origin.x * scale - offsetX, r.origin.y * scale - offsetY, r.size.width * scale, r.size.height * scale);
        NSLog(@"scaleX %f scaleY %f ofssetX %f offsetY %f", scaleX, scaleY, offsetX, offsetY);
        NSLog(@"asking contour detection on %f,%f %f,%f", r.origin.x, r.origin.y, r.size.width, r.size.height);
        ImageProcessingOperation *op = [[ImageProcessingOperation alloc] initWithImage:targetImage selection:r];
        [op addObserver:self forKeyPath:@"isFinished" options:0 context:NULL];
        [queue addOperation:op];
        //[self.imageProcessor processImage:self.imageView.image selection:self.selectionBox.frame delegate:self];
        //[self.imageProcessor detectContourForImage:self.imageView.image selection:self.selectionBox.frame delegate:self];
    }
}

- (IBAction)backTapped:(id)sender {
    if (self.cameraButton.hidden) {
        self.cameraButton.enabled = YES;
        self.imageView.image = nil;
        self.titleImage.image = [UIImage imageNamed:@"title-take-picture"];
        self.cameraButton.hidden = NO;
        self.submitButton.hidden = YES;
        self.pleaseWaitImage.hidden = YES;
        self.imageView.userInteractionEnabled = NO;
        self.selectionBox.hidden = YES;
        [currentShapeRecordView removeFromSuperview];
        currentShapeRecordView = nil;
        [self.captureManager.captureSession startRunning];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
