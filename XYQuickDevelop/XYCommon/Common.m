//
//  FilePath.m
//  ComicReader
//
//  Created by Heaven on 12-1-26.
//  Copyright (c) 2012年 Heaven. All rights reserved.
//

#import "Common.h"
#import <Social/Social.h>
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

// 第三方支持
#ifdef USED_FMDatabase
#import "FMDatabase.h"
#endif

#ifdef USED_MBProgressHUD
#import "MBProgressHUD.h"
#endif

#ifdef USED_ASIHTTPRequest
#import "ASIHTTPRequest.h"
#endif

@implementation Common
{
    
}
/***************************************************************/
+ (NSString *)dataFilePath:(NSString *)file ofType:(int)kType{
    NSString *pathFile = nil;
    switch (kType) {
        case kDocuments:
        {
            // NSDocumentDirectory代表查找Documents路径,NSUserDomainMask代表在应用程序沙盒下找
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            // ios下Documents文件夹只有一个
            NSString *documentsDirectory = [paths objectAtIndex:0];
            pathFile = [documentsDirectory stringByAppendingPathComponent:file];
            break;
        }
        case kTmp:
        {
            NSString *str = NSTemporaryDirectory();
        //    NSLog(@"%@", str);
            pathFile = [str stringByAppendingPathComponent:file];
            break;
        }
        case kAPP:
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
+(NSMutableArray *) rangeArrayOfString:(NSString *)str pointStart:(int)iStart start:(NSString *)strStart end:(NSString *)strEnd mark:(NSString *)strMark operation:(int)operation everyStringExecuteBlock:(void(^)(NSString *strEvery))block{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    int i = 0;
    while (i != -1) {
        NSRange range = [self rangeOfString:str pointStart:i start:strStart end:strEnd mark:strMark operation:operation];
        if(range.length == 0) break;
        [array addObject:[NSValue valueWithRange:range]];
        if (block) {
            NSString *tmpStr = [str substringWithRange:range];
            block(tmpStr);
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
+(void)showAlertViewTitle:(NSString *)aTitle message:(NSString *)msg cancelButtonTitle:(NSString *)str{
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
        aView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    if (b) {
        UIViewController *vc = [Common getCurrentViewController];
        aView.center = vc.view.center;
        [vc.view addSubview:aView];
        [aView startAnimating];
    }else{
        [aView stopAnimating];
    }
   
}
/***************************************************************/
/*
+(void)playSoundWihtPath:(NSString *)audioPath
{
    if (audioPath) {
        NSURL *soundUrl = [[NSURL alloc] initFileURLWithPath:audioPath];
        NSError *error = [[NSError alloc] init];
        AVAudioPlayer *audio = [[[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error] autorelease];
       // NSLogD(@"%s, %@", __FUNCTION__, error);
        [error release];
        // [data release];
        [soundUrl release];
        audio.numberOfLoops = 0;
        // audio.delegate = self;
        // [audio setVolume:1];
        [audio prepareToPlay];
        [audio play];
    }
}
 */
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
#ifdef USED_FMDatabase
/***************************************************************/
+ (BOOL)updateTable:(NSString *)tableName dbPath:(NSString *)dbPath object:(id)aObject{
   // NSString *path = [Common dataFilePath:@"/BeeDatabase/TWP_SkyBookShelf.db" ofType:kDocuments];
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
#ifdef USED_MBProgressHUD
/***************************************************************/
+(void)showMBProgressHUDTitle:(NSString *)aTitle msg:(NSString *)aMsg image:(UIImage *)aImg delay:(float)d{
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
    [hud show:YES];
    [hud hide:YES afterDelay:d];
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
+ (ASIHTTPRequest *)startAsynchronousRequestWithUrl:(NSString *)url
                                             succeed:(void (^)(ASIHTTPRequest *request))blockS
                                              failed:(void (^)(void))blockF{
    NSURL *link = [NSURL URLWithString:url];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:link];
    request.timeOutSeconds = 10;
    [request setCompletionBlock:^{
        // Use when fetching text data
        if (blockS) {
            blockS(request);
        }
    }];
    [request setFailedBlock:^{
        if (blockF) {
            blockF();
        }
    }];
    [request startAsynchronous];
    
    return request;
}
@end
