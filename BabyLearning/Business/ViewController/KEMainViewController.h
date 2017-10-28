//
//  KEMainViewController.h
//  BabyLearning
//
//  Created by fk on 2017/10/27.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "KEBaseViewController.h"

#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>


@interface KEMainViewController : KEBaseViewController<ARSCNViewDelegate,ARSessionDelegate>

@property (nonatomic, strong) ARSCNView *arScnView;
@property (nonatomic, strong) ARWorldTrackingConfiguration *arConfiguration;
@property (nonatomic, strong) ARSession *arSesion;


@end
