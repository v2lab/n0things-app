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
#import <QuartzCore/QuartzCore.h>

@interface CollectionViewController ()

@end

@implementation CollectionViewController
@synthesize collectionScrollView;
@synthesize clustersScrollView;
@synthesize clustersPageControl;
@synthesize latestShape;
@synthesize collectionContainer;


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

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"presentCollectionWithNewShape"]) {
        self.latestShape = sender;
        NSLog(@"presentCollectionWithNewShape %@", sender);
    }
}
*/
- (void)viewWillAppear:(BOOL)animated {
    NSArray *clusters = [CollectionManager sharedInstance].clusters;
    //CGRect f = CGRectMake(10, 10, 60, 400);
    CGFloat xOffset = 0;
    for (Cluster *cluster in clusters) {
        ClusterView *clusterView = [[ClusterView alloc] initWithCluster:cluster];
        //clusterView.backgroundColor = [UIColor blueColor];
        clusterView.frame = CGRectMake(xOffset, 0., 80., self.collectionContainer.bounds.size.height);
        [self.collectionContainer addSubview:clusterView];
        UIView *clusterRepresentativeView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 0., 80., 80.)];
        if (cluster.representative) {
            ShapeView *sv = [[ShapeView alloc] initWithShape:cluster.representative];
            [clusterRepresentativeView addSubview:sv];
            sv.frame = CGRectInset(clusterRepresentativeView.bounds, 20, 20);
        } else {
            NSLog(@"no representative found for cluster %@", cluster.id);
        }
        //clusterRepresentativeView.layer.borderWidth = 2.;
        //clusterRepresentativeView.backgroundColor = [UIColor colorWithHue:i / 8. saturation:1. brightness:1. alpha:.4];
        [self.clustersScrollView addSubview:clusterRepresentativeView];
        xOffset += 80;
    }
    self.clustersPageControl.numberOfPages = ceil(clusters.count / 4.);
    self.clustersScrollView.contentSize = CGSizeMake(self.clustersPageControl.numberOfPages * 4 * 80, 80);
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

@end
