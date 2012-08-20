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

@interface MainImageViewController ()

- (void)contourDetectionDone:(ImageProcessingOperation *)operation;

@end

@implementation MainImageViewController
@synthesize submitButton;
@synthesize submitIndicator, selectionBox, imageView;


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[ImageProcessingOperation class]]) {
        ImageProcessingOperation *op = (ImageProcessingOperation *)object;
        [self performSelectorOnMainThread:@selector(contourDetectionDone:) withObject:op waitUntilDone:NO];
    }
}

- (void)contourDetectionDone:(ImageProcessingOperation *)operation {
    ShapeRecord *shapeRecord = operation.shapeRecord;
    NSLog(@"finishedProcessingImage %@, %@", [shapeRecord.vertices description], shapeRecord.color);
    NSArray *shape12D = [ImageProcessing mapShapeRecord:shapeRecord withWeights:[NSArray array]];
    self.navigationItem.prompt = @"Submit the object or select a new one";
    self.submitButton.enabled = YES;
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
}
- (void)viewWillAppear:(BOOL)animated {
    [self showCamera:nil];
    selectionOrigin = CGPointZero;
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"picker finish %@", [info description]);
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = img;
    [self dismissModalViewControllerAnimated:YES];
    self.navigationItem.prompt = @"Select the object of interest";
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
    self.navigationItem.prompt = @"Select the object of interest";
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setSelectionBox:nil];
    [self setSubmitIndicator:nil];
    [self setSubmitButton:nil];
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
    cameraController.navigationItem.title = @"Nothings";
    cameraController.delegate = self;
    [self presentModalViewController:cameraController animated:YES];
}

- (IBAction)submitImage:(id)sender {
    UIAlertView *submitWaiting = [[UIAlertView alloc] initWithTitle:@"Submitting" message:@"Your image is being processed" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"<debug>", nil];
    [self.submitIndicator startAnimating];
    [submitWaiting show];
    self.navigationItem.prompt = nil;
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
        NSLog(@"panGesture done %f,%f", p.x, p.y);
        ImageProcessingOperation *op = [[ImageProcessingOperation alloc] initWithImage:self.imageView.image selection:self.selectionBox.frame];
        [op addObserver:self forKeyPath:@"isFinished" options:0 context:NULL];
        [queue addOperation:op];
        //[self.imageProcessor processImage:self.imageView.image selection:self.selectionBox.frame delegate:self];
        //[self.imageProcessor detectContourForImage:self.imageView.image selection:self.selectionBox.frame delegate:self];
    }
}

@end
