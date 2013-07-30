//
//  SDDataCache.h
//  SDWebData
//
//  Created by stm on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SDDataCacheManagerDelegate;
@interface SDDataCacheManager : NSObject 
{
    NSMutableDictionary *memCache;
    NSMutableArray      *memCacheKeyArray;
    unsigned long long  cacheMaxCacheAge;
    unsigned long long  memCacheMaxSize;

    NSOperationQueue *cacheInQueue, *cacheOutQueue;
}
//硬盘上缓存保留的时候,单位为秒,默认为1周(60*60*24*7)
@property (nonatomic, assign) unsigned long long cacheMaxCacheAge;
//内存中缓存数据的大小,单位为B,默认为2M(2*1024*1024)
@property (nonatomic, assign) unsigned long long  memCacheMaxSize;

@property (nonatomic, copy)     NSString *diskCachePath;

+ (SDDataCacheManager *)sharedManager;

//存储data
- (void)storeData:(NSData *)aData forKey:(NSString *)key;
- (void)storeData:(NSData *)aData forKey:(NSString *)key toDisk:(BOOL)toDisk;

//得到指定的data
- (NSData *)dataFromKey:(NSString *)key;
- (NSData *)dataFromKey:(NSString *)key fromDisk:(BOOL)fromDisk;

- (void)queryDiskCacheForKey:(NSString *)key delegate:(id <SDDataCacheManagerDelegate>)delegate userInfo:(NSDictionary *)info;

- (void)removeDataForKey:(NSString *)key;//移除指点的元素
- (void)clearMemory;//清理内存
- (void)clearDisk;//清理所有的缓存
- (void)cleanDisk;//清理过期的缓存

@end


@protocol SDDataCacheManagerDelegate<NSObject>

@optional
- (void)dataCache:(SDDataCacheManager *)dataCache didFindData:(NSData *)aData forKey:(NSString *)key userInfo:(NSDictionary *)info;
- (void)dataCache:(SDDataCacheManager *)dataCache didNotFindDataForKey:(NSString *)key userInfo:(NSDictionary *)info;

@end
