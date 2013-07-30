//
//  SDWebDataDownloader.m
//  SDWebData
//
//  Created by stm on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SDWebDataDownloader.h"

static NSString *const SDWebDataDownloadStartNotification = @"SDWebDataDownloadStartNotification";
static NSString *const SDWebDataDownloadStopNotification = @"SDWebDataDownloadStopNotification";

static NSString *const kBoundaryStr=@"_insert_some_boundary_here_";

@interface SDWebDataDownloader ()
@property (nonatomic, retain) NSURLConnection *connection;
@end

@implementation SDWebDataDownloader
@synthesize url, delegate, connection, theData, userInfo, isActivate, isPost, lowPriority;

+ (id)downloaderWithURL:(NSURL *)aUrl delegate:(id<SDWebDataDownloaderDelegate>)aDelegate
{
	return [[self class] downloaderWithURL:aUrl delegate:aDelegate userInfo:nil];
}

+ (id)downloaderWithURL:(NSURL *)aUrl delegate:(id<SDWebDataDownloaderDelegate>)aDelegate userInfo:(id)aUserInfo
{
	return [[self class] downloaderWithURL:aUrl delegate:aDelegate userInfo:aUserInfo lowPriority:NO];
}

+ (id)downloaderWithURL:(NSURL *)aUrl delegate:(id<SDWebDataDownloaderDelegate>)aDelegate userInfo:(id)aUserInfo lowPriority:(BOOL)aLowPriority
{
	// Bind SDNetworkActivityIndicator if available (download it here: http://github.com/rs/SDNetworkActivityIndicator )
    // To use it, just add #import "SDNetworkActivityIndicator.h" in addition to the SDWebImage import
    if (NSClassFromString(@"SDNetworkActivityIndicator"))
    {
        id activityIndicator = [NSClassFromString(@"SDNetworkActivityIndicator") performSelector:NSSelectorFromString(@"sharedActivityIndicator")];
        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"startActivity")
                                                     name:SDWebDataDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"stopActivity")
                                                     name:SDWebDataDownloadStopNotification object:nil];
    }
    
    SDWebDataDownloader *downloader = [[SDWebDataDownloader alloc] init];
    downloader.url = aUrl;
    downloader.delegate = aDelegate;
    downloader.userInfo = aUserInfo;
    downloader.lowPriority = aLowPriority;
    downloader.isPost = NO;
    return downloader;
}

+ (NSData*)generateFormData:(NSDictionary*)dict
{
	NSString* boundary = [NSString stringWithString:kBoundaryStr];
	NSArray* keys = [dict allKeys];
	NSMutableData* result = [[NSMutableData alloc] init];
    
    NSStringEncoding  encoding = NSUTF8StringEncoding; //NSASCIIStringEncoding;
	for (int i = 0; i < [keys count]; i++) 
	{
		id value = [dict valueForKey: [keys objectAtIndex: i]];
		[result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:encoding]];
		if ([value isKindOfClass:[NSString class]])
		{
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [keys objectAtIndex:i]] dataUsingEncoding:encoding]];
			[result appendData:[[NSString stringWithFormat:@"%@",value] dataUsingEncoding:encoding]];
		}
        if ([value isKindOfClass:[NSNumber class]])
		{
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [keys objectAtIndex:i]] dataUsingEncoding:encoding]];
			[result appendData:[[value stringValue] dataUsingEncoding:encoding]];
		}
		else if ([value isKindOfClass:[NSURL class]] && [value isFileURL])
		{
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [keys objectAtIndex:i], [[value path] lastPathComponent]] dataUsingEncoding:encoding]];
			[result appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:encoding]];
			[result appendData:[NSData dataWithContentsOfFile:[value path]]];
		}
        else if ([value isKindOfClass:[NSData class]])
        {
            [result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [keys objectAtIndex:i]] dataUsingEncoding:encoding]];
			[result appendData:value];
        }
		[result appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:encoding]];
	}
	[result appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:encoding]];
	
	return result;
}

+ (id)uploadWithURL:(NSURL *)aUrl delegate:(id<SDWebDataDownloaderDelegate>)aDelegate postInfo:(NSDictionary *)info
{
    SDWebDataDownloader *downloader = [[SDWebDataDownloader alloc] init];
    downloader.url = aUrl;
    downloader.delegate = aDelegate;
    downloader.userInfo = info;
    downloader.lowPriority = NO;
    downloader.isPost = YES;
    return downloader;
}

+ (void)setMaxConcurrentDownloads:(NSUInteger)max
{
    // NOOP
}

- (void)start
{
    isActivate = YES;
    
    // In order to prevent from potential duplicate caching (NSURLCache + SDImageCache) we disable the cache for image requests    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0];
    if (isPost)
    {
        [request setHTTPMethod:@"POST"];    
        NSString *header_type = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",kBoundaryStr];
        [request addValue: header_type forHTTPHeaderField: @"Content-Type"];    
        //按照HTTP的相关协议格式化数据
        NSData *postData=[SDWebDataDownloader generateFormData:self.userInfo];
        [request addValue:[NSString stringWithFormat:@"%d",[postData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
    }
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    // If not in low priority mode, ensure we aren't blocked by UI manipulations (default runloop mode for NSURLConnection is NSEventTrackingRunLoopMode)
    if (!self.lowPriority)
    {
        [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    
    if (connection)
    {
        self.theData = [NSMutableData data];
        [[NSNotificationCenter defaultCenter] postNotificationName:SDWebDataDownloadStartNotification object:nil];
        [connection start];
    }
    else
    {
        isActivate = NO;
        
        if ([delegate respondsToSelector:@selector(dataDownloader:didFailWithError:)])
        {
            [delegate performSelector:@selector(dataDownloader:didFailWithError:) withObject:self withObject:nil];
        }
    }
}

- (void)cancel
{
    isActivate = NO;
    if (connection)
    {
        [connection cancel];
        self.connection = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:SDWebDataDownloadStopNotification object:nil];
    }
}

#pragma mark NSURLConnection (delegate)

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data
{
    [theData appendData:data];
}

#pragma GCC diagnostic ignored "-Wundeclared-selector"
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    isActivate = NO;
    self.connection = nil;
	
    [[NSNotificationCenter defaultCenter] postNotificationName:SDWebDataDownloadStopNotification object:nil];
	
    if ([delegate respondsToSelector:@selector(dataDownloaderDidFinish:)])
    {
        [delegate performSelector:@selector(dataDownloaderDidFinish:) withObject:self];
    }
    
    if ([delegate respondsToSelector:@selector(dataDownloader:didFinishWithData:)])
    {
		NSData *data=theData;
        [delegate performSelector:@selector(dataDownloader:didFinishWithData:) withObject:self withObject:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    isActivate = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SDWebDataDownloadStopNotification object:nil];
	
    if ([delegate respondsToSelector:@selector(dataDownloader:didFailWithError:)])
    {
        [delegate performSelector:@selector(dataDownloader:didFailWithError:) withObject:self withObject:error];
    }
	
    self.connection = nil;
    self.theData = nil;
}

#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
