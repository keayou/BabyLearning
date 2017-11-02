//
//  KEVNCoreMLRequestHandler.m
//  BabyLearning
//
//  Created by 粥粥的小笨猪 on 2017/10/28.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "KEVNCoreMLRequestHandler.h"
#import <Vision/Vision.h>

#import "MobileNet.h"
#import "Inceptionv3.h"

#import "UIImage+Utils.h"

@interface KEVNCoreMLRequestHandler ()

@property (nonatomic, strong) VNCoreMLRequest *vnRequest;

@property (nonatomic, copy) KEVNRequestCompletionHandler completionHandler;

@end

@implementation KEVNCoreMLRequestHandler


- (instancetype)initWithcompletionHandler:(KEVNRequestCompletionHandler)completionHandler {
    self = [super init];
    if (self) {
        _completionHandler = completionHandler;
    }
    return self;
}

- (void)performVNCoreMLRequest:(CIImage *)ciImage {
    
    VNImageRequestHandler *vnHandler = [[VNImageRequestHandler alloc] initWithCIImage:ciImage options:@{}];
    [vnHandler performRequests:@[self.vnRequest] error:nil];
}

- (void)classificationCompleteHandler:(VNRequest *)request error:(NSError *)error {
    
    if (error != nil) {
        NSLog(@"classification ERROR : %@",error);
        return;
    }
    
    NSArray *observations = request.results;
    if (_completionHandler) {
        _completionHandler(observations);
        return;
    }
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


#pragma mark - lazy init
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
