//
//  UIView+ModernEffects.m
//  AIToys
//
//  Created by Assistant on 2025/10/23.
//  Modern UI effects extension for enhanced visual design
//

#import "UIView+ModernEffects.h"

typedef NS_ENUM(NSInteger, ModernButtonStyle) {
    ModernButtonStylePrimary = 0,
    ModernButtonStyleSecondary = 1,
    ModernButtonStyleDestructive = 2
};

@implementation UIView (ModernEffects)

- (void)applyLiquidGlassEffectWithCornerRadius:(CGFloat)cornerRadius tintColor:(UIColor *)tintColor {
    if (@available(iOS 15.0, *)) {
        // Create blur effect view
        UIBlurEffectStyle style = UIBlurEffectStyleSystemUltraThinMaterial;
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
        
        blurEffectView.frame = self.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blurEffectView.layer.cornerRadius = cornerRadius;
        blurEffectView.clipsToBounds = YES;
        blurEffectView.userInteractionEnabled = NO;
        
        // Insert the blur effect at the back
        [self insertSubview:blurEffectView atIndex:0];
        
        // Apply tint color if provided
        if (tintColor) {
            UIView *tintView = [[UIView alloc] init];
            tintView.backgroundColor = tintColor;
            tintView.frame = blurEffectView.bounds;
            tintView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            tintView.userInteractionEnabled = NO;
            [blurEffectView.contentView addSubview:tintView];
        }
        
        // Apply border and corner radius
        self.layer.cornerRadius = cornerRadius;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
        
    } else {
        // Fallback for iOS < 15
        self.backgroundColor = tintColor ?: [UIColor colorWithWhite:1.0 alpha:0.8];
        self.layer.cornerRadius = cornerRadius;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
    }
}

- (void)applyShadowWithOffset:(CGSize)offset radius:(CGFloat)radius opacity:(float)opacity color:(UIColor *)color {
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowColor = color.CGColor;
    
    // Improve performance by setting shadow path
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius];
    self.layer.shadowPath = shadowPath.CGPath;
}

- (void)addTouchInteractionAnimations {
    // This method should be called on buttons or interactive views
    if ([self isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self;
        [button addTarget:self action:@selector(touchDownAnimation) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(touchUpAnimation) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    }
}

- (void)touchDownAnimation {
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.transform = CGAffineTransformMakeScale(0.95, 0.95);
        self.alpha = 0.8;
    } completion:nil];
}

- (void)touchUpAnimation {
    [UIView animateWithDuration:0.2
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1.0;
    } completion:nil];
}

- (void)applyFrostedGlassBackground {
    if (@available(iOS 15.0, *)) {
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterial]];
        blurEffectView.frame = self.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blurEffectView.userInteractionEnabled = NO;
        
        [self insertSubview:blurEffectView atIndex:0];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.85];
    }
}

- (void)applyCardAppearanceWithCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.clipsToBounds = YES;
    
    // Apply shadow for depth
    [self applyShadowWithOffset:CGSizeMake(0, 2) 
                         radius:8 
                        opacity:0.1 
                          color:[UIColor blackColor]];
    
    // Apply subtle border
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
}

@end

@implementation UIButton (ModernEffects)

- (void)configureWithModernStyle:(NSInteger)style cornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.clipsToBounds = YES;
    
    switch (style) {
        case ModernButtonStylePrimary:
            [self configurePrimaryStyle];
            break;
        case ModernButtonStyleSecondary:
            [self configureSecondaryStyle];
            break;
        case ModernButtonStyleDestructive:
            [self configureDestructiveStyle];
            break;
    }
    
    // Add touch interactions
    [self addTouchInteractionAnimations];
}

- (void)configurePrimaryStyle {
    if (@available(iOS 15.0, *)) {
        [self applyLiquidGlassEffectWithCornerRadius:self.layer.cornerRadius 
                                           tintColor:[UIColor systemBlueColor]];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        // Add glow effect
        [self applyShadowWithOffset:CGSizeMake(0, 2) 
                             radius:8 
                            opacity:0.3 
                              color:[UIColor systemBlueColor]];
    } else {
        self.backgroundColor = [UIColor systemBlueColor];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)configureSecondaryStyle {
    if (@available(iOS 15.0, *)) {
        [self applyLiquidGlassEffectWithCornerRadius:self.layer.cornerRadius 
                                           tintColor:[UIColor colorWithWhite:1.0 alpha:0.1]];
        [self setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor systemBlueColor].CGColor;
    } else {
        self.backgroundColor = [UIColor whiteColor];
        [self setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [UIColor systemBlueColor].CGColor;
    }
}

- (void)configureDestructiveStyle {
    if (@available(iOS 15.0, *)) {
        [self applyLiquidGlassEffectWithCornerRadius:self.layer.cornerRadius 
                                           tintColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1]];
        [self setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
        
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor systemRedColor].CGColor;
    } else {
        self.backgroundColor = [UIColor whiteColor];
        [self setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [UIColor systemRedColor].CGColor;
    }
}

@end