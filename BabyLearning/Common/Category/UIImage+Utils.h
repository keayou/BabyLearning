//
//  UIImage+Utils.h
//  MLDemo
//
//  Created by fk on 2017/10/20.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)


- (UIImage *)scaleToSize:(CGSize)size;
- (CVPixelBufferRef)pixelBufferFromCGImage:(UIImage *)image;

@end
