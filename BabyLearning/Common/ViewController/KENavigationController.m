//
//  KENavigationController.m
//  BabyLearning
//
//  Created by fk on 2017/10/27.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "KENavigationController.h"
#import "KEBaseViewController.h"

@interface KENavigationController ()<UINavigationControllerDelegate>

@end

@implementation KENavigationController


- (void)viewDidLoad {
    [super viewDidLoad];
    __weak KENavigationController *weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
        self.interactivePopGestureRecognizer.enabled = NO;
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *reVC =  [super popViewControllerAnimated:animated];
    return reVC;
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if (self.presentedViewController) {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{
    
    // Enable the gesture again once the new controller is shown
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        if (navigationController.viewControllers.count < 2) {
            self.interactivePopGestureRecognizer.enabled = NO;
        }else{
            if ([viewController isKindOfClass:[KEBaseViewController class]]) {
                KEBaseViewController *vc2 = (KEBaseViewController *)viewController;
                if (vc2.swipeDisabled) {
                    self.interactivePopGestureRecognizer.enabled = NO;
                } else {
                    self.interactivePopGestureRecognizer.enabled = YES;
                }
            } else {
                self.interactivePopGestureRecognizer.enabled = YES;
            }
        }
    }
}

@end
