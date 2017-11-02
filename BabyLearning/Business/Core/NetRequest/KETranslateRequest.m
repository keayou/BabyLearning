//
//  KETranslateRequest.m
//  BabyLearning
//
//  Created by fk on 2017/10/31.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "KETranslateRequest.h"
#import "NSString+Utility.h"
#import "KEBaseNetWork.h"

@implementation KETranslateRequest

+ (void)requestTranslation:(NSString *)queryText completeHandler:(void(^)(NSString *result))completeBlock {
//    queryText = @"Origin Text";

    NSString *salt = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSinceReferenceDate]*1000];
    NSString *signOrigin = [NSString stringWithFormat:@"%@%@%@%@",BAIDU_TRANSLATE_APPID,queryText,salt,BAIDU_TRANSLATE_KEY];
    
    NSString *sign = [signOrigin md5];
    NSDictionary *requestDict = @{
                                  @"q":queryText,
                                  @"from":@"auto",
                                  @"to":@"zh",
                                  @"appid":BAIDU_TRANSLATE_APPID,
                                  @"salt":salt,
                                  @"sign":sign
                                  };
    [KEBaseNetWork postWithPath:KE_TRANSLATE_URL params:requestDict block:^(BOOL isSuccess, NSDictionary *json) {
        if (isSuccess && !json[@"error_code"]) {
            NSLog(@"KEBaseNetWork isSuccess");
            
            NSArray *transResult = json[@"trans_result"];
            
            NSDictionary *dict = transResult[0];
            
            NSString *dst = dict [@"dst"];
            
            if (completeBlock) {
                completeBlock([NSString stringWithFormat:@"%@--%@",queryText,dst]);
            }
            
        } else {
            NSLog(@"KEBaseNetWork failed");
        }
    }];
}

@end
