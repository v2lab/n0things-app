//
//  AboutViewController.m
//  Constantijn
//
//  Created by Jan Misker on 29-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

@synthesize webview;

- (IBAction)backTapped:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webview.scrollView.scrollEnabled = NO;
    [self.webview loadHTMLString:@"<html><head><style type='text/css'>html,body{background-color:rgba(0,0,0,0);}body{margin:12px;font-family:Courier;text-align:center;}h1{font-size:20px;}p{margin:8px 0;}a{color:black;text-decoration:none;}</style><body><h1>N0things is an artwork as shape detector application with a dynamic shared collection.</h1><p>Concept&Design:<br/>Constantijn Smit</p><p>Development:<br/>Artm Baguinski<br/>Jan Misker</p><p>N0things was developed in cooperation with V2_ Institute for the Unstable Media</p><p><a href='http://www.constantijnsmit.nl'>www.constantijnsmit.nl</a><br/><a href='http://www.v2.nl'>www.v2.nl</a></p><p>2012 &copy; Constantijn Smit</p></body></html>" baseURL:nil];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
