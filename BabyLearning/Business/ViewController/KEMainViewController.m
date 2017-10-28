//
//  KEMainViewController.m
//  BabyLearning
//
//  Created by fk on 2017/10/27.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "KEMainViewController.h"

#import <Vision/Vision.h>

#import "MobileNet.h"
#import "Inceptionv3.h"

#import "UIImage+Utils.h"



@interface KEMainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *curPredicted;

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@property (nonatomic, strong) VNCoreMLRequest *vnRequest;

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

- (NSString *)predictImageScene:(UIImage *)image {
    
    MobileNet *model = [[MobileNet alloc] init];
    
    UIImage *scaledImage = [image scaleToSize:CGSizeMake(224, 224)];
    CVPixelBufferRef buffer = [image pixelBufferFromCGImage:scaledImage];
    
    MobileNetInput *input = [[MobileNetInput alloc] initWithImage:buffer];
    
    NSError *error;
    MobileNetOutput *output = [model predictionFromFeatures:input error:&error];
    
    return output.classLabel;
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
    
    VNImageRequestHandler *vnHandler = [[VNImageRequestHandler alloc] initWithCIImage:ciImage options:@{}];
    [vnHandler performRequests:@[self.vnRequest] error:nil];
}

- (void)classificationCompleteHandler:(VNRequest *)request error:(NSError *)error {
    
    if (error != nil) {
        NSLog(@"classification ERROR : %@",error);
        return;
    }
    
    NSArray *observations = request.results;
    
    if (observations.count > 0) {
        VNClassificationObservation *firstOb = observations[0];
        
        NSString *result = [NSString stringWithFormat:@"%@ -- %f",firstOb.identifier,firstOb.confidence];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.curPredicted.text = result;
        });
    }
    
    
//    NSLog(@"%ld",observations.count);
    
    
    
    
//    // Get Classifications
//    let classifications = observations[0...1] // top 2 results
//    .flatMap({ $0 as? VNClassificationObservation })
//    .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))" })
//    .joined(separator: "\n")
//
//
//    DispatchQueue.main.async {
//        // Print Classifications
//        print(classifications)
//        print("--")
//
//        // Display Debug Text on screen
//        var debugText:String = ""
//        debugText += classifications
//        self.debugTextView.text = debugText
//
//        // Store the latest prediction
//        var objectName:String = "…"
//        objectName = classifications.components(separatedBy: "-")[0]
//        objectName = objectName.components(separatedBy: ",")[0]
//        self.latestPrediction = objectName
//
//    }
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

- (VNCoreMLRequest *)vnRequest {
    if (_vnRequest) return _vnRequest;

//    MobileNet *model = [[MobileNet alloc] init];
    Inceptionv3 *v3model = [[Inceptionv3 alloc] init];
    
    NSError *error = nil;;
    VNCoreMLModel *mlModel = [VNCoreMLModel modelForMLModel:v3model.model error:&error];
    
    _vnRequest = [[VNCoreMLRequest alloc] initWithModel:mlModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        [self classificationCompleteHandler:request error:error];
    }];
    return _vnRequest;
    
}
@end
