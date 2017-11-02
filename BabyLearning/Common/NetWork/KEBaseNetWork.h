//
//  KEBaseNetWork.h
//  BabyLearning
//
//  Created by fk on 2017/10/31.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^KENetworkReturnBlock)(BOOL isSuccess, NSDictionary *json);

typedef void(^KENetworkReturnTaskBlock)(BOOL isSuccess, NSDictionary *json, NSURLSessionTask *task);

@interface KEBaseNetWork : NSObject


+ (void)getWithPath:(NSString *)path
             params:(NSDictionary *)params
              block:(KENetworkReturnBlock)block;



+ (void)postWithPath:(NSString *)path
              params:(NSDictionary *)params
               block:(KENetworkReturnBlock)block;


@end
