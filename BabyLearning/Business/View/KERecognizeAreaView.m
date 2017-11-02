//
//  KERecognizeAreaView.m
//  BabyLearning
//
//  Created by fk on 2017/10/31.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "KERecognizeAreaView.h"

@implementation KERecognizeAreaView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

    
    CGSize sizeRetangle = CGSizeMake(224, 224);

    CGFloat edge = (self.bounds.size.width - sizeRetangle.width) / 2;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat YMinRetangle = (self.frame.size.height - sizeRetangle.height) / 2.0;

    //非扫码区域半透明
    {
        //设置非识别区域颜色
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.8);

        //扫码区域上面填充
        CGRect rect = CGRectMake(0, 0, self.frame.size.width, YMinRetangle);
        CGContextFillRect(context, rect);

        //扫码区域左边填充
        rect = CGRectMake(0, YMinRetangle, edge, sizeRetangle.height);
        CGContextFillRect(context, rect);

        //扫码区域右边填充
        rect = CGRectMake(edge + sizeRetangle.width, YMinRetangle, edge, sizeRetangle.height);
        CGContextFillRect(context, rect);

        //扫码区域下面填充
        rect = CGRectMake(0, YMinRetangle + sizeRetangle.height, self.frame.size.width,self.frame.size.height - YMinRetangle - sizeRetangle.height);
        CGContextFillRect(context, rect);
        //执行绘画
        CGContextStrokePath(context);
    }

    {
        //中间画矩形(正方形)
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        CGContextSetLineWidth(context, 1);

        CGContextAddRect(context, CGRectMake(edge, YMinRetangle, sizeRetangle.width, sizeRetangle.height));

        CGContextStrokePath(context);
    }
    
}

@end
