//
//  KEMainViewController.m
//  BabyLearning
//
//  Created by fk on 2017/10/27.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "KEMainViewController.h"
#import "MobileNet.h"
#import "UIImage+Utils.h"

@interface KEMainViewController ()

@end

@implementation KEMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *result = [self predictImageScene:[UIImage imageNamed:@"timg"]];
    
    NSLog(@"%@",result);
    
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


@end
