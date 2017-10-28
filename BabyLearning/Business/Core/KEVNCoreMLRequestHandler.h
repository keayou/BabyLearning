//
//  KEVNCoreMLRequestHandler.h
//  BabyLearning
//
//  Created by 粥粥的小笨猪 on 2017/10/28.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KEVNRequestCompletionHandler)(NSArray *results);


@interface KEVNCoreMLRequestHandler : NSObject

- (instancetype)initWithcompletionHandler:(KEVNRequestCompletionHandler)completionHandler;

- (void)performVNCoreMLRequest:(CIImage *)ciImage;



@end
