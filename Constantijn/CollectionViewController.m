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

@interface CollectionViewController ()

@end

@implementation CollectionViewController
@synthesize collectionContainer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    NSArray *clusters = [CollectionManager sharedInstance].clusters;
    CGRect f = CGRectMake(10, 10, 60, 400);
    for (Cluster *cluster in clusters) {
        ClusterView *clusterView = [[ClusterView alloc] initWithCluster:cluster];
        clusterView.backgroundColor = [UIColor blueColor];
        clusterView.frame = f;
        [self.collectionContainer addSubview:clusterView];
        f.origin = CGPointMake(f.origin.x + 80, f.origin.y);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setCollectionContainer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
