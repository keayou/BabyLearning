//
//  KEConstantsMacro.h
//  BabyLearning
//
//  Created by fk on 2017/10/28.
//  Copyright © 2017年 fk. All rights reserved.
//

#ifndef KEConstantsMacro_h
#define KEConstantsMacro_h

/********************* KEY *********************/

#define Bugly_APPID   @"981be0a270"

#define BAIDU_TRANSLATE_APPID   @"20171031000091926"
#define BAIDU_TRANSLATE_KEY     @"U4dx64bmLXcC8h_cWzwU" //密钥

/********************* KEY *********************/


#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#define IS_EMPTY_STR(str) !(str!=nil&&str.length>0)

#define IS_NOEMPTY_STR(str) (str!=nil&&[str isKindOfClass:[NSString class]]&&str.length>0)
#define IS_NOEMPTY_ARRAY(array) (array!=nil&&[array isKindOfClass:[NSArray class]]&&array.count>0)
#define IS_NOEMPTY_DIC(dic) (dic!=nil&&[dic isKindOfClass:[NSDictionary class]]&&dic.count>0)


#define AppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define AppBuild [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define AppName [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)


#define MIN_Scale 1.0/[UIScreen mainScreen].scale



#endif /* KEConstantsMacro_h */
