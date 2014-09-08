//
//  FWTMinimizableViewController.h
//  FWT-Retained-Modal-Transition-iOS
//
//  Created by Carlos Vidal on 30/08/2014.
//
//

#import <UIKit/UIKit.h>

@interface FWTMinimizableBaseViewController : UIViewController

@property (nonatomic, strong) UIViewController *minimizableController;

- (void)presentModalController:(UIViewController*)controller withCompletionBlock:(void (^)(void))completionBlock;

@end
