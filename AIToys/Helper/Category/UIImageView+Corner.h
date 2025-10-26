//
//  UIImageView+Corner.h
//  CmosLiveUI
//
//  Created by 张海阔 on 2017/12/15.
//  Copyright © 2017年 cmos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Corner)
/**
 贝塞尔曲线切割圆角
 
 @param cornerRadius 圆角半径
 */
- (void)roundedRectImageViewWith:(CGFloat)cornerRadius;

/**
 给imageView设置图片，并改变image的渲染颜色

 @param image 图片
 @param color 渲染颜色
 */
- (void)setImage:(UIImage *)image tintColor:(UIColor *)color;
@end
