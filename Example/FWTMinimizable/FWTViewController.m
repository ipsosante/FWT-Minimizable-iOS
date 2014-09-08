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

- (IBAction)_presentModalAction:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    
    UINavigationController *controller = [mainStoryboard instantiateViewControllerWithIdentifier:FWTModalNavigationControllerIdentifier];
    
    [self presentModalController:controller withCompletionBlock:nil];
}

@end
