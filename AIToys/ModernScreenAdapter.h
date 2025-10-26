//
//  ModernScreenAdapter.h
//  AIToys
//
//  现代化屏幕适配解决方案
//

#ifndef ModernScreenAdapter_h
#define ModernScreenAdapter_h

#import <UIKit/UIKit.h>

// MARK: - 安全区域相关
/**
 * 获取当前窗口的安全区域
 * 兼容 iOS 11+ 和旧版本
 */
static inline UIEdgeInsets SafeAreaInsets(void) {
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        if (!window) {
            // 尝试从场景获取窗口 (iOS 13+)
            if (@available(iOS 13.0, *)) {
                NSSet<UIScene *> *scenes = [UIApplication sharedApplication].connectedScenes;
                for (UIScene *scene in scenes) {
                    if ([scene isKindOfClass:[UIWindowScene class]]) {
                        UIWindowScene *windowScene = (UIWindowScene *)scene;
                        window = windowScene.windows.firstObject;
                        break;
                    }
                }
            }
        }
        return window.safeAreaInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}

// MARK: - 屏幕尺寸相关
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

// 状态栏高度 (兼容刘海屏)
#define STATUS_BAR_HEIGHT (SafeAreaInsets().top ?: 20.0f)

// 导航栏高度 (不包含状态栏)
#define NAVIGATION_BAR_HEIGHT (44.0f)

// 导航栏总高度 (包含状态栏)
#define NAVIGATION_TOTAL_HEIGHT (STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT)

// 底部安全区域高度
#define BOTTOM_SAFE_AREA_HEIGHT (SafeAreaInsets().bottom)

// TabBar 总高度 (包含底部安全区域)
#define TABBAR_TOTAL_HEIGHT (49.0f + BOTTOM_SAFE_AREA_HEIGHT)

// MARK: - 设备类型判断 (基于安全区域，更准确)
#define IS_NOTCH_SCREEN (SafeAreaInsets().bottom > 0.0f)
#define IS_REGULAR_SCREEN (!IS_NOTCH_SCREEN)

// MARK: - 现代化尺寸适配
/**
 * 基于设计稿的比例适配 (推荐使用 Auto Layout 替代)
 * 默认以 iPhone 12 Pro (390pt) 为基准
 */
#define DESIGN_WIDTH (390.0f)
#define DESIGN_HEIGHT (844.0f)

// 宽度适配
#define ScaleWidth(width) ((SCREEN_WIDTH / DESIGN_WIDTH) * (width))

// 高度适配 (通常字体大小不建议等比缩放)
#define ScaleHeight(height) ((SCREEN_HEIGHT / DESIGN_HEIGHT) * (height))

// 字体大小适配 (建议使用动态字体)
#define ScaleFont(fontSize) ((SCREEN_WIDTH / DESIGN_WIDTH) * (fontSize))

// MARK: - 便捷宏定义
// View 坐标相关
#define ViewX(view) ((view).frame.origin.x)
#define ViewY(view) ((view).frame.origin.y)
#define ViewWidth(view) ((view).frame.size.width)
#define ViewHeight(view) ((view).frame.size.height)
#define ViewMaxX(view) (CGRectGetMaxX((view).frame))
#define ViewMaxY(view) (CGRectGetMaxY((view).frame))
#define ViewMidX(view) (CGRectGetMidX((view).frame))
#define ViewMidY(view) (CGRectGetMidY((view).frame))

// MARK: - 颜色适配 (支持深色模式)
#define UIColorHex(hex) [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0f \
                                        green:((hex >> 8) & 0xFF) / 255.0f \
                                         blue:(hex & 0xFF) / 255.0f \
                                        alpha:1.0f]

// 动态颜色 (支持深色模式)
#define UIColorDynamic(lightColor, darkColor) \
    ({UIColor *color; \
    if (@available(iOS 13.0, *)) { \
        color = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) { \
            return traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? darkColor : lightColor; \
        }]; \
    } else { \
        color = lightColor; \
    } \
    color;})

// MARK: - 日志宏 (开发/发布版本区分)
#ifdef DEBUG
    #define DebugLog(fmt, ...) NSLog(@"[DEBUG] %s:%d " fmt, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
    #define DebugLog(fmt, ...) do {} while (0)
#endif

// MARK: - 弱引用宏
#define WeakSelf __weak typeof(self) weakSelf = self
#define StrongSelf __strong typeof(weakSelf) strongSelf = weakSelf

// MARK: - 版本判断
#define iOS_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])
#define iOS_AVAILABLE(version) (iOS_VERSION >= version)

#endif /* ModernScreenAdapter_h */