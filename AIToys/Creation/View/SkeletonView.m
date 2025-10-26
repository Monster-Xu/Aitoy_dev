// SkeletonView.m
#import "SkeletonView.h"

@interface SkeletonView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation SkeletonView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // 默认颜色
    _skeletonColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    _highlightColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
    
    self.containerView = [[UIView alloc] initWithFrame:self.bounds];
    self.containerView.backgroundColor = _skeletonColor;
    [self addSubview:self.containerView];
    
    // 设置渐变层
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.colors = @[
        (id)_skeletonColor.CGColor,
        (id)_highlightColor.CGColor,
        (id)_skeletonColor.CGColor
    ];
    self.gradientLayer.locations = @[@0.0, @0.5, @1.0];
    self.gradientLayer.startPoint = CGPointMake(0, 0.5);
    self.gradientLayer.endPoint = CGPointMake(1, 0.5);
    
    [self.containerView.layer addSublayer:self.gradientLayer];
    
    // 初始隐藏
    self.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.containerView.frame = self.bounds;
    
    // 设置渐变层的大小，比视图宽一些以实现滑动效果
    CGFloat gradientWidth = self.bounds.size.width * 1.5;
    self.gradientLayer.frame = CGRectMake(-gradientWidth * 0.25, 0, gradientWidth, self.bounds.size.height);
    
    // 添加圆角
    self.containerView.layer.cornerRadius = 4.0;
    self.containerView.layer.masksToBounds = YES;
}

- (void)startAnimating {
    if (self.isAnimating) return;
    
    self.isAnimating = YES;
    self.hidden = NO;
    
    // 移除之前的动画
    [self.gradientLayer removeAllAnimations];
    
    // 创建滑动动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
    animation.fromValue = @[@0.0, @0.0, @0.25];
    animation.toValue = @[@0.75, @1.0, @1.0];
    animation.duration = 1.5;
    animation.repeatCount = HUGE_VALF;
    
    [self.gradientLayer addAnimation:animation forKey:@"skeletonAnimation"];
}

- (void)stopAnimating {
    self.isAnimating = NO;
    self.hidden = YES;
    [self.gradientLayer removeAllAnimations];
}

- (void)setSkeletonColor:(UIColor *)skeletonColor {
    _skeletonColor = skeletonColor;
    self.containerView.backgroundColor = skeletonColor;
    [self updateGradientColors];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightColor = highlightColor;
    [self updateGradientColors];
}

- (void)updateGradientColors {
    self.gradientLayer.colors = @[
        (id)_skeletonColor.CGColor,
        (id)_highlightColor.CGColor,
        (id)_skeletonColor.CGColor
    ];
}

@end
