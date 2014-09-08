//
//  FWTWebViewController.m
//  FWTMinimizable
//
//  Created by Carlos Vidal on 08/09/2014.
//  Copyright (c) 2014 Carlos. All rights reserved.
//

#import "FWTWebViewController.h"

@interface FWTWebViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation FWTWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"About Future Workshops";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.webView.request == nil){
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.futureworkshops.com"]];
        [self.webView loadRequest:request];
    }
}

#pragma mark - Private methods
- (IBAction)_dismiss:(id)sender
{
        [self dismissViewControllerAnimated:YES completion:nil];
}

@end
