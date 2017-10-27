//
//  KEBaseViewController.m
//  BabyLearning
//
//  Created by fk on 2017/10/27.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "KEBaseViewController.h"

@interface KEBaseViewController ()

@end

@implementation KEBaseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:self.isNavigationBarHidden animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:self.isStatusBarHidden withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    _statusBarHidden = statusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    [UIApplication sharedApplication].statusBarStyle = statusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
    
}

- (BOOL)prefersStatusBarHidden {
    if (self.isStatusBarHidden) {
        return YES;
    }
    return NO;
}




@end
