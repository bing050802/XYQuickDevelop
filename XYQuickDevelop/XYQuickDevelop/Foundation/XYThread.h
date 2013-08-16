//
//  XYThread.h
//  TWP_SkyBookShelf
//
//  Created by Heaven on 13-7-10.
//  模仿 bee Framework
//

#pragma mark -

#undef	FOREGROUND_BEGIN
#undef	FOREGROUND_BEGIN_(x)
#undef	FOREGROUND_COMMIT
#undef	BACKGROUND_BEGIN
#undef	BACKGROUND_BEGIN_(x)
#undef	BACKGROUND_COMMIT

#define FOREGROUND_BEGIN		[XYGCD enqueueForeground:^{
#define FOREGROUND_BEGIN_(x)	[XYGCD enqueueForegroundWithDelay:(dispatch_time_t)x block:^{
#define FOREGROUND_COMMIT		}];

#define BACKGROUND_BEGIN		[XYGCD enqueueBackground:^{
#define BACKGROUND_BEGIN_(x)	[XYGCD enqueueBackgroundWithDelay:(dispatch_time_t)x block:^{
#define BACKGROUND_COMMIT		}];

#pragma mark -

#import "XYQuickDevelop.h"


@interface XYGCD : NSObject

+ (dispatch_queue_t)foreQueue;
+ (dispatch_queue_t)backQueue;

+ (void)enqueueForeground:(dispatch_block_t)block;
+ (void)enqueueBackground:(dispatch_block_t)block;
+ (void)enqueueForegroundWithDelay:(dispatch_time_t)ms block:(dispatch_block_t)block;
+ (void)enqueueBackgroundWithDelay:(dispatch_time_t)ms block:(dispatch_block_t)block;

@end
