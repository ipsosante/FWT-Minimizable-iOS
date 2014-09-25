//
//  FWTMinimizableNavigationController.m
//  FWTMinimizable
//
//  Created by Carlos Vidal on 09/09/2014.
//  Copyright (c) 2014 Carlos. All rights reserved.
//

#import "FWTMinimizableNavigationController.h"
#import "FWTModalInteractiveTransition.h"

@interface FWTMinimizableNavigationController ()

@property (nonatomic, strong) FWTModalInteractiveTransition *transitioner;
@property (nonatomic, strong) id modalCompletionBlock;
@property (nonatomic, strong) UIView *minimizedView;

@end

@implementation FWTMinimizableNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)presentInteractiveModalController:(UIViewController*)controller withCompletionBlock:(void (^)(void))completionBlock
{
    [self _presentModalController:controller withCompletionBlock:completionBlock interactive:YES];
}

- (void)presentModalController:(UIViewController*)controller withCompletionBlock:(void (^)(void))completionBlock
{
    [self _presentModalController:controller withCompletionBlock:completionBlock interactive:NO];
}

#pragma mark - Private methods
- (void)_presentModalController:(UIViewController*)controller withCompletionBlock:(void (^)(void))completionBlock interactive:(BOOL)isInteractive
{
    [controller.view setBackgroundColor:[UIColor whiteColor]];
    
    self.modalCompletionBlock = completionBlock;
    self.minimizableController = controller;
    
    [self _presentControllerWithInteractionEnabled:isInteractive];
}

- (void)_minimizeController:(UIViewController*)controller
{
    self.minimizableController = controller;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [UIView animateWithDuration:0.6f
                          delay:0.0f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:0.8f
                        options:0
                     animations:^{
                         CGRect finalFrame = self.view.superview.bounds;
                         finalFrame.size.height = finalFrame.size.height - FWTMimizedViewHeight;
                         self.minimizedView.frame = CGRectMake(0, CGRectGetHeight(finalFrame), CGRectGetWidth(finalFrame), FWTMimizedViewHeight);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1f animations:^{
                             CGRect finalFrame = self.view.superview.bounds;
                             finalFrame.size.height = finalFrame.size.height - FWTMimizedViewHeight + 1;
                             finalFrame.size.width += 1;
                             self.view.frame = finalFrame;
                         }];
                     }];
}

- (void)_maximizeController
{
    if (self->_minimizedView == nil){
        return;
    }
    
    [self _presentControllerWithInteractionEnabled:YES];
}

- (void)_presentControllerWithInteractionEnabled:(BOOL)interactionEnabled
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.minimizableController.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioner = [[FWTModalInteractiveTransition alloc] initWithModalViewController:self.minimizableController minimizeBlock:[self _minimizeBlock] dismissBlock:[self _dismissBlock] interactive:interactionEnabled];
    self.minimizableController.transitioningDelegate = self.transitioner;
    
    [self _restoreController];
    
    __weak typeof(self) weakSelf = self;
    [self presentViewController:self.minimizableController animated:YES completion:^{
        typeof(self) refSelf = weakSelf;
        
        if (refSelf.modalCompletionBlock != nil){
            ((void (^)(void))refSelf.modalCompletionBlock)();
        }
    }];
}

- (void)_restoreController
{
    if (self->_minimizedView == nil){
        return;
    }
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect finalFrame = self.view.bounds;
        finalFrame.size.height = CGRectGetHeight(self.view.superview.frame);
        
        self.minimizedView.frame = CGRectMake(0, finalFrame.size.height, CGRectGetWidth(self.minimizedView.frame), FWTMimizedViewHeight);
        
        
        if ([FWTModalInteractiveTransition isIOS8] == true){
            self.view.frame = self.view.superview.bounds;
        }
        else {
            UIViewController *controller = self.viewControllers.lastObject;
            controller.view.frame = finalFrame;
        }
    } completion:^(BOOL finished) {
        [self.minimizedView removeFromSuperview];
        self->_minimizedView = nil;
    }];
}

#pragma mark - Lazy loading
- (FWTModalInteractiveTransitionMinimizeBlock)_minimizeBlock
{
    __weak typeof(self) weakSelf = self;
    
    FWTModalInteractiveTransitionMinimizeBlock block = ^(UIViewController *viewController){
        typeof(self) refSelf = weakSelf;
        
        [refSelf _minimizeController:viewController];
    };
    
    return block;
}

- (FWTModalInteractiveTransitionDismissBlock)_dismissBlock
{
    __weak typeof(self) weakSelf = self;
    
    FWTModalInteractiveTransitionDismissBlock block = ^(UIViewController *viewController){
        typeof(self) refSelf = weakSelf;
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [refSelf setNeedsStatusBarAppearanceUpdate];
    };
    
    return block;
}

- (UIView*)minimizedView
{
    if (self->_minimizedView == nil){
        self->_minimizedView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), FWTMimizedViewHeight)];
        self->_minimizedView.backgroundColor = [UIColor whiteColor];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), FWTMimizedViewHeight)];
        button.backgroundColor = [UIColor whiteColor];
        [button addTarget:self action:@selector(_maximizeController) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:self.view.tintColor forState:UIControlStateNormal];
        
        if ([self.minimizableController respondsToSelector:@selector(title)]){
            [button setTitle:self.minimizableController.title forState:UIControlStateNormal];
        }
        
        [self->_minimizedView addSubview:button];
        
        UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self->_minimizedView.frame), 1.f)];
        topSeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        topSeparator.backgroundColor = [UIColor lightGrayColor];
        
        [self->_minimizedView addSubview:topSeparator];
    }
    
    if (self->_minimizedView.superview == nil){
        [self.view.superview addSubview:self->_minimizedView];
    }
    
    return self->_minimizedView;
}

@end
