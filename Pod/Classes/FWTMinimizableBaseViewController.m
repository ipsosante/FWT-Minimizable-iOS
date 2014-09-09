//
//  FWTMinimizableViewController.m
//  FWT-Retained-Modal-Transition-iOS
//
//  Created by Carlos Vidal on 30/08/2014.
//
//

#import "FWTMinimizableBaseViewController.h"
#import "FWTModalInteractiveTransition.h"

@interface FWTMinimizableBaseViewController () <UIBarPositioningDelegate>

@property (nonatomic, strong) FWTModalInteractiveTransition *transitioner;
@property (nonatomic, strong) id modalCompletionBlock;

@property (nonatomic, strong) UIView *minimizedView;

@end

@implementation FWTMinimizableBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)presentModalController:(UIViewController*)controller withCompletionBlock:(void (^)(void))completionBlock
{
    [controller.view setBackgroundColor:[UIColor whiteColor]];
    
    self.modalCompletionBlock = completionBlock;
    self.minimizableController = controller;
    
    [self _presentControllerWithCustomAnimation];
}

#pragma mark - Private methods
- (void)_minimizeController:(UIViewController*)controller
{
    self.minimizableController = controller;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [UIView animateWithDuration:0.6f
                          delay:0.25f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect finalFrame = self.view.superview.frame;
                         finalFrame.size.height = CGRectGetHeight(finalFrame) - FWTMimizedViewHeight;
                         self.minimizedView.frame = CGRectMake(0, finalFrame.size.height, CGRectGetWidth(self.minimizedView.frame), FWTMimizedViewHeight);
                         self.view.frame = finalFrame;
                     } completion:^(BOOL finished) {
                         CGRect finalFrame = self.view.superview.frame;
                         finalFrame.size.height = CGRectGetHeight(finalFrame) - FWTMimizedViewHeight;
                         self.view.frame = finalFrame;
                     }];
}

- (void)_maximizeController
{
    if (self->_minimizedView == nil){
        return;
    }
    
    [self _presentControllerWithCustomAnimation];
}

- (void)_presentControllerWithCustomAnimation
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.minimizableController.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioner = [[FWTModalInteractiveTransition alloc] initWithModalViewController:self.minimizableController minimizeBlock:[self _minimizeBlock] dismissBlock:[self _dismissBlock]];
    self.minimizableController.transitioningDelegate = self.transitioner;
    
    __weak typeof(self) weakSelf = self;
    [self presentViewController:self.minimizableController animated:YES completion:^{
        typeof(self) refSelf = weakSelf;
        
        [self _restoreController];
        
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
    
    [UIView animateWithDuration:0.2f delay:0.30f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect finalFrame = self.view.superview.frame;
        
        self.minimizedView.frame = CGRectMake(0, finalFrame.size.height, CGRectGetWidth(self.minimizedView.frame), FWTMimizedViewHeight);
        
        self.view.frame = finalFrame;
    } completion:^(BOOL finished) {
        
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
        topSeparator.backgroundColor = [UIColor lightGrayColor];
        
        [self->_minimizedView addSubview:topSeparator];
    }
    
    if (self->_minimizedView.superview == nil){
        [self.view.superview addSubview:self->_minimizedView];
    }
    
    return self->_minimizedView;
}

@end
