//
//  SDWebDataManager.h
//  SDWebData
//
//  Created by stm on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDDataCacheManager.h"
#import "SDWebDataDownloader.h"

@protocol SDWebDataManagerDelegate;
@interface SDWebDataManager : NSObject<SDDataCacheManagerDelegate,SDWebDataDownloaderDelegate> 
{
	NSMutableArray *delegates;
    NSMutableArray *contexts;
    NSMutableArray *downloaders;
    NSMutableDictionary *downloaderForURL;
    NSMutableArray *failedURLs;
    
    NSInteger MaxConcurrentCount;
}
@property (nonatomic, assign) NSInteger MaxConcurrentCount;

+ (id)sharedManager;

/**
 post方法请求(支持文件上传)
 info中请求key只能为string类型,object只支持如下类型:
 NSString,NSNumber,NSData,NSUrl(本地文件上传).
 请求头属性Content-Type:multipart/form-data
 **/

- (void)uploadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate postInfo:(NSDictionary *)info context:(id)context;

/**
 url,下载的目标地址;
 delegate,下载的代理;
 context,可设置一个标识对象,在回调中会返回该context,默认为nil;
 refreshCache=YES,忽略本地缓存,重新发起请求,默认为NO;
 retryFailed=YES,如果曾经下载失败,再次下载,默认为NO;
 lowPriority=YES,低优先级(与UI线程相比),默认为NO.
 **/

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate;
- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate context:(id)context;
- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate context:(id)context refreshCache:(BOOL)refreshCache;
- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate context:(id)context refreshCache:(BOOL)refreshCache retryFailed:(BOOL)retryFailed;
- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate context:(id)context refreshCache:(BOOL)refreshCache retryFailed:(BOOL)retryFailed lowPriority:(BOOL)lowPriority;

//清理退出delegate所有下载任务
- (void)cancelForDelegate:(id<SDWebDataManagerDelegate>)delegate;

@end


@protocol SDWebDataManagerDelegate <NSObject>

@optional
- (void)webDataFinishWithData:(NSData *)aData context:(id)context isCache:(BOOL)isCache;
- (void)webDataFailWithError:(NSError *)error context:(id)context;

@end