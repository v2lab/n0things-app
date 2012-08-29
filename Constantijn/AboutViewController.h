//
//  AboutViewController.h
//  Constantijn
//
//  Created by Jan Misker on 29-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webview;

- (IBAction)backTapped:(id)sender;

@end
