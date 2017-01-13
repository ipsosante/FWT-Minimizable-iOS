//
//  FWTMinimizableViewController.h
//  FWT-Retained-Modal-Transition-iOS
//
//  Created by Carlos Vidal on 30/08/2014.
//
//

#import <UIKit/UIKit.h>

@interface FWTMinimizableBaseViewController : UIViewController

- (void)presentModalController:(UIViewController*)controller withButtonTitle:(NSString *)title withCompletionBlock:(void (^)(void))completionBlock;

@end
