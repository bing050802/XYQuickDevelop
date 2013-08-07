//
//  XYFunction.m
//  TWP_SkyBookShelf
//
//  Created by Heaven on 13-7-10.
//
//

#import "XYCommon.h"
#import <Social/Social.h>
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "BlockUI.h"

@implementation Common
{
    
}
/***************************************************************/
+ (NSString *)dataFilePath:(NSString *)file ofType:(int)kType{
    NSString *pathFile = nil;
    switch (kType) {
        case kCommon_dataFilePath_documents:
        {
            // NSDocumentDirectory代表查找Documents路径,NSUserDomainMask代表在应用程序沙盒下找
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            // ios下Documents文件夹只有一个
            NSString *documentsDirectory = [paths objectAtIndex:0];
            pathFile = [documentsDirectory stringByAppendingPathComponent:file];
            break;
        }
        case kCommon_dataFilePath_tmp:
        {
            NSString *str = NSTemporaryDirectory();
            //    NSLog(@"%@", str);
            pathFile = [str stringByAppendingPathComponent:file];
            break;
        }
        case kCommon_dataFilePath_app:
        {
            // 获得文件名
            NSString *str =[file stringByDeletingPathExtension];
            // 获得文件扩展路径
            NSString *str2 = [file pathExtension];
            pathFile = [[NSBundle mainBundle] pathForResource:str ofType:str2];
            break;
        }
        default:
            break;
    }
    return pathFile;
}

/***************************************************************/
+ (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    //  NSLog(@"%@",returnStr);
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

/***************************************************************/
+ (NSRange)rangeOfString:(NSString *)str pointStart:(int)iStart start:(NSString *)strStart end:(NSString *)strEnd mark:(NSString *)strMark operation:(int)operation;
{
    int option = 0;
    NSRange rangeMark = {0, 0};
    NSRange rangeMarkA = {0, 0};
    
    rangeMark.location = iStart;
    rangeMark.length = str.length - iStart;
    
    rangeMark = [str rangeOfString:strMark options:NSLiteralSearch range:rangeMark];
    if(rangeMark.length == 0) return rangeMark;
    switch (operation) {
        case kCommon_rangeOfString_middle:
            rangeMarkA.location = iStart;
            rangeMarkA.length = rangeMark.location + rangeMark.length - iStart;
            option = NSBackwardsSearch;
            break;
        case kCommon_rangeOfString_front:
            rangeMarkA.location = rangeMark.location;
            rangeMarkA.length = str.length - rangeMark.location;
            option = NSLiteralSearch;
            break;
        case kCommon_rangeOfString_back:
            rangeMarkA.location = iStart;
            rangeMarkA.length = rangeMark.location + rangeMark.length - iStart;
            option = NSBackwardsSearch;
        default:
            break;
    }
    rangeMarkA = [str rangeOfString:strStart options:option range:rangeMarkA];
    if(rangeMarkA.length == 0) return rangeMarkA;
    
    NSRange rangeMarkB = NSMakeRange(0, 0);
    switch (operation) {
        case kCommon_rangeOfString_middle:
            rangeMarkB.length = str.length - rangeMark.location;
            rangeMarkB.location = rangeMark.location;
            break;
        case kCommon_rangeOfString_front:
            rangeMarkB.length = str.length - rangeMarkA.location - rangeMarkA.length;
            rangeMarkB.location = rangeMarkA.location + rangeMarkA.length;
            break;
        case kCommon_rangeOfString_back:
            rangeMarkB.length = rangeMark.location - rangeMarkA.location -rangeMarkA.length;
            rangeMarkB.location = rangeMarkA.location + rangeMarkA.length;
        default:
            break;
    }
    
    rangeMarkB = [str rangeOfString:strEnd options:NSLiteralSearch range:rangeMarkB];
    if(rangeMarkB.length == 0) return rangeMarkB;
    NSRange rangeTmp;
    rangeTmp.location = rangeMarkA.location;
    rangeTmp.length = rangeMarkB.location - rangeMarkA.location + rangeMarkB.length;
    
    return rangeTmp;
}

+ (NSRange)rangeOfString:(NSString *)str pointStart:(int)iStart start:(NSString *)strStart end:(NSString *)strEnd operation:(int)operation;
{
    // NSString *strMark = nil;
    NSRange rangeMark;
    return rangeMark;
}
+ (NSMutableArray *)rangeArrayOfString:(NSString *)str pointStart:(int)iStart start:(NSString *)strStart end:(NSString *)strEnd mark:(NSString *)strMark operation:(int)operation{
    return [Common rangeArrayOfString:str pointStart:iStart start:strStart end:strEnd mark:strMark operation:operation everyStringExecuteBlock:nil];
}
+(NSMutableArray *) rangeArrayOfString:(NSString *)str pointStart:(int)iStart start:(NSString *)strStart end:(NSString *)strEnd mark:(NSString *)strMark operation:(int)operation everyStringExecuteBlock:(void(^)(NSRange rangeEvery))block{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    int i = 0;
    while (i != -1) {
        NSRange range = [self rangeOfString:str pointStart:i start:strStart end:strEnd mark:strMark operation:operation];
        if(range.length == 0) break;
        [array addObject:[NSValue valueWithRange:range]];
        if (block) {
            // NSString *tmpStr = [str substringWithRange:range];
            block(range);
        }
        i = range.location + range.length;
    }
    
    return array;
}
/***************************************************************/
+(NSString *)getValueInANonAttributeXMLNode:(NSString *)str key:(NSString *)akey location:(int)location{
    NSString *str1 = [NSString stringWithFormat:@"<%@>", akey];
    NSString *str2 = [NSString stringWithFormat:@"</%@>", akey];
    static int i = 0;
    if (kLastLocation == location) {
        //   NSLogD(@"%s,%d", __FUNCTION__, str.length - akey.length*2);
        if (i> (str.length - akey.length*2)) i = 0;
    }else i = location;
    
    NSRange range = [Common rangeOfString:str pointStart:i start:str1 end:str2 mark:str1 operation:kCommon_rangeOfString_middle];
#pragma mark- 待优化
    if (0 == range.length) {
        i = 0;
        range = [Common rangeOfString:str pointStart:i start:str1 end:str2 mark:str1 operation:kCommon_rangeOfString_middle];
    }
    
    if (0 == range.length) return nil;
    
    i = range.location +range.length;
    range.location = range.location + str1.length;
    range.length = range.length - str1.length -str2.length;
    
    NSString *tmp = [str substringWithRange:range];
#pragma mark - 如果没有 返回空格
    if (tmp == nil) tmp = @" ";
    
    return tmp;
}
/***************************************************************/
// Recursively travel down the view tree, increasing the indentation level for children
+ (void) dumpView: (UIView *) aView atIndent: (int) indent into:(NSMutableString *) outstring{
    for (int i = 0; i < indent; i++) [outstring appendString:@"--"];
	[outstring appendFormat:@"[%2d] %@\n", indent, [[aView class] description]];
	for (UIView *view in [aView subviews]) [self dumpView:view atIndent:indent + 1 into:outstring];
}
// Start the tree recursion at level 0 with the root view
+ (NSString *) displayViews: (UIView *) aView
{
	NSMutableString *outstring = [[NSMutableString alloc] init];
	[self dumpView:aView atIndent:0 into:outstring];
	return [outstring autorelease];
}

/***************************************************************/
+ (NSMutableArray *)analyseString:(NSString *)str regularExpression:(NSString *)regexStr{
    NSMutableArray *arrayA = [self analyseStringToRange:str regularExpression:regexStr];
    NSMutableArray *arrayStr = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSValue *value in arrayA) {
        NSRange range = [value rangeValue];
        NSString *tmpString = [str substringWithRange:range];
        //NSLogD(@"->%@<-",result);
        [arrayStr addObject:tmpString];
    }
    
    return arrayStr;
}
+ (NSMutableArray *)analyseStringToRange:(NSString *)str regularExpression:(NSString *)regexStr{
    NSMutableArray *arrayA = [[[NSMutableArray alloc] init] autorelease];
    
    //NSRegularExpression类里面调用表达的方法需要传递一个NSError的参数。下面定义一个
	NSError *error;
    // \\d*\\.?\\d+匹配浮点
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:0 error:&error];
    if (regex != nil) {
        NSArray *matchs=[regex matchesInString:str options:0 range:NSMakeRange(0, [str length])];
        
        for (NSTextCheckingResult *match in matchs){
            if (match) {
                NSRange resultRange = [match rangeAtIndex:0];
                
                //从str当中截取数据
                // NSString *result=[str substringWithRange:resultRange];
                [arrayA addObject:[NSValue valueWithRange:resultRange]];
                //输出结果
                //NSLogD(@"->%@<-",result);
            }
        }
    }
    return arrayA;
}

/***************************************************************/
+ (NSMutableArray *)allFilesAtPath:(NSString *)direString type:(NSString*)fileType operation:(int)operatio{
    NSMutableArray *pathArray = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *tempArray = [fileManager contentsOfDirectoryAtPath:direString error:nil];
    
    if (tempArray == nil) {
        return nil;
    }
    
    NSString* type = [NSString stringWithFormat:@".%@",fileType];
    for (NSString *fileName in tempArray) {
        BOOL flag = YES;
        NSString *fullPath = [direString stringByAppendingPathComponent:fileName];
        
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&flag])
        {
            if (!flag) {
                
                if ([fileName hasSuffix:type]) {
                    
                    [pathArray addObject:fullPath];
                    
                }
            }
            else {
                
            }
        }
    }
    
    return pathArray;
}

/***************************************************************/
+(void)shareToTwitterWithStr:(NSString *)strText withPicPath:(NSString *)picPath withURL:(NSString*)strURL inController:(id)vc{
    /* 本项目屏蔽
     if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
     {
     SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
     [tweetSheet setInitialText:@"Tweeting from my own app! :)"];
     if (picPath) [tweetSheet addImage:[UIImage imageWithContentsOfFile:picPath]];
     if (strText) [tweetSheet setInitialText:strText];
     if (strURL) [tweetSheet addURL:[NSURL URLWithString:strURL]];
     
     if(vc==nil)
     {
     [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:tweetSheet animated:YES completion:nil];
     }
     }
     else
     {
     UIAlertView *alertView = [[UIAlertView alloc]
     initWithTitle:@"Sorry"
     message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
     delegate:self
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
     [alertView show];
     }
     */
}
/***************************************************************/
+(void) showAlertViewTitle:(NSString *)aTitle message:(NSString *)msg cancelButtonTitle:(NSString *)str{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:aTitle message:msg delegate:nil cancelButtonTitle:str otherButtonTitles:nil, nil];
    [alertview show];
    [alertview release];
}
/***************************************************************/
+(NSArray *)getPropertyListClass:(id)aObject{
    NSUInteger			propertyCount = 0;
    objc_property_t *	properties = class_copyPropertyList( [aObject class], &propertyCount );
    NSMutableArray *    array = [[[NSMutableArray alloc] init] autorelease];
    for ( NSUInteger i = 0; i < propertyCount; i++ )
    {
        const char *name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        
        //   const char *attr = property_getAttributes(properties[i]);
        // NSLogD(@"%s\n%@, %s", __FUNCTION__, propertyName, attr);
        [array addObject:propertyName];
    }
    free( properties );
    return array;
}
/***************************************************************/
+(void)activityShow:(BOOL)b{
    //   static UIView *bgView;
    static UIActivityIndicatorView *aView = nil;
    if (aView == nil) {
        /*
         bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
         bgView.backgroundColor = [UIColor blackColor];
         bgView.alpha = 0.7;
         */
        aView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    }
    if (b) {
        UIViewController *vc = [Common getCurrentViewController];
        aView.center = vc.view.center;
        [vc.view addSubview:aView];
        [aView startAnimating];
    }else{
        [aView stopAnimating];
        [aView removeFromSuperview];
        aView = nil;
    }
    
}
/***************************************************************/
+(NSString *)sha1:(NSString*)str{
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}
/***************************************************************/
+(void)openURL:(NSURL *)url{
    NSURL *tmpURL = url;
    if ([url isKindOfClass:[NSString class]]) {
        tmpURL = [NSURL URLWithString:url];
    }
    [[UIApplication sharedApplication ] openURL:tmpURL];
}

/***************************************************************/
#if (1 == __USED_FMDatabase__)
+ (BOOL)updateTable:(NSString *)tableName dbPath:(NSString *)dbPath object:(id)aObject{
    // NSString *path = [Common dataFilePath:@"/BeeDatabase/TWP_SkyBookShelf.db" ofType:kCommon_dataFilePath_documents];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    
    //查询指定表的字段
    NSString *sql = [NSString stringWithFormat:@"pragma table_info(%@)", tableName];
    FMResultSet *rs = [db executeQuery:sql];
    NSMutableArray *columns = [NSMutableArray arrayWithCapacity:1];
    while ([rs next])
    {
        [columns addObject:[rs stringForColumn:@"name"]];
    }
    
    //当前model的属性集合
    NSMutableArray *newColumns = [NSMutableArray arrayWithArray:[self getPropertyListClass:aObject]];
    
    //新增属性个数
    int newColumnCount = newColumns.count - columns.count;
    
    //当新增属性大于0才进行更新，我勒个去，哥不判断属性名变更了，太麻烦了，不许给我随便更改model的属性名否则后果自负
    //因为父类有SQLiteID 所有判断个数的时候-1
    if (newColumnCount >= 0)
    {
        NSMutableSet *setA = [NSMutableSet setWithArray:columns];
        //最新的列
        NSMutableSet *setB = [NSMutableSet setWithArray:newColumns];
        //得到新增的属性
        [setB minusSet:setA];
        NSString *baseSQL = [NSString stringWithFormat:@"alter table '%@' add column", tableName];
        FMDatabase *database = db;
        //采用事务，暂时写不来单条语句插入多个列的
        [database beginTransaction];
        //回滚标识
        BOOL needRollBack = NO;
        for (NSString *newColumn in setB)
        {
            NSString *sql1 = [NSString stringWithFormat:@"%@ '%@' TEXT", baseSQL, newColumn];
            NSLog(@"sql = %@", sql1);
            needRollBack = ![database executeUpdate:sql1];
            if (needRollBack)
            {
                //回滚吧，少年
                [database rollback];
                return NO;
            }
        }
        [database commit];
    }
    [db close];
    
    return YES;
}
#endif
/***************************************************************/
+ (UIViewController *)getCurrentViewController {
    UIViewController *result;
    // Try to find the root view controller programmically
    // Find the top window (that is not an alert view or other window)
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
        result = topWindow.rootViewController;
    else
        NSAssert(NO, @"Could not find a root view controller.");
    
    return result;
}

/***************************************************************/
#if (1 == __USED_MBProgressHUD__)
+(void)showMBProgressHUDTitle:(NSString *)aTitle msg:(NSString *)aMsg image:(UIImage *)aImg dimBG:(BOOL)dimBG delay:(float)d{
    UIViewController *vc = [self getCurrentViewController];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
    
    if (aImg)
    {
        UIImageView *img = [[UIImageView alloc] initWithImage:aImg];
        hud.customView = img;
        hud.mode = MBProgressHUDModeCustomView;
        
        [img release];
    }else{
        hud.mode = MBProgressHUDModeText;
    }
    
    hud.labelText = aTitle;
    hud.detailsLabelText = aMsg;
    hud.removeFromSuperViewOnHide = YES;
    hud.dimBackground = dimBG;
    [hud show:YES];
    [hud hide:YES afterDelay:d];
}
+(void) showMBProgressHUDTitle:(NSString *)aTitle msg:(NSString *)aMsg dimBG:(BOOL)dimBG executeBlock:(void(^)(MBProgressHUD *hud))blockE finishBlock:(void(^)(void))blockF{
    UIViewController *vc = [self getCurrentViewController];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
    hud.labelText = aTitle;
    hud.detailsLabelText = aMsg;
    hud.removeFromSuperViewOnHide = YES;
    hud.dimBackground = dimBG;
    [hud showAnimated:YES whileExecutingBlock:^{
		blockE(hud);
	} completionBlock:^{
		//[hud hide:YES];
        blockF();
	}];
}
#endif
/***************************************************************/
+ (NSString *)getStringFromDate:(NSDate *)date
{
    NSDateFormatter*formatter = [[NSDateFormatter alloc] init];
    //    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    NSString *dateTimeString=[formatter stringFromDate:date];
    [formatter release];
    return dateTimeString;
}
/***************************************************************/
+ (NSDate *)getDateFromString:(NSString *)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:string];
    [dateFormatter release];
    return date;
}
/***************************************************************/
+ (NSString *)StringForSQL:(NSString *)str
{
    return [str stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
}
/***************************************************************/
+ (NSString *)getLocalHost{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

/***************************************************************/
#if (1 ==  __USED_ASIHTTPRequest__)
+(ASIHTTPRequest *) startAsynchronousRequestWithURLString:(NSString *)str
                                                  succeed:(void (^)(ASIHTTPRequest *request))blockS
                                                   failed:(void (^)(NSError *error))blockF{
    NSURL *link = [NSURL URLWithString:str];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:link];
    request.timeOutSeconds = 10;
    [request setCompletionBlock:^{
        if (blockS) {
            blockS(request);
        }
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        if (blockF) {
            blockF(error);
        }
    }];
    [request startAsynchronous];
    
    return request;
}
#endif
/***************************************************************/
+(void) printUsedAndFreeMemoryWithMark:(NSString *)mark{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        NSLog(@"mark: %@\nFailed to fetch vm statistics", mark);
    
    /* Stats in bytes */
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
    int iUsed = round(mem_used/100000);
    int iFree = round(mem_free/100000);
    int iTotal = round(mem_total/100000);
    NSLog(@"mark: %@\nused: %d free: %d total: %d", mark, iUsed, iFree, iTotal);
}

/***************************************************************/
/*
 +(void) showBackgroundView{
 [Common setBackgroundViewHidden:NO];
 }
 +(void) removeBackgroundView{
 [Common setBackgroundViewHidden:YES];
 }
 +(void) setBackgroundViewHidden:(BOOL)b{
 static UIControl *tmpView2 = nil;
 if (b) {
 if (tmpView2) {
 [tmpView2 removeFromSuperview];
 tmpView2 = nil;
 }
 
 }else{
 UIView *tmpView = [Common getCurrentViewController].view;
 CGRect rect;
 if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
 // 竖屏
 rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
 }else{
 // 横屏
 rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
 }
 if (tmpView2) {
 tmpView2.frame = rect;
 }else{
 tmpView2 = [[UIControl alloc] initWithFrame:rect];
 tmpView2.backgroundColor = RGBACOLOR(0, 0, 0, 0.8);
 tmpView2.userInteractionEnabled = YES;
 [tmpView2 addTarget:self action:@selector(removeBackgroundView) forControlEvents:UIControlEventTouchUpInside];
 }
 [tmpView addSubview:tmpView2];
 [tmpView2 release];
 }
 }
 */

/***************************************************************/
#if (1 ==  __USED_ASIHTTPRequest__)
+(void) checkUpdateInAppStore:(NSString *)appID curVersion:(NSString *)aVersion appURLString:(NSString *)strURL
                         same:(void(^)(void))blockSame
                    stayStill:(void(^)(void))blockstayStill{
    [self checkUpdateInAppStore:appID curVersion:aVersion
                           same:blockSame localIsOld:^(NSString *appStoreVersion) {
                               NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
                               NSString *appName = [infoDict objectForKey:@"CFBundleDisplayName"];
                               NSString *msg = [NSString stringWithFormat:@"There is a new update available for the %@ (v%@),  would you like to download from the App Store now ?", appName, appStoreVersion];
                               
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                                               message:msg
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"Cancel"
                                                                     otherButtonTitles:@"Update",nil];
                               [alert showWithCompletionHandler:^(NSInteger buttonIndex) {
                                   if (buttonIndex == 0) {
                                       if (blockstayStill) {
                                           blockstayStill();
                                       }
                                   }else if (buttonIndex == 1){
                                       [self openURL:[NSURL URLWithString:strURL]];
                                   }
                               }];
                           }];
}
+(void) checkUpdateInAppStore:(NSString *)appID curVersion:(NSString *)aVersion
                         same:(void(^)(void))blockSame
                   localIsOld:(void(^)(NSString *appStoreVersion))blocklocalIsOld{
    NSURL *appleLink = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", appID]];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:appleLink];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    request.timeOutSeconds = 10;
    [request setCompletionBlock:^{
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *str = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
        
        NSRange range = [self rangeOfString:str pointStart:0 start:@":\"" end:@"\"," mark:@"\"version\"" operation:kCommon_rangeOfString_front];
        NSString *versionAppStore = [str substringWithRange:NSMakeRange(range.location + 2, range.length -4)];
        NSString *localVersion;
        if (aVersion == nil) {
            localVersion = [infoDict objectForKey:@"CFBundleVersion"];
        }else{
            localVersion = aVersion;
        }
        
        BOOL b = [self compareVersionFromOldVersion:localVersion newVersion:versionAppStore];
        
        if (b) {
            if (blocklocalIsOld) {
                blocklocalIsOld(versionAppStore);
            }
        }else{
            if (blockSame) {
                blockSame();
            }
        }
        
    }];
    [request setFailedBlock:^{
        if (blockSame) {
            blockSame();
        }
    }];
    [request startAsynchronous];
}
#endif
/***************************************************************/
+(BOOL) compareVersionFromOldVersion:(NSString *)oldVersion newVersion:(NSString *)newVersion{
    NSArray*oldV = [oldVersion componentsSeparatedByString:@"."];
    NSArray*newV = [newVersion componentsSeparatedByString:@"."];
    
    if (oldV.count == newV.count) {
        for (NSInteger i = 0; i < oldV.count; i++) {
            NSInteger old = [(NSString *)[oldV objectAtIndex:i] integerValue];
            NSInteger new = [(NSString *)[newV objectAtIndex:i] integerValue];
            if (old < new) {
                return YES;
            }
        }
        return NO;
    } else {
        return NO;
    }
}

@end

