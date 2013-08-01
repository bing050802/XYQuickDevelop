//
//  XYFunction.h
//  TWP_SkyBookShelf
//
//  Created by Heaven on 13-7-10.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <objc/runtime.h>

#import "XYPrecompile.h"

// 第三方支持
#if defined (__USED_FMDatabase____) && __USED_FMDatabase__
#import "FMDatabase.h"
#endif

#if defined (__USED_MBProgressHUD__) && __USED_MBProgressHUD__
#import "MBProgressHUD.h"
#endif
@class MBProgressHUD;

#if defined (__USED_ASIHTTPRequest__) && __USED_ASIHTTPRequest__
#import "ASIHTTPRequest.h"
#endif
@class ASIHTTPRequest;


/****************************************************************/
/** 移魂大法
 * api parameters 说明
 * c 类
 * original 原方法
 * replacement 劫持后的方法
 */
static void XY_swizzleInstanceMethod(Class c, SEL original, SEL replacement) {
    Method a = class_getInstanceMethod(c, original);
    Method b = class_getInstanceMethod(c, replacement);
    if (class_addMethod(c, original, method_getImplementation(b), method_getTypeEncoding(b)))
    {
        class_replaceMethod(c, replacement, method_getImplementation(a), method_getTypeEncoding(a));
    }
    else
    {
        method_exchangeImplementations(a, b);
    }
}

/********************************           Common          *****************/
@interface Common : NSObject{
 
}
/***************************************************************/
#define kCommon_dataFilePath_documents 1
#define kCommon_dataFilePath_tmp 2
#define kCommon_dataFilePath_app 3
// 返回文件路径的方法
/*
 * api parameters 说明
 *
 * file 文件名
 * kType 文件所在目录类型. kCommon_dataFilePath_documents documents文件夹里,kCommon_dataFilePath_tmp Tmp文件夹里,kCommon_dataFilePath_app app文件夹里.
 */
+ (NSString *) dataFilePath:(NSString *)file ofType:(int)kType;

/***************************************************************/
// Unicode格式的字符串编码转成中文的方法(如\u7E8C)转换成中文,unicode编码以\u开头
/*
 * api parameters 说明
 *
 * unicodeStr 需要被转的字符串
 */
+ (NSString *) replaceUnicode:(NSString *)unicodeStr;

/***************************************************************/
#define kCommon_rangeOfString_middle 1
#define kCommon_rangeOfString_front  2
#define kCommon_rangeOfString_back   3
// 返回字符串的位置的方法
/* rangeOfString:返回range. rangeArrayOfString:返回range数组
 * api parameters 说明
 *
 * str 在str中查找
 * iStart 查找起始位置
 * strMark 需要查找的字符串的标记
 * strStart 起始标记
 * strEnd 结束标记
 * operation 模式. kCommon_rangeOfString_middle mark在Start和end中间,当Start=mark时,返回 Start和end中间的Range
 *                kCommon_rangeOfString_front: mark在Start和end前面   kCommon_rangeOfString_back: mark在Start和end后面
 * block 每一个字符串都执行该block
 */
+(NSRange) rangeOfString:(NSString *)str pointStart:(int)iStart start:(NSString *)strStart end:(NSString *)strEnd mark:(NSString *)strMark operation:(int)operation;
+(NSMutableArray *) rangeArrayOfString:(NSString *)str pointStart:(int)iStart start:(NSString *)strStart end:(NSString *)strEnd mark:(NSString *)strMark operation:(int)operation;
+(NSMutableArray *) rangeArrayOfString:(NSString *)str pointStart:(int)iStart start:(NSString *)strStart end:(NSString *)strEnd mark:(NSString *)strMark operation:(int)operation everyStringExecuteBlock:(void(^)(NSRange rangeEvery))block;
/***************************************************************/
#define kLastLocation -1
// 返回没有属性的xml中指定节点的值的方法
/*
 * api parameters 说明
 *
 * str xml字符串
 * akey 节点名
 * location 起始位置
 * operation 模式. kLastLocation 从上次结束的位置开始查找,提高效率
 */
+(NSString *) getValueInANonAttributeXMLNode:(NSString *)str key:(NSString *)akey location:(int)location;
/***************************************************************/
//切图

/***************************************************************/
// 提取视图层次结构的方法
/*
 * api parameters 说明
 *
 * aView 要提取的视图
 * indent 层次 请给0值
 * outstring 保存层次的字符串
 */
+(void) dumpView: (UIView *) aView atIndent: (int) indent into:(NSMutableString *)outstring;
// 打印视图层次结构
+ (NSString *) displayViews: (UIView *) aView;

/***************************************************************/
// 正则表达式分析字符串的方法
/* analyseString:返回NSString数组. analyseStringToRange:返回range数组
 * api parameters 说明
 *
 * str 被分析的字符串
 * regexStr 用于分析str的正则表达式 (.|[\r\n])*? 表示任何多个字符，包括换行符，懒惰扫描
 * (已取消)options 匹配选项使用
 */
+ (NSMutableArray *) analyseString:(NSString *)str regularExpression:(NSString *)regexStr;
+ (NSMutableArray *) analyseStringToRange:(NSString *)str regularExpression:(NSString *)regexStr;
/***************************************************************/
// 返回目下所有给定后缀的文件的方法
/*
 * api parameters 说明
 *
 * direString 目录绝对路径
 * fileType 文件后缀名
 * operation (预留,暂时没用)
 */
+ (NSMutableArray *) allFilesAtPath:(NSString *)direString type:(NSString*)fileType operation:(int)operation;

#pragma mark -分享facebook,发email待完善
/***************************************************************/
// 分享至Twitter的方法
/*
 * api parameters 说明
 *
 * strText 需要分享的文字
 * picPath 图片路径
 * strURL URL地址
 * vc Twitter的父视图控制器,目前版本请用nil,默认为[UIApplication sharedApplication].delegate.window.rootViewControlle
 */
+(void) shareToTwitterWithStr:(NSString *)strText withPicPath:(NSString *)picPath withURL:(NSString*)strURL inController:(id)vc;

/***************************************************************/
// 得到对象的属性名字列表
/*
 * api parameters 说明
 *
 * aObject 类对象
 */
+(NSArray *) getPropertyListClass:(id)aObject;
/****************************************************************/
// 显示,关闭活动指示器
/*
 * api parameters 说明
 *
 * b YES开,NO关
 */
+(void) activityShow:(BOOL)b;
/****************************************************************/
// 返回sha1
/*
 * api parameters 说明
 *
 * str 源string
 */
+(NSString *) sha1:(NSString*)str;
/****************************************************************/
// 用打开一个URL
/*
 * api parameters 说明
 *
 * url http:// 浏览器, mailto:// 邮件, tel:// 拨号, sms: 短信
 */
+(void) openURL:(NSURL *)url;

/****************************************************************/
#if defined (__USED_FMDatabase____) && __USED_FMDatabase__
/** 更新表结构
 * api parameters 说明
 * tableName 表明, dbPath 数据库路径, aObject 实体对象
 */
+ (BOOL) updateTable:(NSString *)tableName dbPath:(NSString *)dbPath object:(id)aObject;
#endif
/****************************************************************/
/** 得到当前 UIViewController
 * api parameters 说明
 *
 */
+ (UIViewController *) getCurrentViewController;

/****************************************************************/
#if defined (__USED_MBProgressHUD__) && __USED_MBProgressHUD__
/** 显示MBProgressHUD指示器
 * api parameters 说明
 * aTitle 标题
 * aMsg 信息
 * aImg 图片, 为nil时,只显示标题
 * d 延时消失时间
 * blockE 执行的代码快
 * blockF 结束时的代码块
 * 执行时改变hub需要调用Common_MainFun(aFun)
 */
#define SHOWMBProgressHUD(aTitle, aMsg, aImg, aDimBG, aDelay) [Common showMBProgressHUDTitle:aTitle msg:aMsg image:aImg dimBG:aDimBG delay:aDelay];
+(void) showMBProgressHUDTitle:(NSString *)aTitle msg:(NSString *)aMsg image:(UIImage *)aImg dimBG:(BOOL)dimBG delay:(float)d;
+(void) showMBProgressHUDTitle:(NSString *)aTitle msg:(NSString *)aMsg dimBG:(BOOL)dimBG executeBlock:(void(^)(MBProgressHUD *hud))blockE finishBlock:(void(^)(void))blockF;
#endif
/***************************************************************/
// 显示UIAlertView
/*
 * api parameters 说明
 *
 * aTitle msg标题
 * msg 信息
 * strCancel 取消按钮标题
 */
#define SHOWMSG(a, b, c) [Common showAlertViewTitle:a message:b cancelButtonTitle:c]
+(void) showAlertViewTitle:(NSString *)aTitle message:(NSString *)msg cancelButtonTitle:(NSString *)strCancel;

/****************************************************************/
/** NSDate to NSString
 * api parameters 说明
 */
+(NSString *) getStringFromDate:(NSDate *)date;
/****************************************************************/
/** NSString to NSDate
 * api parameters 说明
 */
+(NSDate *) getDateFromString:(NSString *)string;
/****************************************************************/
/**
 * 替换string里面的单引号'为2个单引号'',用于处理SQL问题
 */
+(NSString *) StringForSQL:(NSString *)str;
/****************************************************************/
/** 返回本机ip
 * api parameters 说明
 *
 */
+(NSString *) getLocalHost;
/****************************************************************/
#if defined (__USED_ASIHTTPRequest__) && __USED_ASIHTTPRequest__
/** 开启一个异步请求
 * api parameters 说明
 * url
 * blockS 成功的代码块
 * blockF 失败的代码块
 */
+(ASIHTTPRequest *) startAsynchronousRequestWithURLString:(NSString *)str
                                                  succeed:(void (^)(ASIHTTPRequest *request))blockS
                                                   failed:(void (^)(NSError *error))blockF;
#endif
/****************************************************************/
/** 打印内存情况
 * api parameters 说明
 * mark 标记
 */
+(void) printUsedAndFreeMemoryWithMark:(NSString *)mark;
#pragma mark - 背景不是最上层
/****************************************************************/
/** 显示,移除 遮罩背景
 * api parameters 说明
 * mark 标记
 
+(void) showBackgroundView;
+(void) removeBackgroundView;
 */
//+(UIView *) setBackgroundViewHidden:(BOOL)b;
/****************************************************************/
#if defined (__USED_ASIHTTPRequest__) && __USED_ASIHTTPRequest__
/** 检查软件更新
 * api parameters 说明
 * appID 应用程序ID
 * aVersion 当前版本号 (nil 默认为CFBundleVersion)
 * link 应用程序链接,选择升级则跳转
 * blockstayStill 选择不升级的代码块
 * blockSame 版本相同的 的代码快 (如无网络也调用)
 * blocklocalIsOld 本地是旧的版本代码块
 */
// 有提示框弹出
+(void) checkUpdateInAppStore:(NSString *)appID curVersion:(NSString *)aVersion appURLString:(NSString *)strURL
                         same:(void(^)(void))blockSame
                    stayStill:(void(^)(void))blockstayStill;
// 需要自己处理弹出对话框
+(void) checkUpdateInAppStore:(NSString *)appID curVersion:(NSString *)aVersion
                         same:(void(^)(void))blockSame
                   localIsOld:(void(^)(NSString *appStoreVersion))blocklocalIsOld;
#endif
/****************************************************************/
/** 版本号比大小
 * api parameters 说明
 * 比较oldVersion和newVersion，如果oldVersion比newVersion旧，则返回YES，否则NO
 * Version format[X.X.X]
 */
+(BOOL) compareVersionFromOldVersion:(NSString *)oldVersion newVersion:(NSString *)newVersion;
/****************************************************************/
#pragma mark - to do
/** objc to dictionary
 * api parameters 说明
 * aObject 对象
 */
+(NSMutableDictionary *) dictionaryOfObject:(id)aObject;

@end
