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

@interface KEMainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *curPredicted;

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@property (nonatomic, strong) KEVNCoreMLRequestHandler *vnRequest;

@end

@implementation KEMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfiguration];
    
    [self viewSetup];
    [self.view bringSubviewToFront:self.curPredicted];

    [self loopCoreMLUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.arScnView.session runWithConfiguration:self.arConfiguration];
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
    _arScnView.preferredFramesPerSecond = 60;
    _arScnView.autoenablesDefaultLighting = YES;// Enable Default Lighting - makes the 3D text a bit poppier.
    [self.view addSubview:_arScnView];
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
        NSString *result = [NSString stringWithFormat:@"%@ -- %f",firstOb.identifier,firstOb.confidence];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.curPredicted.text = result;
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


@end
