//
//  FWTMinimizableViewController.m
//  FWT-Retained-Modal-Transition-iOS
//
//  Created by Carlos Vidal on 30/08/2014.
//
//

#import "FWTMinimizableBaseViewController.h"
#import "FWTModalInteractiveTransition.h"

CGFloat const FWTMimizedViewHeight  = 48.f;

@interface FWTMinimizableBaseViewController () <UIBarPositioningDelegate>

@property (nonatomic, strong) UIViewController *minimizableController;
@property (nonatomic, strong) FWTModalInteractiveTransition *transitioner;
@property (nonatomic, strong) id modalCompletionBlock;

@property (nonatomic, strong) UIToolbar *minimizedView;
@property (nonatomic, strong) UIBarButtonItem *titleButtonItem;
@property (nonatomic, copy) NSString *buttonTitle;

@end

@implementation FWTMinimizableBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)presentModalController:(UIViewController*)controller withButtonTitle:(NSString *)title withCompletionBlock:(void (^)(void))completionBlock;
{
    [controller.view setBackgroundColor:[UIColor whiteColor]];
    self.buttonTitle = title;

    self.modalCompletionBlock = completionBlock;
    self.minimizableController = controller;

    [self _presentControllerWithCustomAnimation];
}

#pragma mark - Private methods
- (void)_minimizeController:(UIViewController*)controller
{
    self.minimizableController = controller;

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self setNeedsStatusBarAppearanceUpdate];

    CGRect finalFrame = self.view.superview.frame;
    finalFrame.size.height = CGRectGetHeight(finalFrame) - FWTMimizedViewHeight;
    CGFloat y = finalFrame.size.height;
    if (self.tabBarController)
    {
        y = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.tabBarController.tabBar.frame) - FWTMimizedViewHeight;
    }
    finalFrame = CGRectMake(0, y, CGRectGetWidth(self.minimizedView.frame), FWTMimizedViewHeight);

    [UIView animateWithDuration:0.6f
                          delay:0.25f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.minimizedView.frame = finalFrame;
                         self.titleButtonItem.title = self.buttonTitle;
                         self.minimizableController.view.alpha = 0;
                     } completion:nil];
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    self.minimizableController.view.alpha = 1;
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

        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [refSelf setNeedsStatusBarAppearanceUpdate];
    };

    return block;
}

- (UIView*)minimizedView
{
    if (self->_minimizedView == nil){
        self->_minimizedView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), FWTMimizedViewHeight)];

        UIBarButtonItem *firstFlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        self.titleButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(_maximizeController)];
        UIBarButtonItem *secondFlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        [self->_minimizedView setItems:@[firstFlexibleSpace, self.titleButtonItem, secondFlexibleSpace]];
    }

    if (self->_minimizedView.superview == nil){
        [self.view.superview addSubview:self->_minimizedView];
    }

    return self->_minimizedView;
}

@end
