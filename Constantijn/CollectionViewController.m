//
//  CollectionViewController.m
//  Constantijn
//
//  Created by Jan Misker on 22-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionManager.h"
#import "ClusterView.h"
#import "ShapeView.h"
#import "ShapeRecord.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>

@interface CollectionViewController () <MFMailComposeViewControllerDelegate>

- (AVAudioPlayer *)loadAudioPlayer:(NSString *)filename;

@end

@implementation CollectionViewController
@synthesize collectionScrollView;
@synthesize clustersScrollView;
@synthesize clustersPageControl;
@synthesize latestShape;
@synthesize collectionContainer;

#pragma mark shape doubletap to email 

- (void)shapeDoubleTapped:(NSNotification *)notif {
    ShapeView *sv = notif.object;
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    NSError *err = nil;
    [sv.shape addShapeRecord];
    ShapeRecord *shapeRecord = sv.shape.shapeRecord;
    
    NSData *contourData = [NSJSONSerialization dataWithJSONObject:sv.shape.contour options:0 error:&err];
    if (err) {
        NSLog(@"error serializing to JSON %@", [err description]);
        return;
    }
    NSData *colorData = [NSJSONSerialization dataWithJSONObject:shapeRecord.color options:0 error:&err];
    if (err) {
        NSLog(@"error serializing to JSON %@", [err description]);
        return;
    }

    ShapeView *shapeView = [[ShapeView alloc] initWithShape:sv.shape];
    shapeView.bounds = CGRectMake(0., 0., 200., 200.);
    UIGraphicsBeginImageContextWithOptions(shapeView.bounds.size, NO, 0.0);
    [shapeView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *png = UIImagePNGRepresentation(img);

    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    [mailer setSubject:@"N0things shape"];
    NSString *txt = [NSString stringWithFormat:@"N0things shape data\n\nID: %@\n\nDate: %@\n\nRGB:%@\n\nShape: %@\n\nhttp://www.constantijnsmit.nl",
                     sv.shape.id,
                     [NSDate dateWithTimeIntervalSinceReferenceDate:sv.shape.submittedDate],
                     [[NSString alloc] initWithData:colorData encoding:NSUTF8StringEncoding],
                     [[NSString alloc] initWithData:contourData encoding:NSUTF8StringEncoding]];
    [mailer setMessageBody:txt isHTML:NO];
    [mailer setToRecipients:[NSArray arrayWithObject:@"n0things@constantijnsmit.nl"]];
        //NSData *svgData = [@"<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\"><path d=\"M150 0 L75 200 L225 200 Z\" /></svg>" dataUsingEncoding:NSUTF8StringEncoding];
    [mailer addAttachmentData:png mimeType:@"image/png" fileName:[NSString stringWithFormat:@"n0things_%@.png", sv.shape.id]];
    [self presentViewController:mailer animated:YES completion:^{
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark Scrolling and Paging of clusters
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat page = ceil(scrollView.contentOffset.x / scrollView.bounds.size.width);
    clustersPageControl.currentPage = page;
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint scrollOffset = self.clustersScrollView.contentOffset;
    collectionContainer.frame = CGRectMake(-scrollOffset.x, collectionContainer.frame.origin.y, scrollOffset.x + 320, collectionContainer.frame.size.height);
}
- (void)changePage:(id)sender {
    [self.clustersScrollView setContentOffset:CGPointMake(self.clustersPageControl.currentPage * self.clustersScrollView.bounds.size.width, 0) animated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    for (ClusterView *v in self.collectionContainer.subviews) {
        [v flashScrollIndicators];
    }
    if (latestShape) {
        [audioSuccess play];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shapeDoubleTapped:) name:@"ShapeDoubleTapped" object:nil];
    Cluster *latestCluster = nil;
    if (latestShape) {
        latestCluster = latestShape.cluster;
    }
    NSArray *clusters = [CollectionManager sharedInstance].clusters;
    //CGRect f = CGRectMake(10, 10, 60, 400);
    CGFloat xOffset = 0;
    self.clustersPageControl.numberOfPages = ceil(clusters.count / 4.);
    self.clustersScrollView.contentSize = CGSizeMake(self.clustersPageControl.numberOfPages * 4 * 80, 80);
    for (Cluster *cluster in clusters) {
        ClusterView *clusterView = [[ClusterView alloc] initWithCluster:cluster];
        clusterView.latestShape = self.latestShape;
        //clusterView.backgroundColor = [UIColor blueColor];
        clusterView.frame = CGRectMake(xOffset, 0., 80., self.collectionContainer.bounds.size.height);
        //clusterView.layer.borderWidth = 1.;
        [self.collectionContainer addSubview:clusterView];
        UIView *clusterRepresentativeView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 0., 80., 80.)];
        if (cluster.representative) {
            ShapeView *sv = [[ShapeView alloc] initWithShape:cluster.representative];
            sv.representsCluster = YES;
            [clusterRepresentativeView addSubview:sv];
            sv.frame = CGRectInset(clusterRepresentativeView.bounds, 20, 20);
        } else {
            NSLog(@"no representative found for cluster %@", cluster.id);
        }
        //clusterRepresentativeView.layer.borderWidth = 2.;
        //clusterRepresentativeView.backgroundColor = [UIColor colorWithHue:i / 8. saturation:1. brightness:1. alpha:.4];
        [self.clustersScrollView addSubview:clusterRepresentativeView];
        if (cluster == latestShape.cluster) {
            self.clustersScrollView.contentOffset = CGPointMake(floor(xOffset / 320) * 320, 0);
            [self scrollViewDidScroll:self.clustersScrollView];
            self.clustersPageControl.currentPage = floor(xOffset / 320);
        }
        xOffset += 80;
    }
    /*
    Cluster *cluster = [clusters lastObject];
    for (int i = 0; i < 11; ++i) {
        ClusterView *clusterView = [[ClusterView alloc] initWithCluster:cluster];
        //[clusterView sizeToFit];
        clusterView.frame = CGRectMake(xOffset, 0., 80., self.collectionContainer.bounds.size.height);
        [self.collectionContainer addSubview:clusterView];
        UIView *clusterRepresentativeView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 0., 80., 80.)];
        if (cluster.representative) {
            ShapeView *sv = [[ShapeView alloc] initWithShape:cluster.representative];
            [clusterRepresentativeView addSubview:sv];
        }
        //clusterRepresentativeView.layer.borderWidth = 2.;
        clusterRepresentativeView.backgroundColor = [UIColor colorWithHue:i / 8. saturation:1. brightness:1. alpha:.4];
        [self.clustersScrollView addSubview:clusterRepresentativeView];
        xOffset += 80;
    }
    self.clustersPageControl.numberOfPages = ceil(11. / 4.);
    self.clustersScrollView.contentSize = CGSizeMake(self.clustersPageControl.numberOfPages * 4 * 80, 80);
     */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.clustersScrollView.layer.borderWidth = 1.;
    self.clustersScrollView.layer.borderColor = [UIColor grayColor].CGColor;
    audioSuccess = [self loadAudioPlayer:@"well done"];
}

- (void)viewDidUnload
{
    [self setClustersPageControl:nil];
    [self setClustersScrollView:nil];
    [self setCollectionScrollView:nil];
    [self setCollectionContainer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backTapped:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
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

@end
