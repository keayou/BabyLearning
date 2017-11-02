//
//  NSString+Utility.m
//  sogousearch
//
//  Created by Dragon on 17/4/25.
//  Copyright © 2017年 搜狗. All rights reserved.
//

#import "NSString+Utility.h"
#import <CommonCrypto/CommonDigest.h>
#import <CoreText/CoreText.h>

@implementation NSString (Utility)

- (NSString *)md5 {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconversion"
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
#pragma clang diagnostic pop
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)sha1 {
    
    //const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    //NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
    
}

- (NSString *)base64 {
    NSData *originData = [self dataUsingEncoding:NSASCIIStringEncoding];
    NSString *encodeResult = [originData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return encodeResult;
}

- (NSString *)encodeBase64 {
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:self options:0];
    NSString *decodeStr = [[NSString alloc] initWithData:decodeData encoding:NSASCIIStringEncoding];
    return decodeStr;
}


- (NSString *)stringByURLEncoded {
    // NSURL's stringByAddingPercentEscapesUsingEncoding: does not escape
    // some characters that should be escaped in URL parameters, like / and ?;
    // we'll use CFURL to force the encoding of those
    //
    // We'll explicitly leave spaces unescaped now, and replace them with +'s
    //
    // Reference: <a href="%5C%22http://www.ietf.org/rfc/rfc3986.txt%5C%22" target="\"_blank\"" onclick='\"return' checkurl(this)\"="" id="\"url_2\"">http://www.ietf.org/rfc/rfc3986.txt</a>
    
    NSString *resultStr = self;
    
    CFStringRef originalString = (__bridge CFStringRef) self;
    CFStringRef leaveUnescaped = CFSTR(" ");
    CFStringRef forceEscaped = CFSTR("!*'();:@&=+$,/?%#[]");
    
    CFStringRef escapedStr;
    escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                         originalString,
                                                         leaveUnescaped,
                                                         forceEscaped,
                                                         kCFStringEncodingUTF8);
    
    if( escapedStr )
    {
        NSMutableString *mutableStr = [NSMutableString stringWithString:(__bridge NSString *)escapedStr];
        CFRelease(escapedStr);
        
        // replace spaces with plusses
        [mutableStr replaceOccurrencesOfString:@" "
                                    withString:@"%20"
                                       options:0
                                         range:NSMakeRange(0, [mutableStr length])];
        resultStr = mutableStr;
    }
    return resultStr;

}

- (NSString *)stringByURLDeEncoded {
    NSString *result = self;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
    result = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                   (__bridge CFStringRef)self,
                                                                                                   CFSTR(""),
                                                                                                   kCFStringEncodingUTF8);
#else
    result = [self stringByRemovingPercentEncoding];
#endif
    return result;
}

- (id)jsonObject {
    
    id jsonObject = nil;
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];

    jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    return jsonObject;
}

- (CGSize)calculateSizeWithFont:(UIFont *)font
{
    return [self calculateSizeWithFont:font withMaxWidth:MAXFLOAT];
}

- (CGSize)calculateSizeWithFont:(UIFont *)font withMaxWidth:(CGFloat)maxWidth
{
    CGSize size;
    
    if ([[[UIDevice currentDevice] systemVersion] longLongValue] >= 7) {
        NSDictionary *attr = @{NSFontAttributeName : font};
        size = [self boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT)
                                  options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                               attributes:attr
                                  context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        size = [self sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)];
#pragma clang diagnostic pop
    }
    
    return size;
}

- (CGSize)calculateMultiSizeWithFont:(UIFont *)font withMaxWidth:(CGFloat)maxWidth
{
    return [self fitSize:self withFont:font withMaxWidth:maxWidth];
}


/**
 *  计算文本size
 *
 *  @param text     文本内容
 *  @param font     字体大小
 *  @param maxWidth 最大宽度
 *
 *  @return 文本size
 */
- (CGSize)fitSize:(NSString *)text withFont:(UIFont *)font withMaxWidth:(CGFloat)maxWidth
{
    NSDictionary *attributes = @{NSFontAttributeName : font};
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    CFIndex offset = 0, length;
    CGFloat height = 0;
    double  width  = 0;
    do {
        length = CTTypesetterSuggestLineBreak(typesetter, offset, maxWidth);
        CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(offset, length));
        CGFloat ascent, descent, leading;
        CGFloat lineW = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        if (width < lineW) {
            width = lineW;
        }
        
        CFRelease(line);
        
        offset += length;
        height += ascent + descent + leading + 1;
    } while (offset < [attString length]);
    
    CFRelease(typesetter);
    
    return CGSizeMake(width, height);
}


-(BOOL)isEmptyString
{
    return [self length] == 0;
}

+ (BOOL)isURL:(NSString*)urlString{
    
    //去掉空格
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //没有空格，有‘.’
    BOOL result = [urlString rangeOfString:@"://"].location != NSNotFound && [urlString rangeOfString:@"\\s" options:NSRegularExpressionSearch].location == NSNotFound && [urlString rangeOfString:@"."].location != NSNotFound;
    
    if (result == NO) {
        if ([NSURL URLWithString:[@"http://" stringByAppendingString:urlString]]){
            urlString = [@"http://" stringByAppendingString:urlString];
            
            result = YES;
        }
    }
    
    if (result) {
        NSString *host = [[NSURL URLWithString:urlString] host];
        if ([host rangeOfString:@"."].location == NSNotFound) {
            return NO;
        }
        //ip地址
        if ([[host stringByReplacingOccurrencesOfString:@"\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [host length])] length] == 0) {
            return YES;
        }
        //判断链接后缀是不是由纯字母组成
        NSString *com = [[host componentsSeparatedByString:@"."] lastObject];
        //        com = [com stringByReplacingOccurrencesOfString:@"[a-zA-Z]+" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [com length])];
        //        if ([com length] == 0) {
        //            return YES;
        //        }
        //取常用域名，非常用不识别
        return [self isContainSuffix:com];
    }
    return NO;
   
    
}

//取常用域名，非常用不识别
+(BOOL)isContainSuffix:(NSString *)suffix {
    NSSet *set = [NSSet setWithObjects:@"com",@"org",@"net",@"edu",@"gov",@"cn",@"hk",@"top",@"tel",@"cc",@"info",@"mobi",@"ad",@"ae",@"af",@"ag",@"ai",@"al",@"tw",@"az",@"uk",@"th",@"su",@"se",@"mn",@"gr",@"fr",@"de",@"ca",@"us",@"im",@"so",@"ph",@"jp",nil];
    if ([set containsObject:suffix]) {
        return YES;
    }
    return NO;
    
}

@end
