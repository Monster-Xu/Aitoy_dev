//
//  ATFontManager.m
//  AIToys
//
//  Created by AI Assistant on 2025/08/14.
//  Copyright © 2025 AIToys. All rights reserved.
//

#import "ATFontManager.h"
#import <CoreText/CoreText.h>

// 字体名称常量 - 基于实际字体文件的 PostScript 名称
NSString * const kSFProRoundedRegular = @"SFProRoundedRegular";
NSString * const kSFProRoundedMedium = @"SFProRoundedMedium";
NSString * const kSFProRoundedBold = @"SFProRoundedBold";
NSString * const kSFProRoundedHeavy = @"SFProRoundedHeavy";

@implementation ATFontManager

#pragma mark - 私有方法

+ (UIFont *)fontWithPossibleNames:(NSArray<NSString *> *)possibleNames size:(CGFloat)size fallback:(UIFont *)fallback {
    for (NSString *fontName in possibleNames) {
        UIFont *font = [UIFont fontWithName:fontName size:size];
        if (font) {
            return font;
        }
    }
    return fallback;
}

#pragma mark - 主要字体获取方法

+ (UIFont *)regularFontWithSize:(CGFloat)size {
    // 使用正确的 PostScript 字体名称
    NSArray *possibleNames = @[
        kSFProRoundedRegular,  // SFProRoundedRegular
        @"SFProRoundedRegular",
        @"SF Pro Rounded Regular",
        @"SF Pro Rounded"
    ];
    return [self fontWithPossibleNames:possibleNames size:size fallback:[UIFont systemFontOfSize:size]];
}

+ (UIFont *)mediumFontWithSize:(CGFloat)size {
    NSArray *possibleNames = @[
        kSFProRoundedMedium,  // SFProRoundedMedium
        @"SFProRoundedMedium",
        @"SF Pro Rounded Medium"
    ];
    return [self fontWithPossibleNames:possibleNames size:size fallback:[UIFont systemFontOfSize:size weight:UIFontWeightMedium]];
}

+ (UIFont *)boldFontWithSize:(CGFloat)size {
    NSArray *possibleNames = @[
        kSFProRoundedBold,  // SFProRoundedBold
        @"SFProRoundedBold",
        @"SF Pro Rounded Bold"
    ];
    return [self fontWithPossibleNames:possibleNames size:size fallback:[UIFont boldSystemFontOfSize:size]];
}

+ (UIFont *)heavyFontWithSize:(CGFloat)size {
    NSArray *possibleNames = @[
        kSFProRoundedHeavy,  // SFProRoundedHeavy
        @"SFProRoundedHeavy",
        @"SF Pro Rounded Heavy"
    ];
    return [self fontWithPossibleNames:possibleNames size:size fallback:[UIFont systemFontOfSize:size weight:UIFontWeightHeavy]];
}

#pragma mark - 系统字体替换方法

+ (UIFont *)systemFontOfSize:(CGFloat)size {
    return [self regularFontWithSize:size];
}

+ (UIFont *)boldSystemFontOfSize:(CGFloat)size {
    return [self boldFontWithSize:size];
}

+ (UIFont *)systemFontOfSize:(CGFloat)size weight:(UIFontWeight)weight {
    if (weight <= UIFontWeightUltraLight) {
        return [self regularFontWithSize:size];
    } else if (weight <= UIFontWeightLight) {
        return [self regularFontWithSize:size];
    } else if (weight <= UIFontWeightRegular) {
        return [self regularFontWithSize:size];
    } else if (weight <= UIFontWeightMedium) {
        return [self mediumFontWithSize:size];
    } else if (weight <= UIFontWeightSemibold) {
        return [self boldFontWithSize:size];
    } else if (weight <= UIFontWeightBold) {
        return [self boldFontWithSize:size];
    } else {
        return [self heavyFontWithSize:size];
    }
}

#pragma mark - 便捷方法

+ (UIFont *)mappedFontWithName:(NSString *)fontName size:(CGFloat)size {
    if (!fontName || fontName.length == 0) {
        return [self regularFontWithSize:size];
    }
    
    NSString *lowerFontName = [fontName lowercaseString];
    
    // 检查是否已经是SF Pro Rounded字体
    if ([lowerFontName containsString:@"sf-pro-rounded"]) {
        UIFont *font = [UIFont fontWithName:fontName size:size];
        return font ?: [self regularFontWithSize:size];
    }
    
    // 映射系统字体
    if ([lowerFontName containsString:@"system"]) {
        if ([lowerFontName containsString:@"bold"]) {
            return [self boldFontWithSize:size];
        } else {
            return [self regularFontWithSize:size];
        }
    }
    
    // 根据字体名称中的关键词映射
    if ([lowerFontName containsString:@"heavy"] || [lowerFontName containsString:@"black"]) {
        return [self heavyFontWithSize:size];
    } else if ([lowerFontName containsString:@"bold"]) {
        return [self boldFontWithSize:size];
    } else if ([lowerFontName containsString:@"semibold"]) {
        return [self boldFontWithSize:size];
    } else if ([lowerFontName containsString:@"medium"]) {
        return [self mediumFontWithSize:size];
    } else {
        return [self regularFontWithSize:size];
    }
}

+ (BOOL)validateFontsLoaded {
    NSArray *fontNames = @[kSFProRoundedRegular, kSFProRoundedMedium, kSFProRoundedBold, kSFProRoundedHeavy];
    
    for (NSString *fontName in fontNames) {
        UIFont *font = [UIFont fontWithName:fontName size:16.0];
        if (!font) {
            NSLog(@"❌ Font not loaded: %@", fontName);
            return NO;
        } else {
            NSLog(@"✅ Font loaded successfully: %@", fontName);
        }
    }
    
    return YES;
}

+ (void)printAvailableFonts {
    NSLog(@"=== Available Font Families ===");
    for (NSString *familyName in [UIFont familyNames]) {
        NSLog(@"Family: %@", familyName);
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            if ([fontName containsString:@"SF-Pro-Rounded"]) {
                NSLog(@"  ✅ %@", fontName);
            }
        }
    }
}

@end
