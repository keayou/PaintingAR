//
//  SGUtilsConstantsMacro.h
//  sogousearch
//
//  Created by Dragon on 14-5-29.
//  Copyright (c) 2014年 搜狗. All rights reserved.
//

#ifndef sogousearch_SGConstantsMacro_h
#define sogousearch_SGConstantsMacro_h

#ifndef DEBUG
#define NSLog(...)
#endif

/**
 安全线程唤起函数

 @param block <#block description#>
 @return <#return value description#>
 */
static inline void SGSafeInvokeThread(dispatch_block_t block) {
    
    if ([NSThread isMainThread]) {
        if (block) {
            block();
        }
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (block) {
                block();
            }
        });
    }
}
/********************* 适配宏 *********************/

#if __has_feature(objc_arc)
#define SG_ARC_RELEASE(x)   (x)
#define SG_ARC_RETAIN(x)    (x)
#define SG_ARC_AUTORELEASE(x) (x)
#define SG_ARC_SUPER_DEALLOC()
#else
#define SG_ARC_RELEASE(x) ([(x) release])
#define SG_ARC_RETAIN(x) ([(x) retain])
#define SG_ARC_AUTORELEASE(x) ([(x) autorelease])
#define SG_ARC_SUPER_DEALLOC() ([super dealloc])
#endif


#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
#define BUILD_BASE_IOS7 NO
#else
#define BUILD_BASE_IOS7 YES
#endif

#define GBKEncoding CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)

#define ShouleAdaptForiOS7  (BUILD_BASE_IOS7 && [UIDevice currentDevice].systemVersion.floatValue > 6.99f)
#define isiOS11 (NSFoundationVersionNumber > NSFoundationVersionNumber10_11)
#define isiOS9 (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_3)
#define isiOS8 (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)
#define isiOS7 (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
#define isiOS6 (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_5_1 && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1)

//系统版本判断（iOS10之后）
//等于
#define SYSTEM_VERSION_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
//大于
#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
//大于等于
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
//小于
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
//小于等于
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define ScreenMatchHeight(space) (space * ScreenHeight/667.0)

#define IS_IPAD             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE           (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA           ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH        ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT       ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH   (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH   (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))


#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5         (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6         (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P        (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_X         (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)
#define IS_IPHONE_XR        (IS_IPHONE && SCREEN_MAX_LENGTH == 896.0 && [[UIScreen mainScreen] scale] == 2.0)
#define IS_IPHONE_MAX       (IS_IPHONE && SCREEN_MAX_LENGTH == 896.0 && [[UIScreen mainScreen] scale] == 3.0)

#define IS_NOTCH        (IS_IPHONE_X || IS_IPHONE_XR || IS_IPHONE_MAX)


#define IS_SCREEN_65_INCH   IS_IPHONE_MAX
#define IS_SCREEN_61_INCH   IS_IPHONE_XR
#define IS_SCREEN_58_INCH   IS_IPHONE_X
#define IS_SCREEN_55_INCH   IS_IPHONE_6P
#define IS_SCREEN_47_INCH   IS_IPHONE_6
#define IS_SCREEN_4_INCH    IS_IPHONE_5
#define IS_SCREEN_35_INCH    ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960),  [[UIScreen mainScreen] currentMode].size) : NO)


#define isRetina4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define SGScreen_55_Inch    ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)||CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size)) : NO)
#define SGScreen_47_Inch    ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define SGScreen_4_Inch     ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define SGScreen_35_Inch    ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size)||CGSizeEqualToSize(CGSizeMake(320, 480), [[UIScreen mainScreen] currentMode].size)) : NO)
#define SGScreen_55_Inch_EXP    ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) : NO)
#define  SGScreen_X_Inch  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define  SGScreen_XR_Inch  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
#define  SGScreen_MAX_Inch  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)
#define  SGScreen_MAX_Inch_EXP  SGScreen_X_Inch

#define  SGScreen_320_Width (SGScreen_35_Inch || SGScreen_4_Inch)
#define  SGScreen_375_Width (SGScreen_47_Inch || SGScreen_55_Inch_EXP || SGScreen_X_Inch || SGScreen_MAX_Inch_EXP)
#define  SGScreen_414_Width (SGScreen_55_Inch || SGScreen_XR_Inch || SGScreen_MAX_Inch)

#define SGScreen_isSamll      ([UIScreen mainScreen].currentMode.size.width <= 640 ? YES : NO)

#define SGScaleWidth  (ScreenWidth/320)
#define SGScaleHeight (ScreenHeight/568)

/// 底部margin iphonex 为34 其他为0
#define kViewBottomMargin (IS_NOTCH ? (34.f) :(0.0f))
/// 首页tabbar 高度. iphoneX 为78 其他为45
#define TabBarHeight (IS_NOTCH ? (83.f) :(50.0f))
/// 导航栏高度 44
#define NavigationBarHeight (44.0f)
/// 状态栏高度 iphoneX 为44 其他为20 隐藏状态下为0
#define StatusBarHeight  StatusBarHeightReal //[UIApplication sharedApplication].statusBarFrame.size.height
/// 隐藏状态栏的情况下 也有值
#define StatusBarHeightReal (IS_NOTCH ? (44.f) :(20.0f))
/// 状态栏加导航栏高度 iphoneX 为88, 其他为64
#define NavStatusBarHeight (NavigationBarHeight+StatusBarHeightReal)

// 以4.7寸屏换算比例
#define SGAUTOSIZE(_wid,_hei)   CGSizeMake(_wid * SCREEN_WIDTH / 375.0, _hei * SCREEN_HEIGHT / 667.0)
#define SGAUTOWIDTH(_wid)  _wid * SCREEN_WIDTH / 375.0
#define SGAUTOHEIGHT(_hei) _hei * SCREEN_HEIGHT / 667.0

/********************* 函数宏 *********************/
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
// 快速的定义一个weakSelf，方便之后在block块中调用。
#define WS(weakSelf)  __weak __typeof(&*self) weakSelf = self;

//空替代宏
#define NOTEMPTY_STR(str) (IS_NOEMPTY_STR(str)?str:@"")
#define NOTEMPTY_ARRAY(arr) (IS_NOEMPTY_ARRAY(arr)?arr:[NSArray array])
#define NOTEMPTY_DIC(dic) (IS_NOEMPTY_DIC(dic)?dic:[NSDictionary dictionary])

//可变数组的待添加
//判空宏
#define IS_NOEMPTY_STR(str) (str!=nil&&[str isKindOfClass:[NSString class]]&&[(NSString *)str length]>0)
#define IS_NOEMPTY_ARRAY(arr) (arr!=nil&&[arr isKindOfClass:[NSArray class]]&&[(NSArray *)arr count]>0)
#define IS_NOEMPTY_DIC(dic) (dic!=nil&&[dic isKindOfClass:[NSDictionary class]]&&[(NSDictionary *)dic count]>0)

//delegate 宏，只支持object参数类型
#define DelegateAction(delegate,SEL) DelegateActionOne(delegate,SEL,nil)
#define DelegateActionOne(delegate,SEL,sender) if([delegate respondsToSelector:SEL]) {[delegate performSelector:SEL withObject:sender];}

#define SandBoxDocumentsPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)firstObject]


#define MIN_Scale 1.0/[UIScreen mainScreen].scale

#define ScreenFactor ([UIScreen mainScreen].bounds.size.width/320.0)

#define DeviceFactor(height) ([UIScreen mainScreen].bounds.size.width * height / 375.0)

#endif

