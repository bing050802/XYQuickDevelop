//
//  SDDataCache.m
//  SDWebData
//
//  Created by stm on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SDDataCacheManager.h"
#import <CommonCrypto/CommonDigest.h>

static NSString* const kDataCacheDirectory=@"DataCache";
static SDDataCacheManager *instance;

@implementation SDDataCacheManager
@synthesize cacheMaxCacheAge, memCacheMaxSize;

- (id)init
{
    if ((self = [super init]))
    {
        // Init the memory cache
        memCache = [[NSMutableDictionary alloc] init];
        memCacheKeyArray = [[NSMutableArray alloc] init];
        
        //default cacheMaxCacheAge 1 week
        cacheMaxCacheAge = 7*24*60*60;
        
        //default memCacheMaxSize 2M
        memCacheMaxSize = 2*1024*1024;
		
        // Init the disk cache
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kDataCacheDirectory];
		
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.diskCachePath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.diskCachePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
        
		//clean pass cache
        [self cleanDisk];
        
        // Init the operation queue
        cacheInQueue = [[NSOperationQueue alloc] init];
        cacheInQueue.maxConcurrentOperationCount = 1;
        cacheOutQueue = [[NSOperationQueue alloc] init];
        cacheOutQueue.maxConcurrentOperationCount = 1;
#if !TARGET_OS_IPHONE
#else
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
		
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
		
#ifdef __IPHONE_4_0
        UIDevice *device = [UIDevice currentDevice];
        if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported)
        {
            // When in background, clean memory in order to have less chance to be killed
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(clearMemory)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
        }
		
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
#endif
#endif
    }
	
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark SDDataCache (class methods)

+ (SDDataCacheManager *)sharedManager
{
    if (instance == nil)
    {
        instance = [[SDDataCacheManager alloc] init];
    }
	
    return instance;
}

#pragma mark SDDataCache (private)

- (void)setMemCacheWithObject:(NSData *)obj withKey:(id)key
{    
    if (obj.length > memCacheMaxSize)
    {
        return;
    }
    
    unsigned long long(^block)(void);
    block = ^{
        unsigned long long  memCacheSize = 0;
        for (id aObj in [memCache allValues])
        {
            if ([aObj isKindOfClass:[NSData class]])
            {
                memCacheSize += [(NSData *)aObj length];
            }
        }
        return memCacheSize;
    };
    
    while ([memCacheKeyArray count]>0 && block()+obj.length>memCacheMaxSize)
    {
        id firstKey = [memCacheKeyArray objectAtIndex:0];
        [memCache removeObjectForKey:firstKey];
        [memCacheKeyArray removeObject:firstKey];
    }
    
    [memCache setObject:obj forKey:key];
    [memCacheKeyArray removeObject:key];
    [memCacheKeyArray addObject:key];
}

- (void)removeMemCacheForKey:(id)key
{
    [memCache removeObjectForKey:key];
    [memCacheKeyArray removeObject:key];
}

- (void)removeMemCache
{
    [memCache removeAllObjects];
    [memCacheKeyArray removeAllObjects];
}

- (NSString *)cachePathForKey:(NSString *)key
{
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
	
    return [self.diskCachePath stringByAppendingPathComponent:filename];
}

- (void)storeKeyWithDataToDisk:(NSDictionary *)arguments
{
    // Can't use defaultManager another thread
    NSFileManager *fileManager = [NSFileManager defaultManager];
	
    NSString *key = [arguments objectForKey:@"key"];
    NSData   *data = [arguments objectForKey:@"data"];
	if (data)
	{
		[fileManager createFileAtPath:[self cachePathForKey:key] contents:data attributes:nil];
	}
}

- (void)notifyDelegate:(NSDictionary *)arguments
{
    NSString *key = [arguments objectForKey:@"key"];
    id <SDDataCacheManagerDelegate> delegate = [arguments objectForKey:@"delegate"];
    NSDictionary *info = [arguments objectForKey:@"userInfo"];
    NSData *data = [arguments objectForKey:@"data"];
	
    if (data)
    {
        [self setMemCacheWithObject:data withKey:key];
		
        if ([delegate respondsToSelector:@selector(dataCache:didFindData:forKey:userInfo:)])
        {
            [delegate dataCache:self didFindData:data forKey:key userInfo:info];
        }
    }
    else
    {
        if ([delegate respondsToSelector:@selector(dataCache:didNotFindDataForKey:userInfo:)])
        {
            [delegate dataCache:self didNotFindDataForKey:key userInfo:info];
        }
    }
}

- (void)queryDiskCacheOperation:(NSDictionary *)arguments
{
    NSString *key = [arguments objectForKey:@"key"];
    NSMutableDictionary *mutableArguments = [arguments mutableCopy];
	
	NSData *data=[[NSData alloc] initWithContentsOfFile:[self cachePathForKey:key]];
    if (data)
    {
        [mutableArguments setObject:data forKey:@"data"];
    }
	
    [self performSelectorOnMainThread:@selector(notifyDelegate:) withObject:mutableArguments waitUntilDone:NO];
}

#pragma mark DataCache

- (void)storeData:(NSData *)aData forKey:(NSString *)key
{
	[self storeData:aData forKey:key toDisk:YES];
}

- (void)storeData:(NSData *)aData forKey:(NSString *)key toDisk:(BOOL)toDisk
{
    if (!aData || !key)
    {
        return;
    }
	
    if (toDisk && !aData)
    {
        return;
    }
	
    [self setMemCacheWithObject:aData withKey:key];
	
    if (toDisk)
    {		
        NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:aData,@"data",key,@"key", nil];
        [cacheInQueue addOperation:[[NSInvocationOperation alloc] initWithTarget:self
                                                                         selector:@selector(storeKeyWithDataToDisk:)
                                                                           object:arguments]];
    }
}

- (NSData *)dataFromKey:(NSString *)key
{
    return [self dataFromKey:key fromDisk:YES];
}

- (NSData *)dataFromKey:(NSString *)key fromDisk:(BOOL)fromDisk
{
    if (key == nil)
    {
        return nil;
    }
	
	NSData *data=[memCache objectForKey:key];
	
    if (!data && fromDisk)
    {
		data=[[NSData alloc] initWithContentsOfFile:[self cachePathForKey:key]];
        if (data)
        {
            [self setMemCacheWithObject:data withKey:key];
        }
    }
	
    return data;
}

- (void)queryDiskCacheForKey:(NSString *)key delegate:(id <SDDataCacheManagerDelegate>)delegate userInfo:(NSDictionary *)info
{
    if (!delegate)
    {
        return;
    }
	
    if (!key)
    {
        if ([delegate respondsToSelector:@selector(dataCache:didNotFindDataForKey:userInfo:)])
        {
            [delegate dataCache:self didNotFindDataForKey:key userInfo:info];
        }
        return;
    }
	
    // First check the in-memory cache...
	NSData *data=[memCache objectForKey:key];
	
    if (data)
    {
        // ...notify delegate immediately, no need to go async
        if ([delegate respondsToSelector:@selector(dataCache:didFindData:forKey:userInfo:)])
        {
            [delegate dataCache:self didFindData:data forKey:key userInfo:info];
        }
        return;
    }
	
    NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithCapacity:3];
    [arguments setObject:key forKey:@"key"];
    [arguments setObject:delegate forKey:@"delegate"];
    if (info)
    {
        [arguments setObject:info forKey:@"userInfo"];
    }
    [cacheOutQueue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(queryDiskCacheOperation:) object:arguments]];
}

- (void)removeDataForKey:(NSString *)key
{
    if (key == nil)
    {
        return;
    }
	
    [self removeMemCacheForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:[self cachePathForKey:key] error:nil];
}

- (void)clearMemory
{
    [cacheInQueue cancelAllOperations]; // won't be able to complete
    [self removeMemCache];
}

- (void)clearDisk
{
    [cacheInQueue cancelAllOperations];
    [[NSFileManager defaultManager] removeItemAtPath:self.diskCachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.diskCachePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}

- (void)cleanDisk
{
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheMaxCacheAge];
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.diskCachePath];
    for (NSString *fileName in fileEnumerator)
    {
        NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        //if ([[[attrs fileModificationDate] laterDate:expirationDate] isEqualToDate:expirationDate])
		if ([[attrs fileModificationDate] compare:expirationDate]==NSOrderedAscending)
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}

@end
