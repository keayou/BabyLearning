//
//  KEBaseViewController.h
//  BabyLearning
//
//  Created by fk on 2017/10/27.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KEBaseViewController : UIViewController

@property (nonatomic, assign, getter=isNavigationBarHidden) BOOL navigationBarHidden;
@property (nonatomic, assign, getter=isStatusBarHidden) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL swipeDisabled;

@property (nonatomic, assign) UIStatusBarStyle  statusBarStyle;

@end
