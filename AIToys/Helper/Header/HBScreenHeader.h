//
//  HBScreenHeader.h
//  HelloBrother
//
//  Created by 乔不赖 on 2024/1/15.
//

#ifndef HBScreenHeader_h
#define HBScreenHeader_h

#import "ATFontManager.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define IS_iPhoneX ({\
BOOL IS_iPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
IS_iPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(IS_iPhoneX);\
})

#define VScaleW(w)    ((kScreenWidth/375.0) * w)
#define VScaleH(h)     ((kScreenHeight/667.0) * h)

/* 设置字体的大小 - 使用SF Pro Rounded **/
#define FontThin(size) [ATFontManager systemFontOfSize:size]

/* 设置加粗字体的大小 - 使用SF Pro Rounded **/
#define FontBoldThin(size)  [ATFontManager boldSystemFontOfSize:size]

/********************************** 🇨🇳 导航栏, 状态栏, 标签栏  🇨🇳 **********************************/

// 导航栏(navigationbar) Frame
#define Navigationbar_Frame self.navigationController.navigationBar.frame

// 导航栏的最大高度
#define Nav_Max_Height    CGRectGetMaxY(Navigationbar_Frame);

// 导航栏的当前高度
#define Nav_Current_Height    (CGRectGetHeight(Navigationbar_Frame));

// 状态栏(statusbar) Frame
#define StatusBar_Frame [[UIApplication sharedApplication] statusBarFrame]

// 状态栏的当前高度
#define StatusBar_Current_Height    CGRectGetHeight(StatusBar_Frame);

#define STATUS_BAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height

// 是否为刘海屏
#define IsBang ([[UIApplication sharedApplication] statusBarFrame].size.height >20.f ? YES : NO)

// 适配iPhone x 底栏高度  (49+34)
#define TabBar_Height     ([[UIApplication sharedApplication] statusBarFrame].size.height >20.f ? 83.f : 49.f)

// 状态栏高度
#define    StatusBar_Height    CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)

#define KNavigationBarHeight 44.0

//导航栏 + 状态栏高度
#define    Nav_And_Tabbar_Height    (StatusBar_Height + KNavigationBarHeight)

//标签栏的安全区域距离底部的距离
#define  Tabbar_Safe_BottomMargin        (IS_iPhoneX ? 34.f : 0.f)
#define TabbarSafeBottomMargin  (IS_iPhoneX ? 34.f : 10.f)


#define kuandu(float) [utilOC returnRealWidth:float]
#define gaodu(float) [utilOC returnRealHeight:float]

#pragma mark ---------------------以6为标准

#define SCREEN_WIDTH_IPHONE6 375.0
#define SCREEN_HEIGHT_IPHONE6 667.0
CG_INLINE CGFloat
scale6x(CGFloat x)
{
    CGFloat scalex = (SCREEN_WIDTH / SCREEN_WIDTH_IPHONE6);
    return x*scalex;
}
CG_INLINE CGFloat
scale6y(CGFloat y)
{
    CGFloat scaley = (SCREEN_WIDTH / SCREEN_WIDTH_IPHONE6);//= (SCREEN_HEIGHT / SCREEN_HEIGHT_IPHONE6);
    return y*scaley;
}
CG_INLINE CGRect
RectMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    CGRect rect = CGRectZero;
    
    CGFloat scaleX = (SCREEN_WIDTH / SCREEN_WIDTH_IPHONE6);
//    CGFloat scaleY = (SCREEN_HEIGHT / SCREEN_HEIGHT_IPHONE6);
    CGFloat scaleY = (SCREEN_WIDTH / SCREEN_WIDTH_IPHONE6);
    
    rect.origin.x = x * scaleX;
    rect.origin.y = y * scaleY;
    
    if (width > SCREEN_WIDTH_IPHONE6) {
        width = SCREEN_WIDTH_IPHONE6;
    }
    
    if (height > SCREEN_HEIGHT_IPHONE6) {
        height = SCREEN_HEIGHT_IPHONE6;
    }
    
    rect.size.width = width * scaleX;
    rect.size.height = height * scaleY;
    
    return rect;
}

/********************************** 🇨🇳 View 坐标(x,y)和宽高(width,height)  🇨🇳 **********************************/
#define X(v)                    (v).frame.origin.x
#define Y(v)                    (v).frame.origin.y

#define WIDTH(v)                (v).frame.size.width
#define HEIGHT(v)               (v).frame.size.height

#define MinX(v)                 CGRectGetMinX((v).frame)
#define MinY(v)                 CGRectGetMinY((v).frame)

#define MidX(v)                 CGRectGetMidX((v).frame)
#define MidY(v)                 CGRectGetMidY((v).frame)

#define MaxX(v)                 CGRectGetMaxX((v).frame)
#define MaxY(v)                 CGRectGetMaxY((v).frame)


/********************************** 🇨🇳 沙盒路径 🇨🇳 **********************************/

#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

/********************************** 🇨🇳 加载图片 🇨🇳 **********************************/
#define PNGIMAGE(NAME)          [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(NAME) ofType:@"png"]]
#define JPGIMAGE(NAME)          [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(NAME) ofType:@"jpg"]]
#define IMAGE(NAME, EXT)        [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(NAME) ofType:(EXT)]]


/********************************** 🇨🇳 颜色(RGB) 🇨🇳 **********************************/
#define RGBCOLOR(r, g, b)       [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

/********************************** 🇨🇳 随机颜色 🇨🇳 **********************************/
#define RANDOM_UICOLOR     [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]



/********************************** 🇨🇳 本地化字符串 🇨🇳 **********************************/
/** NSLocalizedString宏做的其实就是在当前bundle中查找资源文件名“Localizable.strings”(参数:键＋注释) */
#define LocalString(x, ...)     NSLocalizedString(x, nil)
/** NSLocalizedStringFromTable宏做的其实就是在当前bundle中查找资源文件名“xxx.strings”(参数:键＋文件名＋注释) */
#define AppLocalString(x, ...)  NSLocalizedStringFromTable(x, @"someName", nil)

/********************************** 🇨🇳 当前语言 🇨🇳 **********************************/
#define CURRENTLANGUAGE         ([[NSLocale preferredLanguages] objectAtIndex:0])




/********************************** 🇨🇳 单例对象定义的宏 🇨🇳 **********************************/
//#define SINGLETON_DEFINE(className) +(className *)shareInstance;
//
//#define SINGLETON_IMPLEMENT(className) \
//static className* _instance = nil; \
//+ (className *) shareInstance{\
//static dispatch_once_t onceToken; \
//dispatch_once(&onceToken,\
//^{ _instance = [[self alloc] init];});\
//return _instance;\
//}\


// .h
#define SINGLETON_INTERFACE(className) +(className *) shared##className;
// .m
#define SINGLETON_IMPLEMENTATION(className)         \
static className *_instance = nil;                        \
                                                \
+(id) allocWithZone : (struct _NSZone *) zone { \
    static dispatch_once_t onceToken;           \
    dispatch_once(&onceToken, ^{                \
        _instance = [super allocWithZone:zone]; \
    });                                         \
                                                \
    return _instance;                           \
}                                               \
                                                \
+ (className *) shared##className{\
static dispatch_once_t onceToken; \
dispatch_once(&onceToken,\
^{ _instance = [[self alloc] init];});\
return _instance;\
}\

/********************************** 🇨🇳 日志打印 🇨🇳 **********************************/
/** 自定义NSLog,在debug模式下打印，在release模式下取消一切NSLog */
#ifdef DEBUG
#define EBNSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#define EBPrintf(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#else
#define EBNSLog(FORMAT, ...) nil
#define EBPrintf(FORMAT, ...) nil
#endif


/********************************** 🇨🇳 修饰 🇨🇳 **********************************/
// __strong修饰
#define STRONGSELF(aa)  __strong  typeof(aa)strong##aa = aa;

// __weak修饰
#define WEAKSELF(aa)  __weak  typeof(aa)weak##aa = aa;
#define WEAK_SELF  __weak  typeof(self)weakSelf = self;


/********************************** 🇨🇳 获取 <系统, app >版本号🇨🇳 **********************************/
// 系统版本号
#define SYSTEMVESION [[[UIDevice currentDevice] systemVersion] floatValue]
// APP版本号
#define APP_VERSION  [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"]

/********************************** 🇨🇳 排序管理 🇨🇳 **********************************/

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending) //不是升序就走

/********************************** 🇨🇳 颜色管理 🇨🇳 **********************************/
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#define UIColorFromRGBA(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:a]

///颜色随机
#define APPRandomColor    [UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:1.0]

//#define LOGIN_BLUE_COLOR [UIColor colorWithRed:0.11 green:0.64 blue:0.94 alpha:1.00];


/********************************** 主题色**********************************/
#define mainColor       UIColorHex(1EAAFD)
#define unEnableColor   UIColorHex(96D9FC)
#define bgViewColor     UIColorHex(FFFFFF)
#define tableBgColor    UIColorHex(F6F7FB)

#define strongTextColor    UIColorFromRGBA(000000, 0.9)
#define generalTextColor   UIColorFromRGBA(000000, 0.5)
#define lightTextColor     UIColorFromRGBA(000000, 0.3)


#define IPHONEX_MARGIN_TOP (88)
#define IPHONEX_MARGIN_BOTTOM (34)

// App Frame
#define Application_Frame       [[UIScreen mainScreen] applicationFrame]

// App Frame Height&Width
#define App_Frame_Height        [[UIScreen mainScreen] applicationFrame].size.height
#define App_Frame_Width         [[UIScreen mainScreen] applicationFrame].size.width

// MainScreen Height&Width
#define Main_Screen_Height      [[UIScreen mainScreen] bounds].size.height
#define Main_Screen_Width       [[UIScreen mainScreen] bounds].size.width


// View 坐标(x,y)和宽高(width,height)
#define X(v)                    (v).frame.origin.x
#define Y(v)                    (v).frame.origin.y

#define WIDTH(v)                (v).frame.size.width
#define HEIGHT(v)               (v).frame.size.height

#define MinX(v)                 CGRectGetMinX((v).frame)
#define MinY(v)                 CGRectGetMinY((v).frame)

#define MidX(v)                 CGRectGetMidX((v).frame)
#define MidY(v)                 CGRectGetMidY((v).frame)

#define MaxX(v)                 CGRectGetMaxX((v).frame)
#define MaxY(v)                 CGRectGetMaxY((v).frame)


#endif /* HBScreenHeader_h */
