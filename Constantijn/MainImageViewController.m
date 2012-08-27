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

#define ANIMATION_DURATION 1.0

@interface MainImageViewController ()

- (void)contourDetectionDone:(ImageProcessingOperation *)operation;

@end

@implementation MainImageViewController
@synthesize titleImage;
@synthesize pleaseWaitImage;
@synthesize cameraButton;
@synthesize submitButton;
@synthesize submitIndicator, selectionBox, imageView;

- (void)shapeSubmitSuccesObjectId:(NSString *)objectId {
    NSLog(@"shapeSubmitSuccesObjectId %@", objectId);
    [submitIndicator stopAnimating];
    [submitWaiting dismissWithClickedButtonIndex:0 animated:YES];
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
        NSLog(@"finishedProcessingImage %@, %@", [currentShapeRecord.vertices description], currentShapeRecord.color);
        self.titleImage.image = [UIImage imageNamed:@"title-submit-shape"];
        self.submitButton.hidden = NO;
        self.pleaseWaitImage.hidden = YES;
        self.imageView.userInteractionEnabled = YES;
        [self.submitIndicator stopAnimating];
        currentShapeRecordView = [[ShapeRecordView alloc] initWithShapeRecord:currentShapeRecord];
        CGRect f;
        f.origin = CGPointZero;
        f.size = imageView.image.size;
        CGFloat scaleX = self.imageView.image.size.width / self.imageView.bounds.size.width;
        CGFloat scaleY = self.imageView.image.size.height / self.imageView.bounds.size.height;
        CGFloat scale = MIN(scaleX, scaleY); // because image is set to aspect fill
        CGFloat offsetX = (self.imageView.bounds.size.width * scale - self.imageView.image.size.width) / 2.;
        CGFloat offsetY = (self.imageView.bounds.size.height * scale - self.imageView.image.size.height) / 2.;
        currentShapeRecordView.frame = f;
        //currentShapeRecordView.layer.anchorPoint = CGPointZero;
        currentShapeRecordView.userInteractionEnabled = NO;
        currentShapeRecordView.transform = CGAffineTransformMakeScale(1./scale, 1./scale);
        CGRect f1 = currentShapeRecordView.frame;
        f1.origin = CGPointZero;
        currentShapeRecordView.frame = f1;
        currentShapeRecordView.transform = CGAffineTransformConcat(currentShapeRecordView.transform, CGAffineTransformMakeTranslation(offsetX, offsetY));
        
        [self.view addSubview:currentShapeRecordView];
    } else {
        NSLog(@"no contour found"); //ToDO something
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.selectionBox.layer.borderWidth = 3.;
    self.selectionBox.layer.borderColor = [UIColor colorWithWhite:1. alpha:.5].CGColor;
    self.selectionBox.layer.shadowColor = [UIColor blackColor].CGColor;
    self.selectionBox.layer.shadowOffset = CGSizeMake(2., 2.);
    self.selectionBox.layer.shadowOpacity = 0.5;
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
}
- (void)viewWillAppear:(BOOL)animated {
    //[self showCamera:nil];
    selectionOrigin = CGPointZero;
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"picker finish %@", [info description]);
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
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
        [self performSegueWithIdentifier:@"presentCollection" sender:nil];
    }
}

- (IBAction)showCamera:(id)sender {
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
    submitWaiting = [[UIAlertView alloc] initWithTitle:@"Submitting" message:@"Your image is being processed" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"<debug>", nil];
    [self.submitIndicator startAnimating];
    [submitWaiting show];
    self.navigationItem.prompt = nil;
    [[CollectionManager sharedInstance] submitShapeRecord:currentShapeRecord delegate:self];
}

- (IBAction)panGesture:(UIGestureRecognizer *)sender {
    CGPoint p = [sender locationInView:self.view];
    if (sender.state == UIGestureRecognizerStateBegan) {
        selectionOrigin = p;
        self.selectionBox.bounds = CGRectZero;
        self.selectionBox.hidden = NO;
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
        NSLog(@"photo size %f,%f", self.imageView.image.size.width, self.imageView.image.size.height);
        self.titleImage.image = [UIImage imageNamed:@"title-detecting-shape"];
        self.imageView.userInteractionEnabled = NO;
        self.pleaseWaitImage.hidden = NO;
        [self.submitIndicator startAnimating];
        CGRect r = self.selectionBox.frame;
        CGFloat scaleX = self.imageView.image.size.width / self.imageView.bounds.size.width;
        CGFloat scaleY = self.imageView.image.size.height / self.imageView.bounds.size.height;
        CGFloat scale = MIN(scaleX, scaleY); // because image is set to aspect fill
        CGFloat offsetX = (self.imageView.bounds.size.width * scale - self.imageView.image.size.width) / 2.;
        CGFloat offsetY = (self.imageView.bounds.size.height * scale - self.imageView.image.size.height) / 2.;
        r = CGRectMake(r.origin.x * scale - offsetX, r.origin.y * scale - offsetY, r.size.width * scale, r.size.height * scale);
        NSLog(@"scaleX %f scaleY %f ofssetX %f offsetY %f", scaleX, scaleY, offsetX, offsetY);
        NSLog(@"asking contour detection on %f,%f %f,%f", r.origin.x, r.origin.y, r.size.width, r.size.height);
        ImageProcessingOperation *op = [[ImageProcessingOperation alloc] initWithImage:self.imageView.image selection:r];
        [op addObserver:self forKeyPath:@"isFinished" options:0 context:NULL];
        [queue addOperation:op];
        //[self.imageProcessor processImage:self.imageView.image selection:self.selectionBox.frame delegate:self];
        //[self.imageProcessor detectContourForImage:self.imageView.image selection:self.selectionBox.frame delegate:self];
    }
}

- (IBAction)backTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
