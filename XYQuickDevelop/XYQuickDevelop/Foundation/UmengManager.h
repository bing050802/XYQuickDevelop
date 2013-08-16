//
//  StatisticsManager.h
//  JoinShow
//
//  Created by Heaven on 13-8-7.
//  Copyright (c) 2013年 Heaven. All rights reserved.
//
// 目前用的是友盟
#import "XYQuickDevelop.h"


#ifdef UMENG
#import "MobClick.h"
#endif

#define Umeng_appkey @"aaaaaaaaaaaaaaaaaaaaaaaa"

#define Umeng_startWithAppkey [UmengManager startWithAppkey];
#define Umeng_beginLogPageView(a) [UmengManager beginLogPageView:a];
#define Umeng_endLogPageView(a) [UmengManager endLogPageView:a];
#define Umeng_eventAttributes(a, b) [UmengManager event:a attributes:b];
#define Umeng_checkUpdate [UmengManager checkUpdate];
#define Umeng_updateOnlineConfig  [UmengManager updateOnlineConfig];

@interface UmengManager : NSObject

//XY_SINGLETON(UmengManager)

+(void) startWithAppkey;
+(void) beginLogPageView:(NSString *)str;
+(void) endLogPageView:(NSString *)str;
+(void) event:(NSString *)eventID attributes:(NSDictionary *)dic;
+(void) checkUpdate;
+(NSString *) getConfigParams:(NSString *)key;
+(void) updateOnlineConfig;

@end
