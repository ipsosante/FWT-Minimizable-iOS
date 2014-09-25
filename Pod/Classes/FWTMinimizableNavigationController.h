//
//  FWTMinimizableNavigationController.h
//  FWTMinimizable
//
//  Created by Carlos Vidal on 09/09/2014.
//  Copyright (c) 2014 Carlos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FWTMinimizableNavigationController : UINavigationController

@property (nonatomic, strong) UIViewController *minimizableController;

- (void)presentModalController:(UIViewController*)controller withCompletionBlock:(void (^)(void))completionBlock;
- (void)presentInteractiveModalController:(UIViewController*)controller withCompletionBlock:(void (^)(void))completionBlock;

@end
