//
//  FontValidationHelper.h
//  AIToys
//
//  Created by AI Assistant on 2025/08/14.
//  Copyright © 2025 AIToys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 字体验证助手
 * 用于验证SF Pro Rounded字体是否正确加载和应用
 */
@interface FontValidationHelper : NSObject

/**
 * 在AppDelegate中调用此方法验证字体
 * 建议在application:didFinishLaunchingWithOptions:中调用
 */
+ (void)validateFontsInAppDelegate;

/**
 * 验证指定视图控制器中的字体使用情况
 * @param viewController 要验证的视图控制器
 */
+ (void)validateFontsInViewController:(UIViewController *)viewController;

/**
 * 验证指定视图及其子视图的字体使用情况
 * @param view 要验证的视图
 */
+ (void)validateFontsInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
