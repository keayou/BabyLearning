//
//  KEMotionManager.h
//  BabyLearning
//
//  Created by fk on 2017/10/31.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KEMotionManagerDelegate <NSObject>

- (void)deviceMotionStable;

@end

@interface KEMotionManager : NSObject

@property (nonatomic, weak) id<KEMotionManagerDelegate> delegate;

- (void)startMotionObserving;

- (void)stopMotionObserving;

@end
