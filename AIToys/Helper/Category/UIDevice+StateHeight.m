//
//  UIDevice+StateHeight.m
//  HelloBrother
//
//  Created by 乔不赖 on 2024/1/17.
//

#import "UIDevice+StateHeight.h"

@implementation UIDevice (StateHeight)
// 顶部安全区高度

+ (CGFloat)dev_safeDistanceTop {

if (@available(iOS 13.0, *)) {

NSSet *set = [UIApplication sharedApplication].connectedScenes;

UIWindowScene *windowScene = [set anyObject];

UIWindow *window = windowScene.windows.firstObject;

return window.safeAreaInsets.top;

} else if (@available(iOS 11.0, *)) {

UIWindow *window = [UIApplication sharedApplication].windows.firstObject;

return window.safeAreaInsets.top;

}

return 0;

}

// 底部安全区高度

+ (CGFloat)dev_safeDistanceBottom {

if (@available(iOS 13.0, *)) {

NSSet *set = [UIApplication sharedApplication].connectedScenes;

UIWindowScene *windowScene = [set anyObject];

UIWindow *window = windowScene.windows.firstObject;

return window.safeAreaInsets.bottom;

} else if (@available(iOS 11.0, *)) {

UIWindow *window = [UIApplication sharedApplication].windows.firstObject;

return window.safeAreaInsets.bottom;

}

return 0;

}

//顶部状态栏高度（包括安全区）

+ (CGFloat)dev_statusBarHeight {

if (@available(iOS 13.0, *)) {

NSSet *set = [UIApplication sharedApplication].connectedScenes;

UIWindowScene *windowScene = [set anyObject];

UIStatusBarManager *statusBarManager = windowScene.statusBarManager;

return statusBarManager.statusBarFrame.size.height;

} else {

return [UIApplication sharedApplication].statusBarFrame.size.height;

}

}

// 导航栏高度

+ (CGFloat)dev_navigationBarHeight {

return 44.0f;

}

// 状态栏+导航栏的高度

+ (CGFloat)dev_navigationFullHeight {

return [UIDevice dev_statusBarHeight] + [UIDevice dev_navigationBarHeight];

}

// 底部导航栏高度

+ (CGFloat)dev_tabBarHeight {

return 49.0f;

}

// 底部导航栏高度（包括安全区）

+ (CGFloat)dev_tabBarFullHeight {

return [UIDevice dev_statusBarHeight] + [UIDevice dev_safeDistanceBottom];

}
@end
