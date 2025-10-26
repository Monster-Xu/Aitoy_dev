//
//  RadarView.h
//  AIToys
//
//  Created by qdkj on 2025/6/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RadarView : UIView
typedef NS_ENUM(NSInteger, RadarViewType) {
    RadarViewTypeScan,
    RadarViewTypeDiffuse
};

/** 雷达 空心圆圈的颜色 */
@property (nonatomic, strong) UIColor * radarLineColor;
/** 扇形开始颜色 必须由RGBA值初始化
 *  [UIColor colorWithRed: green: blue: alpha:]
 */
@property (nonatomic, strong) UIColor * startColor;
/** 扇形结束颜色 必须由RGBA值初始化
 *  [UIColor colorWithRed: green: blue: alpha:]
 */
@property (nonatomic, strong) UIColor * endColor;
 
/**
 *
 *  @param radius       半径
 *  @param angle        角度
 *  @param radarLineNum 雷达线数量
 *  @param hollowRadius 空心圆半径
 *
 *  @return 扫描 雷达 View
 */
+ (RadarView *)scanRadarViewWithRadius:(CGFloat)radius
                                 angle:(int)angle
                          radarLineNum:(int)radarLineNum
                          hollowRadius:(CGFloat)hollowRadius;
 
 
/**
 *
 *  @param startRadius 扩散圆 起始的半径
 *  @param endRadius   扩散圆 消失的半径
 *  @param circleColor 扩散圆 的颜色
 *
 *  @return 扩散 雷达 View
 */
+ (RadarView *)diffuseRadarViewWithStartRadius:(CGFloat)startRadius
                                     endRadius:(CGFloat)endRadius
                                   circleColor:(UIColor *)circleColor;
 
/**
 *  展示在targerView上
 *
 *  @param targerView <#targerView description#>
 */
- (void)showTargetView:(UIView *)targerView;
 
- (void)dismiss;
 
/** 开始扫描动画 */
- (void)startAnimatian;
 
/** 停止扫描动画 */
- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
