//
//  UIView+ModernEffects.h
//  AIToys
//
//  Created by Assistant on 2025/10/23.
//  Modern UI effects extension for enhanced visual design
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ModernEffects)

/// Applies modern Liquid Glass effect to the view
/// @param cornerRadius Corner radius for the glass effect
/// @param tintColor Optional tint color for the glass effect
- (void)applyLiquidGlassEffectWithCornerRadius:(CGFloat)cornerRadius tintColor:(nullable UIColor *)tintColor;

/// Applies subtle shadow effect for depth
/// @param offset Shadow offset
/// @param radius Shadow radius
/// @param opacity Shadow opacity
/// @param color Shadow color
- (void)applyShadowWithOffset:(CGSize)offset radius:(CGFloat)radius opacity:(float)opacity color:(UIColor *)color;

/// Adds interactive touch animations
- (void)addTouchInteractionAnimations;

/// Applies frosted glass background effect
- (void)applyFrostedGlassBackground;

/// Applies modern card-like appearance with shadow and corner radius
/// @param cornerRadius Corner radius for the card
- (void)applyCardAppearanceWithCornerRadius:(CGFloat)cornerRadius;

@end

@interface UIButton (ModernEffects)

/// Configures button with modern glass button style
/// @param style Primary, secondary, or destructive style
/// @param cornerRadius Corner radius for the button
- (void)configureWithModernStyle:(NSInteger)style cornerRadius:(CGFloat)cornerRadius;

@end

NS_ASSUME_NONNULL_END