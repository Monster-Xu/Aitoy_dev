// SkeletonTableViewCell.h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SkeletonCellStyle) {
    SkeletonCellStyleDefault,      // 默认样式
    SkeletonCellStyleWithAvatar,   // 带头像的样式
    SkeletonCellStyleDetail        // 详情样式
};

@interface SkeletonTableViewCell : UITableViewCell

// 初始化方法
- (instancetype)initWithStyle:(SkeletonCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

// 开始/停止动画
- (void)startSkeletonAnimation;
- (void)stopSkeletonAnimation;

// 配置不同样式的鱼骨效果
- (void)configureWithStyle:(SkeletonCellStyle)style;

@end

NS_ASSUME_NONNULL_END
