//
//  NSString+Utility.h
//  sogousearch
//
//  Created by Dragon on 17/4/25.
//  Copyright © 2017年 搜狗. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Utility)

- (NSString *)md5;
- (NSString *)sha1;

- (NSString *)base64;
- (NSString *)encodeBase64;

- (NSString *)stringByURLEncoded;
- (NSString *)stringByURLDeEncoded;

- (id)jsonObject;

- (CGSize)calculateSizeWithFont:(UIFont *)font;
- (CGSize)calculateSizeWithFont:(UIFont *)font withMaxWidth:(CGFloat)maxWidth;
/**
 *  计算多行文本size
 *
 *  @param font     字体大小
 *  @param maxWidth 最大宽度
 *
 *  @return 文本size
 */
- (CGSize)calculateMultiSizeWithFont:(UIFont *)font withMaxWidth:(CGFloat)maxWidth;
- (BOOL)isEmptyString;


//判断是否是URL
+ (BOOL)isURL:(NSString*)urlString;

@end
