//
//  UIDevice+StateHeight.h
//  HelloBrother
//
//  Created by 乔不赖 on 2024/1/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (StateHeight)
/** 顶部安全区高度 **/

+ (CGFloat)dev_safeDistanceTop;

/** 底部安全区高度 **/

+ (CGFloat)dev_safeDistanceBottom;

/** 顶部状态栏高度（包括安全区） **/

+ (CGFloat)dev_statusBarHeight;

/** 导航栏高度 **/

+ (CGFloat)dev_navigationBarHeight;

/** 状态栏+导航栏的高度 **/

+ (CGFloat)dev_navigationFullHeight;

/** 底部导航栏高度 **/

+ (CGFloat)dev_tabBarHeight;

/** 底部导航栏高度（包括安全区） **/

+ (CGFloat)dev_tabBarFullHeight;
@end

NS_ASSUME_NONNULL_END
