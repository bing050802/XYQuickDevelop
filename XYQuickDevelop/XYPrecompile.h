//
//  XYPrecompile.h
//  TWP_SkyBookShelf
//
//  Created by Heaven on 13-5-29.
//
//

#ifndef TWP_SkyBookShelf_XYPrecompile_h
#define TWP_SkyBookShelf_XYPrecompile_h

#define __USED_FMDatabase__ (0)
#define __USED_MBProgressHUD__ (0)
#define __USED_ASIHTTPRequest__ (0)
#define __USED_CocosDenshion__ (0)

#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <objc/runtime.h>

#import "CommonDefine.h"
#import "XYCommon.h"

// 第三方支持
#if (1 == __USED_FMDatabase__)
#import "FMDatabase.h"
#endif

#if (1 == __USED_MBProgressHUD__)
#import "MBProgressHUD.h"
#endif

#if (1 ==  __USED_ASIHTTPRequest__)
#import "ASIHTTPRequest.h"
#endif

#if (1 == __USED_CocosDenshion__)
#import "SimpleAudioEngine.h"
#endif