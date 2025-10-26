//
//  ATFontManager.h
//  AIToys
//
//  Created by AI Assistant on 2025/08/14.
//  Copyright © 2025 AIToys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * SF Pro Rounded字体管理器
 * 提供统一的字体访问接口，支持不同粗细程度的字体映射
 */
@interface ATFontManager : NSObject

#pragma mark - 字体名称常量
extern NSString * const kSFProRoundedRegular;    // SFProRoundedRegular
extern NSString * const kSFProRoundedMedium;     // SFProRoundedMedium
extern NSString * const kSFProRoundedBold;       // SFProRoundedBold
extern NSString * const kSFProRoundedHeavy;      // SFProRoundedHeavy

#pragma mark - 主要字体获取方法

/**
 * 获取常规字体
 * @param size 字体大小
 * @return SF Pro Rounded Regular字体
 */
+ (UIFont *)regularFontWithSize:(CGFloat)size;

/**
 * 获取中等粗细字体
 * @param size 字体大小
 * @return SF Pro Rounded Medium字体
 */
+ (UIFont *)mediumFontWithSize:(CGFloat)size;

/**
 * 获取粗体字体
 * @param size 字体大小
 * @return SF Pro Rounded Bold字体
 */
+ (UIFont *)boldFontWithSize:(CGFloat)size;

/**
 * 获取重磅字体
 * @param size 字体大小
 * @return SF Pro Rounded Heavy字体
 */
+ (UIFont *)heavyFontWithSize:(CGFloat)size;

#pragma mark - 系统字体替换方法

/**
 * 替换系统字体
 * @param size 字体大小
 * @return SF Pro Rounded Regular字体
 */
+ (UIFont *)systemFontOfSize:(CGFloat)size;

/**
 * 替换系统粗体字体
 * @param size 字体大小
 * @return SF Pro Rounded Bold字体
 */
+ (UIFont *)boldSystemFontOfSize:(CGFloat)size;

/**
 * 根据权重获取字体
 * @param size 字体大小
 * @param weight 字体权重
 * @return 对应权重的SF Pro Rounded字体
 */
+ (UIFont *)systemFontOfSize:(CGFloat)size weight:(UIFontWeight)weight;

#pragma mark - 便捷方法

/**
 * 根据字体名称获取对应的SF Pro Rounded字体
 * @param fontName 原字体名称
 * @param size 字体大小
 * @return 映射后的SF Pro Rounded字体
 */
+ (UIFont *)mappedFontWithName:(NSString *)fontName size:(CGFloat)size;

/**
 * 验证字体是否正确加载
 * @return 是否所有字体都正确加载
 */
+ (BOOL)validateFontsLoaded;

/**
 * 打印所有可用的字体信息（调试用）
 */
+ (void)printAvailableFonts;

@end

NS_ASSUME_NONNULL_END
