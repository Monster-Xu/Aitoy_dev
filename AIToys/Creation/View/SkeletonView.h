// SkeletonView.h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SkeletonView : UIView

// 开始动画
- (void)startAnimating;
// 停止动画
- (void)stopAnimating;
// 设置鱼骨效果的颜色
@property (nonatomic, strong) UIColor *skeletonColor;
// 设置动画颜色
@property (nonatomic, strong) UIColor *highlightColor;

@end

NS_ASSUME_NONNULL_END
