//
//  NSObject+XY.h
//  JoinShow
//
//  Created by Heaven on 13-7-31.
//  Copyright (c) 2013年 Heaven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (XY)
#pragma mark -todo 拆分参数
// 目前只支持添加一个随机时间执行
// 不用时需要移除
-(void) performSelector:(SEL)aSelector target:(id)target mark:(id)mark afterDelay:(NSTimeInterval(^)(void))aBlockTime loop:(BOOL)loop isRunNow:(BOOL)now;

-(void) performBlock:(void(^)(void))aBlock mark:(id)mark afterDelay:(NSTimeInterval(^)(void))aBlockTime loop:(BOOL)loop isRunNow:(BOOL)now;
//-(void) removePerformWithMark:(NSString *)mark;
-(void) removePerformRandomDelay;
@end
