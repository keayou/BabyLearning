//
//  KEBaseNetWork.m
//  BabyLearning
//
//  Created by fk on 2017/10/31.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "KEBaseNetWork.h"
#import "AFNetworking.h"


static NSTimeInterval timeoutInterval = 60.0;

@implementation KEBaseNetWork

+ (AFHTTPSessionManager *)manager {
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = timeoutInterval;
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    NSMutableSet *newSet = [NSMutableSet set];
    newSet.set = manager.responseSerializer.acceptableContentTypes;
    [newSet addObject:@"text/html"];
    [newSet addObject:@"text/plain"];
    manager.responseSerializer.acceptableContentTypes = newSet;
    
    return manager;
}

+ (void)getWithPath:(NSString *)path params:(NSDictionary *)params block:(KENetworkReturnBlock)block {
    
    NSURL *URL = [NSURL URLWithString:path];
    
    AFHTTPSessionManager *manager = [self manager];
    [manager GET:URL.absoluteString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        if (block) block(YES, responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (block) block(NO, nil);
        [manager invalidateSessionCancelingTasks:YES];
    }];
}


+ (void)postWithPath:(NSString *)path params:(NSDictionary *)params block:(KENetworkReturnBlock)block {
    NSURL *URL = [NSURL URLWithString:path];
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:URL.absoluteString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        if (block) block(YES, responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (block) block(NO, nil);
        [manager invalidateSessionCancelingTasks:YES];
    }];
}

@end
