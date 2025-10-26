//
//  UIImage+Extension.h
//  StockLine
//
//  Created by 张海阔 on 2019/8/14.
//  Copyright © 2019 ZhangHaiKuo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Extension)
/**
 绘制纯色带圆角的图片
 
 @param size 图片大小
 @param color 图片颜色
 @param cornerRadius 图片圆角
 @return 返回图片
 */
+ (UIImage *)imageWithSize:(CGSize)size color:(UIColor *)color cornRadius:(CGFloat)cornerRadius;

+ (UIImage *)imageWithSize:(CGSize)size
                     color:(UIColor *)color
                cornRadius:(CGFloat)cornerRadius
               borderWidth:(CGFloat)borderWidth
               borderColor:(UIColor *)borderColor;

+ (UIImage *)imageWithColor:(UIColor *)color;

- (UIImage *)imageForThemeColor:(UIColor *)color;
- (UIImage *)imageForThemeColor:(UIColor *)color blendMode:(CGBlendMode)blendMode;
@end

NS_ASSUME_NONNULL_END
