//
//  KETranslateRequest.h
//  BabyLearning
//
//  Created by fk on 2017/10/31.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KETranslateRequest : NSObject

+ (void)requestTranslation:(NSString *)queryText completeHandler:(void(^)(NSString *result))completeBlock;

@end
