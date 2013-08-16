//
//  SDNetworkActivityIndicator.m
//  DaZhongNetwork
//
//  Created by 谭 颢 on 11-7-15.
//  Copyright 2011 天府学院. All rights reserved.
//

#import "SDNetworkActivityIndicator.h"

static SDNetworkActivityIndicator *instance=nil;

@implementation SDNetworkActivityIndicator

+ (id)sharedActivityIndicator
{
	if (instance==nil) 
    {
		//UIActivityIndicatorView *loadingView;
		instance=[[SDNetworkActivityIndicator alloc] init];
	}
	return instance;
}

- (void)startActivity
{
#if TARGET_OS_IPHONE
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#endif
}

- (void)stopActivity
{
#if TARGET_OS_IPHONE
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
}

@end
