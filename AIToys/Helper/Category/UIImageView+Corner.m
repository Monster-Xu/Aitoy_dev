//
//  UIImageView+Corner.m
//  CmosLiveUI
//
//  Created by 张海阔 on 2017/12/15.
//  Copyright © 2017年 cmos. All rights reserved.
//

#import "UIImageView+Corner.h"

@implementation UIImageView (Corner)
/**
 贝塞尔曲线切割圆角

 @param cornerRadius 圆角半径
 */
- (void)roundedRectImageViewWith:(CGFloat)cornerRadius
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:cornerRadius];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = bezierPath.CGPath;
    self.layer.mask = layer;
}
/**
 给imageView设置图片，并改变image的渲染颜色
 
 @param image 图片
 @param color 渲染颜色
 */
- (void)setImage:(UIImage *)image tintColor:(UIColor *)color
{
    self.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.tintColor = color;
}


@end
