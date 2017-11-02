//
//  KEMotionManager.m
//  BabyLearning
//
//  Created by fk on 2017/10/31.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "KEMotionManager.h"
#import <CoreMotion/CoreMotion.h>

@interface KEMotionManager ()
{
    double _attitudeRoll;
    double _attitudePitch;
    double _attitudeYaw;
    double _accelerationX;
    double _accelerationY;
    double _accelerationZ;
}
@property (nonatomic, strong) CMMotionManager *mgr;

@end


@implementation KEMotionManager

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _mgr = [[CMMotionManager alloc] init];
        _mgr.deviceMotionUpdateInterval = 0.8;
    }
    return self;
}
- (void)startMotionObserving {
    
    [self pushDeviceMotion];
}

- (void)stopMotionObserving {
    
    [self.mgr stopDeviceMotionUpdates];
}

#pragma mark - 获取设备运动信息
- (void)pushDeviceMotion {
    _attitudeRoll = 10;
    _attitudePitch = 10;
    _attitudePitch = 10;
    _accelerationX = 10;
    _accelerationY = 10;
    _accelerationZ = 10;
    //设备运动
    if (_mgr.deviceMotionAvailable) {
        __weak __typeof(self)weakSelf = self;

        [_mgr startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError * error) {
            if (!error) {
                
                CMAcceleration acceleration = motion.gravity;
                
                if (fabs(_accelerationX - acceleration.x) < 0.005 && fabs(_accelerationY - acceleration.y) < 0.005 && fabs(_accelerationZ - acceleration.z) < 0.005) {
                    //                    [weakSelf stopMotionObserving];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if ([weakSelf.delegate respondsToSelector:@selector(deviceMotionStable)]) {
                            [weakSelf.delegate deviceMotionStable];
                        }
                    });
                    
                    _accelerationX = 10;
                    _accelerationY = 10;
                    _accelerationZ = 10;
                }
                _accelerationX = acceleration.x;
                _accelerationY = acceleration.y;
                _accelerationZ = acceleration.z;
                
            }
        }];
    }
}
@end
