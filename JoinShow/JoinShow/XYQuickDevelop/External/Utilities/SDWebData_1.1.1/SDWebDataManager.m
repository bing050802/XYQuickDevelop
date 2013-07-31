//
//  SDWebDataManager.m
//  SDWebData
//
//  Created by stm on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SDWebDataManager.h"

static SDWebDataManager *instance=nil;

@implementation SDWebDataManager
@synthesize MaxConcurrentCount;

- (id)init
{
    if ((self = [super init]))
    {
        MaxConcurrentCount = 10;
        delegates = [[NSMutableArray alloc] init];
        contexts  = [[NSMutableArray alloc] init];
        downloaders = [[NSMutableArray alloc] init];
        downloaderForURL = [[NSMutableDictionary alloc] init];
        failedURLs = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (id)sharedManager
{
    if (instance == nil)
    {
        instance = [[SDWebDataManager alloc] init];
    }
	
    return instance;
}

- (void)startDownloaderQueue
{
    NSInteger activateCount = 0;
    //for (NSInteger idx = [downloaders count] - 1; idx >= 0; idx--)
    NSArray *loopArray = [NSArray arrayWithArray:downloaders];
    for (NSInteger idx = 0; idx < [loopArray count]; idx++)
    {
        SDWebDataDownloader *loader = [loopArray objectAtIndex:idx];
        if (!loader.isActivate)
        {
            [loader performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
        }
        if (++activateCount > MaxConcurrentCount)
        {
            break;
        }
    }
}

- (void)uploadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate postInfo:(NSDictionary *)info context:(id)context
{
    if (!url || !delegate)
    {
        return;
    }
    if (!context)
    {
        context = [NSNull null];
    }
    
    // Share the same downloader for identical URLs so we don't download the same URL several times
    SDWebDataDownloader *downloader = [SDWebDataDownloader uploadWithURL:url delegate:self postInfo:info];
    
    [delegates addObject:delegate];
    [contexts addObject:context];
    [downloaders addObject:downloader];
    [self startDownloaderQueue];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate
{
    [self downloadWithURL:url delegate:delegate context:nil];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate context:(id)context
{
	[self downloadWithURL:url delegate:delegate context:context refreshCache:NO];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate context:(id)context refreshCache:(BOOL)refreshCache
{
	[self downloadWithURL:url delegate:delegate context:context refreshCache:refreshCache retryFailed:NO];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate context:(id)context refreshCache:(BOOL)refreshCache retryFailed:(BOOL)retryFailed
{
	[self downloadWithURL:url delegate:delegate context:context refreshCache:refreshCache retryFailed:retryFailed lowPriority:NO];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate context:(id)context refreshCache:(BOOL)refreshCache retryFailed:(BOOL)retryFailed lowPriority:(BOOL)lowPriority
{
	if (!url || !delegate || (!retryFailed && [failedURLs containsObject:url]))
    {
        return;
    }
    
    if (!context)
    {
        context = [NSNull null];
    }
    
	if (!refreshCache) 
	{
		// Check the on-disk cache async so we don't block the main thread
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:delegate, @"delegate", context, @"context", url, @"url", [NSNumber numberWithBool:lowPriority], @"low_priority", nil];
		[[SDDataCacheManager sharedManager] queryDiskCacheForKey:[url absoluteString] delegate:self userInfo:info];
	}else 
    {		
		// Share the same downloader for identical URLs so we don't download the same URL several times
		SDWebDataDownloader *downloader = [downloaderForURL objectForKey:url];
		
		if (!downloader) 
		{
			downloader = [SDWebDataDownloader downloaderWithURL:url delegate:self userInfo:nil lowPriority:lowPriority];
			[downloaderForURL setObject:downloader forKey:url];
		}
		
		// If we get a normal priority request, make sure to change type since downloader is shared
		if (!lowPriority && downloader.lowPriority)
			downloader.lowPriority = NO;
		
		[delegates addObject:delegate];
        [contexts addObject:context];
		[downloaders addObject:downloader];
        [self startDownloaderQueue];
	}
}


- (void)cancelForDelegate:(id<SDWebDataManagerDelegate>)delegate
{
	NSUInteger idx = [delegates indexOfObjectIdenticalTo:delegate];    
    while (idx != NSNotFound)
    {
        SDWebDataDownloader *downloader = [downloaders objectAtIndex:idx];
        
        [delegates removeObjectAtIndex:idx];
        [contexts removeObjectAtIndex:idx];
        [downloaders removeObjectAtIndex:idx];
        [self startDownloaderQueue];
        
        if (![downloaders containsObject:downloader])
        {
            // No more delegate are waiting for this download, cancel it
            [downloader cancel];
            [downloaderForURL removeObjectForKey:downloader.url];
        }
        
        idx = [delegates indexOfObjectIdenticalTo:delegate];
    }
}

#pragma mark -
#pragma mark SDDataCacheDelegate

- (void)dataCache:(SDDataCacheManager *)dataCache didFindData:(NSData *)aData forKey:(NSString *)key userInfo:(NSDictionary *)info
{
	id<SDWebDataManagerDelegate> delegate = [info objectForKey:@"delegate"];
    id context = [info objectForKey:@"context"];
    if ([context isKindOfClass:[NSNull class]])
    {
        context = nil;
    }
    
	if ([delegate respondsToSelector:@selector(webDataFinishWithData:context:isCache:)])
	{
		[delegate webDataFinishWithData:aData context:context isCache:YES];
	}
}

- (void)dataCache:(SDDataCacheManager *)dataCache didNotFindDataForKey:(NSString *)key userInfo:(NSDictionary *)info
{
	NSURL *url = [info objectForKey:@"url"];
    id context = [info objectForKey:@"context"];
	id<SDWebDataManagerDelegate> delegate = [info objectForKey:@"delegate"];
	BOOL lowPriority = [[info objectForKey:@"low_priority"] boolValue];
	
	// Share the same downloader for identical URLs so we don't download the same URL several times
	SDWebDataDownloader *downloader = [downloaderForURL objectForKey:url];
	
	if (!downloader) 
	{
		downloader = [SDWebDataDownloader downloaderWithURL:url delegate:self userInfo:nil lowPriority:lowPriority];
		[downloaderForURL setObject:downloader forKey:url];
	}
	
	// If we get a normal priority request, make sure to change type since downloader is shared
    if (!lowPriority && downloader.lowPriority)
        downloader.lowPriority = NO;
    
    [delegates addObject:delegate];
    [contexts addObject:context];
    [downloaders addObject:downloader];
    [self startDownloaderQueue];
}

#pragma mark -
#pragma mark SDWebDataDownloaderDelegate

- (void)dataDownloader:(SDWebDataDownloader *)downloader didFinishWithData:(NSData *)aData
{	
    // Notify all the delegates with this downloader
    for (NSInteger idx = [downloaders count] - 1; idx >= 0; idx--)
    {
        SDWebDataDownloader *aDownloader = [downloaders objectAtIndex:idx];
        if (aDownloader == downloader)
        {
            id<SDWebDataManagerDelegate> delegate = [delegates objectAtIndex:idx];
			id context = [contexts objectAtIndex:idx];
            if ([context isKindOfClass:[NSNull class]])
            {
                context = nil;
            }
            
            if (aData)
            {
				if ([delegate respondsToSelector:@selector(webDataFinishWithData:context:isCache:)]) 
				{
					[delegate webDataFinishWithData:aData context:context isCache:NO];
				}
            }
            else
            {
				if ([delegate respondsToSelector:@selector(webDataFailWithError:context:)]) 
				{
                    [delegate webDataFailWithError:nil context:context];
				}
            }
			
            [downloaders removeObjectAtIndex:idx];
            [delegates removeObjectAtIndex:idx];
            [contexts removeObjectAtIndex:idx];
            [self startDownloaderQueue];
        }
    }
	
    if (aData)
    {
        if (!downloader.isPost)
        {
            // Store the data in the cache
            [[SDDataCacheManager sharedManager] storeData:aData forKey:[downloader.url absoluteString] toDisk:YES];
        }
    }
    else
    {
        // The image can't be downloaded from this URL, mark the URL as failed so we won't try and fail again and again
        [failedURLs addObject:downloader.url];
    }
	
    // Release the downloader
    [downloaderForURL removeObjectForKey:downloader.url];
}

- (void)dataDownloader:(SDWebDataDownloader *)downloader didFailWithError:(NSError *)error
{
    // Notify all the delegates with this downloader
    for (NSInteger idx = [downloaders count] - 1; idx >= 0; idx--)
    {
        SDWebDataDownloader *aDownloader = [downloaders objectAtIndex:idx];
        if (aDownloader == downloader)
        {
            id<SDWebDataManagerDelegate> delegate = [delegates objectAtIndex:idx];
			id context = [contexts objectAtIndex:idx];
            if ([context isKindOfClass:[NSNull class]])
            {
                context = nil;
            }
            
			if ([delegate respondsToSelector:@selector(webDataFailWithError:context:)]) 
			{
                [delegate webDataFailWithError:error context:context];
			}
			
            [downloaders removeObjectAtIndex:idx];
            [delegates removeObjectAtIndex:idx];
            [contexts removeObjectAtIndex:idx];
            [self startDownloaderQueue];
        }
    }
	
    // Release the downloader
    [downloaderForURL removeObjectForKey:downloader.url];
}


@end
