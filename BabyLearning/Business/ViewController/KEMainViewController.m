//
//  KEMainViewController.m
//  BabyLearning
//
//  Created by fk on 2017/10/27.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "KEMainViewController.h"

#import <Vision/Vision.h>

#import "KEVNCoreMLRequestHandler.h"
#import "KERecognizeAreaView.h"
#import "KEMotionManager.h"
#import "KETranslateRequest.h"

@interface KEMainViewController ()<KEMotionManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *curPredicted;
@property (weak, nonatomic) IBOutlet UILabel *transLabel;

@property (nonatomic, strong) NSString *predictedStr;

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@property (nonatomic, strong) KEVNCoreMLRequestHandler *vnRequest;
@property (nonatomic, strong) KEMotionManager *motionManager;

@end

@implementation KEMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfiguration];
    
    [self viewSetup];
    [self.view bringSubviewToFront:self.curPredicted];
    [self.view bringSubviewToFront:self.transLabel];

    [self loopCoreMLUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.arScnView.session runWithConfiguration:self.arConfiguration];
    [self.motionManager startMotionObserving];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.arScnView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initConfiguration {
    _serialQueue = dispatch_queue_create("KE_MainVC_SERIAL_QUEUE", DISPATCH_QUEUE_SERIAL);
    self.statusBarHidden = YES;
}

- (void)viewSetup {
    _arScnView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    _arScnView.delegate = self;
    _arScnView.session = self.arSesion;
    
    _arScnView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
    _arScnView.automaticallyUpdatesLighting = NO;
    _arScnView.autoenablesDefaultLighting = YES;// Enable Default Lighting - makes the 3D text a bit poppier.
    _arScnView.preferredFramesPerSecond = 60;
    SCNCamera *camera = _arScnView.pointOfView.camera;
    if (camera) {
        camera.wantsHDR = YES;
        camera.wantsExposureAdaptation = YES;
        camera.exposureOffset = -1;
        camera.minimumExposure = -1;
        camera.maximumExposure = 3;
    }
    [self.view addSubview:_arScnView];
    
    KERecognizeAreaView *maskView = [[KERecognizeAreaView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:maskView];

}

#pragma mark - KEMotionManagerDelegate
- (void)deviceMotionStable {
    if (IS_NOEMPTY_STR(_predictedStr)) {
        [KETranslateRequest requestTranslation:_predictedStr completeHandler:^(NSString *result) {
            _transLabel.text = result;
        }];
    }

    NSLog(@"-----------------------");
}

#pragma mark - private method
- (void)loopCoreMLUpdate {
    dispatch_async(_serialQueue, ^{
       
        [self updateCoreML];
        
        [self loopCoreMLUpdate];
    });
}

- (void)updateCoreML {
    CVPixelBufferRef pixbuff = self.arScnView.session.currentFrame.capturedImage;
    if (!pixbuff) return;
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixbuff];
    
    [self.vnRequest performVNCoreMLRequest:ciImage];
}

- (void)classificationCompleteHandler:(NSArray *)observations {
    
    if (observations.count > 0) {
        VNClassificationObservation *firstOb = observations[0];
        
        NSString *originStr = firstOb.identifier;
        NSArray *identifierList = [originStr componentsSeparatedByString:@","];
        
        NSString *result = [NSString stringWithFormat:@"%@ -- %f",identifierList[0],firstOb.confidence];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.curPredicted.text = result;
            _predictedStr = identifierList[0];
        });
    }
}

#pragma mark - lazy init
- (ARSession *)arSesion {
    if (_arSesion) return _arSesion;

    _arSesion = [[ARSession alloc] init];
    _arSesion.delegate = self;
    return _arSesion;
}

- (ARWorldTrackingConfiguration *)arConfiguration {
    if (_arConfiguration) return _arConfiguration;

    _arConfiguration = [[ARWorldTrackingConfiguration alloc] init];
    _arConfiguration.lightEstimationEnabled = YES;
    return _arConfiguration;
}

- (KEVNCoreMLRequestHandler *)vnRequest {
    if (_vnRequest) return _vnRequest;

    WS(weakSelf);
    _vnRequest = [[KEVNCoreMLRequestHandler alloc] initWithcompletionHandler:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf classificationCompleteHandler:results];
        });
    }];
    return _vnRequest;
}

- (KEMotionManager *)motionManager {
    if (_motionManager) return _motionManager;
    _motionManager = [[KEMotionManager alloc] init];
    _motionManager.delegate = self;
    return _motionManager;
}
@end
