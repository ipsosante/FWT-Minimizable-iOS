//
//  FWTModalInteractiveTransition.m
//  FWT-Retained-Modal-Transition-iOS
//
//  Created by Carlos Vidal on 29/08/2014.
//
//

#import "FWTModalInteractiveTransition.h"

CGFloat const FWTModalInteractiveTransitionModalTopMargin = 20.f;

@interface FWTModalInteractiveTransition()

@property (nonatomic, strong) UIViewController *modalController;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, strong) FWTFailOnEdgeGestureRecognizer *gesture;
@property (nonatomic, assign) BOOL isInteractive;
@property (nonatomic, assign)CGFloat panLocationStart;

@property (nonatomic, assign) CATransform3D tridimensionalTransform;
@property (nonatomic, assign) BOOL isDismiss;
@property (nonatomic, assign) BOOL bounces;

@property (nonatomic, assign) CGFloat behindViewScale;
@property (nonatomic, assign) CGFloat behindViewAlpha;

@property (nonatomic, strong) FWTModalInteractiveTransitionMinimizeBlock minimizeBlock;
@property (nonatomic, strong) FWTModalInteractiveTransitionDismissBlock dismissBlock;

@end

@implementation FWTModalInteractiveTransition

- (id)initWithModalViewController:(UIViewController*)modalViewController minimizeBlock:(FWTModalInteractiveTransitionMinimizeBlock)minimizeBlock dismissBlock:(FWTModalInteractiveTransitionDismissBlock)dismissBlock
{
    self = [super init];
    
    if (self != nil){
        NSNumber *flag = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
        NSAssert(flag.boolValue == NO, @"Please set the property UIViewControllerBasedStatusBarAppearance to \"NO\" in your project's plist file");
        
        self->_modalController = modalViewController;
        self->_bounces = YES;
        self->_behindViewScale = 0.90f;
        self->_behindViewAlpha = 0.75f;
        self->_minimizeBlock = minimizeBlock;
        self->_dismissBlock = dismissBlock;
        
        self->_gesture = [[FWTFailOnEdgeGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self->_gesture.delegate = self;
        [modalViewController.view addGestureRecognizer:self->_gesture];
    }
    
    return self;
}


- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.modalController.view.window];
    location = CGPointApplyAffineTransform(location, CGAffineTransformInvert(recognizer.view.transform));
    
    CGPoint velocity = [recognizer velocityInView:[self.modalController.view window]];
    velocity = CGPointApplyAffineTransform(velocity, CGAffineTransformInvert(recognizer.view.transform));
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        self.isInteractive = YES;
        self.panLocationStart = location.y;
        
        [self.modalController dismissViewControllerAnimated:YES completion:nil];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged){
        CGFloat animationRatio = (location.y - self.panLocationStart) / (CGRectGetHeight([self.modalController view].bounds));
        
        [self updateInteractiveTransition:animationRatio];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded){
        
        CGFloat velocityForSelectedDirection = velocity.y;
        
        if (velocityForSelectedDirection > 100){
            [self finishInteractiveTransition];
        }
        else{
            [self cancelInteractiveTransition];
        }
        
        self.isInteractive = NO;
    }
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    self.transitionContext = nil;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.8;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.isDismiss == false){
        if ([toViewController isKindOfClass:[UINavigationController class]]) {
            CGRect barFrame = toViewController.view.frame;
            barFrame.origin.y = -FWTModalInteractiveTransitionModalTopMargin;
            toViewController.view.frame = barFrame;
        }
        
        [[transitionContext containerView] addSubview:toViewController.view];
        
        toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        CGRect startRect = CGRectMake(0,
                                      CGRectGetHeight(toViewController.view.frame),
                                      CGRectGetWidth(toViewController.view.bounds),
                                      CGRectGetHeight(toViewController.view.bounds));
        
        CGPoint transformedPoint = CGPointApplyAffineTransform(startRect.origin, toViewController.view.transform);
        toViewController.view.frame = CGRectMake(transformedPoint.x, transformedPoint.y, startRect.size.width, startRect.size.height);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:0.7f
              initialSpringVelocity:0.8f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             fromViewController.view.transform = CGAffineTransformScale(fromViewController.view.transform, self.behindViewScale, self.behindViewScale);
                             fromViewController.view.alpha = self.behindViewAlpha;
                             
                             toViewController.view.frame = CGRectMake(0,44.f,
                                                                      CGRectGetWidth(toViewController.view.frame),
                                                                      CGRectGetHeight(toViewController.view.frame));
                             
                             
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    }
    else{
        [[transitionContext containerView] bringSubviewToFront:fromViewController.view];
        
        if ([self isIOS8] == false) {
            toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, self.behindViewScale, self.behindViewScale, 1);
        }
        
        toViewController.view.alpha = self.behindViewAlpha;
        
        CGRect endRect = CGRectMake(0,
                                    CGRectGetHeight(fromViewController.view.bounds),
                                    CGRectGetWidth(fromViewController.view.frame),
                                    CGRectGetHeight(fromViewController.view.frame));
        
        CGPoint transformedPoint = CGPointApplyAffineTransform(endRect.origin, fromViewController.view.transform);
        endRect = CGRectMake(transformedPoint.x, transformedPoint.y, endRect.size.width, endRect.size.height);
        
        self.dismissBlock(toViewController);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.f
             usingSpringWithDamping:0.7f
              initialSpringVelocity:0.8f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             CGFloat scaleBack = (1 / self.behindViewScale);
                             toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, scaleBack, scaleBack, 1);
                             toViewController.view.alpha = 1.0f;
                             fromViewController.view.frame = endRect;
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    }
}

#pragma mark - UIViewControllerContextTransitioning delegate methods
-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if ([self isIOS8] == false) {
        toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, self.behindViewScale, self.behindViewScale, 1);
    }
    
    self.tridimensionalTransform = toViewController.view.layer.transform;
    
    toViewController.view.alpha = self.behindViewAlpha;
    [[transitionContext containerView] bringSubviewToFront:fromViewController.view];
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    if (percentComplete < 0.07f){
        return;
    }
    
    if (!self.bounces && percentComplete < 0) {
        percentComplete = 0;
    }
    
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CATransform3D transform = CATransform3DMakeScale(
                                                     1 + (((1 / self.behindViewScale) - 1) * percentComplete),
                                                     1 + (((1 / self.behindViewScale) - 1) * percentComplete), 1);
    toViewController.view.layer.transform = CATransform3DConcat(self.tridimensionalTransform, transform);
    
    toViewController.view.alpha = self.behindViewAlpha + ((1 - self.behindViewAlpha) * percentComplete);
    
    CGRect updateRect = CGRectMake(0,
                                   (CGRectGetHeight(fromViewController.view.bounds) * percentComplete),
                                   CGRectGetWidth(fromViewController.view.frame),
                                   CGRectGetHeight(fromViewController.view.frame));
    
    CGPoint transformedPoint = CGPointApplyAffineTransform(updateRect.origin, fromViewController.view.transform);
    updateRect = CGRectMake(transformedPoint.x, transformedPoint.y, updateRect.size.width, updateRect.size.height);
    
    fromViewController.view.frame = updateRect;
}

- (void)finishInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endRect = CGRectMake(0,
                                CGRectGetHeight(fromViewController.view.bounds),
                                CGRectGetWidth(fromViewController.view.frame),
                                CGRectGetHeight(fromViewController.view.frame));
    
    CGPoint transformedPoint = CGPointApplyAffineTransform(endRect.origin, fromViewController.view.transform);
    endRect = CGRectMake(transformedPoint.x, transformedPoint.y, endRect.size.width, endRect.size.height);
    
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGFloat scaleBack = (1 / self.behindViewScale);
                         toViewController.view.layer.transform = CATransform3DScale(self.tridimensionalTransform, scaleBack, scaleBack, 1);
                         toViewController.view.alpha = 1.0f;
                         fromViewController.view.frame = endRect;
                     } completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                         self.minimizeBlock(self.modalController);
                         self.modalController = nil;
                     }];
}

- (void)cancelInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [UIView animateWithDuration:0.4f
                          delay:0.f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         toViewController.view.layer.transform = self.tridimensionalTransform;
                         toViewController.view.alpha = self.behindViewAlpha;
                         
                         fromViewController.view.frame = CGRectMake(0,CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + FWTModalInteractiveTransitionModalTopMargin,
                                                                    CGRectGetWidth(fromViewController.view.frame),
                                                                    CGRectGetHeight(fromViewController.view.frame));
                         
                         
                     } completion:^(BOOL finished) {
                         [transitionContext completeTransition:NO];
                     }];
}

#pragma mark - UIViewControllerAnimatedTransitioningDelegate Methods
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isDismiss = NO;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isDismiss = YES;
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    if (self.isInteractive == true){
        self.isDismiss = YES;
        return self;
    }
    
    return nil;
}

#pragma mark - Utils
- (BOOL)isIOS8
{
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"8.0" options: NSNumericSearch];
    
    if (order == NSOrderedSame || order == NSOrderedDescending){
        return YES;
    }
    
    return NO;
}

@end

// Custom gesture recognizer
@interface FWTFailOnEdgeGestureRecognizer ()

@property (nonatomic, strong) NSNumber *isFail;

@end

@implementation FWTFailOnEdgeGestureRecognizer

- (void)dealloc
{
    self->_scrollview = nil;
    self->_isFail = nil;
}

- (void)reset
{
    [super reset];
    
    self.isFail = nil;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (!self.scrollview) {
        return;
    }
    
    if (self.state == UIGestureRecognizerStateFailed){
        return;
    }
    
    CGPoint nowPoint = [touches.anyObject locationInView:self.view];
    CGPoint prevPoint = [touches.anyObject previousLocationInView:self.view];
    
    if (self.isFail){
        if (self.isFail.boolValue){
            self.state = UIGestureRecognizerStateFailed;
        }
        
        return;
    }
    
    if (nowPoint.y > prevPoint.y && self.scrollview.contentOffset.y <= 0){
        self.isFail = @NO;
    }
    else if (self.scrollview.contentOffset.y >= 0){
        self.state = UIGestureRecognizerStateFailed;
        self.isFail = @YES;
    }
    else{
        self.isFail = @NO;
    }
    
}

@end
