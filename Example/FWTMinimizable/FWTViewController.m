//
//  FWTViewController.m
//  FWTMinimizable
//
//  Created by Carlos on 09/08/2014.
//  Copyright (c) 2014 Carlos. All rights reserved.
//

#import "FWTViewController.h"

NSString *const FWTModalNavigationControllerIdentifier = @"FWTModalNavigationControllerIdentifier";

@interface FWTViewController ()

@property (strong, nonatomic) IBOutlet UIButton *presentModalButton;

@end

@implementation FWTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.presentModalButton.layer.borderColor = self.view.tintColor.CGColor;
    self.presentModalButton.layer.borderWidth = 1.f;
    self.presentModalButton.layer.cornerRadius = 4.f;
}

- (IBAction)_presentModalAction:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    
    UINavigationController *controller = [mainStoryboard instantiateViewControllerWithIdentifier:FWTModalNavigationControllerIdentifier];
    
    [self presentModalController:controller withCompletionBlock:nil];
}

@end
