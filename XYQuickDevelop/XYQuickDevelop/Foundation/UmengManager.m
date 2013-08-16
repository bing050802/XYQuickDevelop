//
//  StatisticsManager.m
//  JoinShow
//
//  Created by Heaven on 13-8-7.
//  Copyright (c) 2013年 Heaven. All rights reserved.
//

#import "UmengManager.h"

@implementation UmengManager

//DEF_SINGLETON(UmengManager)

+(void)startWithAppkey{
#ifdef UMENG
    [MobClick startWithAppkey:Umeng_appkey];
#endif
}

+(void)beginLogPageView:(NSString *)str{
#ifdef UMENG
    [MobClick beginLogPageView:str];
#endif
}

+(void)endLogPageView:(NSString *)str{
#ifdef UMENG
    [MobClick endLogPageView:str];
#endif
}

+(void)event:(NSString *)eventID attributes:(NSDictionary *)dic{
#ifdef UMENG
    [MobClick event:eventID attributes:dic];
#endif
}

+(void)checkUpdate{
#ifdef UMENG
    [MobClick checkUpdate];
#endif
}

+(NSString *) getConfigParams:(NSString *)key{
#ifdef UMENG
    return [MobClick getConfigParams:key];
#else
    return nil;
#endif
}

+(void) updateOnlineConfig{
#ifdef UMENG
    [MobClick updateOnlineConfig];
#endif
}

@end
