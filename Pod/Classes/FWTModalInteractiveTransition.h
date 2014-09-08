//
//  FWTModalInteractiveTransition.h
//  FWT-Retained-Modal-Transition-iOS
//
//  Created by Carlos Vidal on 29/08/2014.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef void (^FWTModalInteractiveTransitionMinimizeBlock)(UIViewController *viewController);
typedef void (^FWTModalInteractiveTransitionDismissBlock)(UIViewController *viewController);

@interface FWTFailOnEdgeGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, strong) UIScrollView *scrollview;

@end

@interface FWTModalInteractiveTransition : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning,
UIViewControllerTransitioningDelegate,
UIGestureRecognizerDelegate>

- (id)initWithModalViewController:(UIViewController*)modalViewController minimizeBlock:(FWTModalInteractiveTransitionMinimizeBlock)minimizeBlock dismissBlock:(FWTModalInteractiveTransitionDismissBlock)dismissBlock;

@end
