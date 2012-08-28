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

@interface CollectionViewController ()

@end

@implementation CollectionViewController
@synthesize collectionScrollView;
@synthesize clustersScrollView;
@synthesize clustersPageControl;
@synthesize latestShape;
@synthesize collectionContainer;

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
    /*
    for (Cluster *cluster in clusters) {
        ClusterView *clusterView = [[ClusterView alloc] initWithCluster:cluster];
        clusterView.backgroundColor = [UIColor blueColor];
        clusterView.frame = f;
        [self.collectionContainer addSubview:clusterView];
        f.origin = CGPointMake(f.origin.x + 80, f.origin.y);
    }
     */
    Cluster *cluster = [clusters lastObject];
    self.clustersScrollView.contentSize = CGSizeMake(800,100);
    for (int i = 0; i < 6; ++i) {
        ClusterView *clusterView = [[ClusterView alloc] initWithCluster:cluster];
        //[clusterView sizeToFit];
        clusterView.frame = CGRectMake(xOffset, 0., 80., self.collectionContainer.bounds.size.height);
        [self.collectionContainer addSubview:clusterView];
        ShapeView *sv = [[ShapeView alloc] initWithShape:cluster.representative];
        xOffset += 80;
    }
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
