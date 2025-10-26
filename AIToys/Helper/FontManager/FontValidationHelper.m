//
//  FontValidationHelper.m
//  AIToys
//
//  Created by AI Assistant on 2025/08/14.
//  Copyright © 2025 AIToys. All rights reserved.
//

#import "FontValidationHelper.h"
#import "ATFontManager.h"

@implementation FontValidationHelper

+ (void)validateFontsInAppDelegate {
    NSLog(@"=== SF Pro Rounded 字体验证开始 ===");

    // 检查字体文件是否存在
    [self checkFontFilesExistence];

    // 首先打印所有可用的字体族
    [self printAllAvailableFonts];

    // 检查字体文件
    [self tryDynamicFontLoading];

    // 测试Info.plist中的字体注册
    [self testInfoPlistFonts];

    // 验证字体是否正确加载
    BOOL fontsLoaded = [ATFontManager validateFontsLoaded];
    
    if (fontsLoaded) {
        NSLog(@"✅ 所有SF Pro Rounded字体加载成功");
        
        // 打印字体信息
        [ATFontManager printAvailableFonts];
        
        // 测试字体创建
        UIFont *regularFont = [ATFontManager regularFontWithSize:16];
        UIFont *boldFont = [ATFontManager boldFontWithSize:16];
        UIFont *mediumFont = [ATFontManager mediumFontWithSize:16];
        UIFont *boldFont2 = [ATFontManager boldFontWithSize:16];
        UIFont *heavyFont = [ATFontManager heavyFontWithSize:16];
        
        NSLog(@"📝 测试字体创建:");
        NSLog(@"  Regular (16pt): %@", regularFont.fontName);
        NSLog(@"  Bold (16pt): %@", boldFont.fontName);
        NSLog(@"  Medium (16pt): %@", mediumFont.fontName);
        NSLog(@"  Bold2 (16pt): %@", boldFont2.fontName);
        NSLog(@"  Heavy (16pt): %@", heavyFont.fontName);
        
        // 验证字体替换是否正确
        UIFont *systemFont = [ATFontManager systemFontOfSize:16];
        UIFont *boldSystemFont = [ATFontManager boldSystemFontOfSize:16];
        
        NSLog(@"🔄 系统字体替换验证:");
        NSLog(@"  systemFontOfSize:16 -> %@", systemFont.fontName);
        NSLog(@"  boldSystemFontOfSize:16 -> %@", boldSystemFont.fontName);
        
    } else {
        NSLog(@"❌ 部分字体加载失败，请检查字体文件和Info.plist配置");
        NSLog(@"💡 解决方案:");
        NSLog(@"  1. 确认字体文件已正确添加到项目中");
        NSLog(@"  2. 检查Info.plist中的UIAppFonts配置");
        NSLog(@"  3. 确认字体文件路径正确");
        NSLog(@"  4. 重新编译项目");
    }
    
    NSLog(@"=== SF Pro Rounded 字体验证结束 ===");
}

+ (void)checkFontFilesExistence {
    NSLog(@"📁 检查字体文件是否存在:");

    NSArray *fontFiles = @[
        @{@"file": @"SF-Pro-Rounded-Regular", @"ext": @"otf"},
        @{@"file": @"SF-Pro-Rounded-Medium", @"ext": @"ttf"},
        // @{@"file": @"SF-Pro-Rounded-Semibold", @"ext": @"ttf"}, // 已替换为 Bold
        @{@"file": @"SF-Pro-Rounded-Bold", @"ext": @"ttf"},
        @{@"file": @"SF-Pro-Rounded-Heavy", @"ext": @"otf"}
    ];

    for (NSDictionary *fontInfo in fontFiles) {
        NSString *fileName = fontInfo[@"file"];
        NSString *fileExt = fontInfo[@"ext"];

        NSString *fontPath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExt];
        if (fontPath) {
            NSLog(@"  ✅ %@.%@ 存在于: %@", fileName, fileExt, fontPath);

            // 尝试获取文件大小
            NSError *error;
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fontPath error:&error];
            if (attributes) {
                NSNumber *fileSize = attributes[NSFileSize];
                double fileSizeMB = [fileSize doubleValue] / (1024.0 * 1024.0);
                NSLog(@"    📏 文件大小: %.2f MB", fileSizeMB);
            }
        } else {
            NSLog(@"  ❌ %@.%@ 未找到", fileName, fileExt);
        }
    }
}

+ (void)printAllAvailableFonts {
    NSLog(@"=== 所有可用字体族 ===");

    NSArray *fontFamilies = [UIFont familyNames];
    NSMutableArray *sfFonts = [NSMutableArray array];

    for (NSString *familyName in fontFamilies) {
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];

        for (NSString *fontName in fontNames) {
            // 收集所有可能相关的字体
            if ([fontName containsString:@"SF"] ||
                [fontName containsString:@"Pro"] ||
                [fontName containsString:@"Rounded"] ||
                [fontName containsString:@"SFPro"] ||
                [fontName containsString:@"SFUIText"] ||
                [fontName containsString:@"SFUIDisplay"]) {
                [sfFonts addObject:@{@"family": familyName, @"name": fontName}];
            }
        }
    }

    if (sfFonts.count > 0) {
        NSLog(@"🔍 找到 %lu 个相关字体:", (unsigned long)sfFonts.count);
        for (NSDictionary *fontInfo in sfFonts) {
            NSLog(@"  📁 族: %@ -> 字体: %@", fontInfo[@"family"], fontInfo[@"name"]);
        }
    } else {
        NSLog(@"❌ 未找到SF Pro相关字体");
    }

    // 尝试测试一些常见的字体名称
    [self testCommonFontNames];

    NSLog(@"=== 字体族打印完成 ===");
}

+ (void)testCommonFontNames {
    NSLog(@"🧪 测试常见字体名称:");

    NSArray *testNames = @[
        @"SFProRounded-Regular",
        @"SF Pro Rounded Regular",
        @"SFProRounded",
        @"SF-Pro-Rounded-Regular",
        @"SFProRounded-400",
        @"SF Pro Rounded",
        @"SFProRounded-Bold",
        @"SF Pro Rounded Bold",
        @"SFProRounded-700",
        @"SFProRounded-Medium",
        @"SF Pro Rounded Medium",
        @"SFProRounded-500",
        @"SFProRounded-Semibold",
        @"SF Pro Rounded Bold",
        @"SFProRounded-600",
        @"SFProRounded-Heavy",
        @"SF Pro Rounded Heavy",
        @"SFProRounded-800"
    ];

    for (NSString *fontName in testNames) {
        UIFont *font = [UIFont fontWithName:fontName size:16.0];
        if (font) {
            NSLog(@"  ✅ 成功: %@ -> 实际字体: %@", fontName, font.fontName);
        } else {
            NSLog(@"  ❌ 失败: %@", fontName);
        }
    }
}

+ (void)tryDynamicFontLoading {
    NSLog(@"🔄 检查字体文件并尝试简单加载:");

    NSArray *fontFiles = @[
        @{@"file": @"SF-Pro-Rounded-Regular", @"ext": @"otf", @"weight": @"Regular"},
        @{@"file": @"SF-Pro-Rounded-Medium", @"ext": @"ttf", @"weight": @"Medium"},
        // @{@"file": @"SF-Pro-Rounded-Semibold", @"ext": @"ttf", @"weight": @"Semibold"}, // 已替换为 Bold
        @{@"file": @"SF-Pro-Rounded-Bold", @"ext": @"ttf", @"weight": @"Bold"},
        @{@"file": @"SF-Pro-Rounded-Heavy", @"ext": @"otf", @"weight": @"Heavy"}
    ];

    for (NSDictionary *fontInfo in fontFiles) {
        NSString *fileName = fontInfo[@"file"];
        NSString *fileExt = fontInfo[@"ext"];
        NSString *weight = fontInfo[@"weight"];

        NSString *fontPath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExt];
        if (fontPath) {
            NSLog(@"  ✅ %@ (%@.%@) 文件存在", weight, fileName, fileExt);
            NSLog(@"    📁 路径: %@", fontPath);

            // 检查文件大小
            NSError *error;
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fontPath error:&error];
            if (attributes) {
                NSNumber *fileSize = attributes[NSFileSize];
                double fileSizeMB = [fileSize doubleValue] / (1024.0 * 1024.0);
                NSLog(@"    📏 文件大小: %.2f MB", fileSizeMB);

                if (fileSizeMB < 0.1) {
                    NSLog(@"    ⚠️  警告: 文件大小异常小，可能是空文件");
                }
            }
        } else {
            NSLog(@"  ❌ %@ (%@.%@) 文件不存在", weight, fileName, fileExt);
        }
    }
}

+ (void)testInfoPlistFonts {
    NSLog(@"📋 测试Info.plist中注册的字体:");

    // 获取Info.plist中的UIAppFonts数组
    NSArray *appFonts = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIAppFonts"];

    if (appFonts && appFonts.count > 0) {
        NSLog(@"  📁 Info.plist中注册了 %lu 个字体:", (unsigned long)appFonts.count);

        for (NSString *fontFileName in appFonts) {
            NSLog(@"    📝 注册的字体文件: %@", fontFileName);

            // 尝试基于文件名推测可能的PostScript名称
            NSString *baseName = [fontFileName stringByDeletingPathExtension];
            NSArray *possibleNames = @[
                baseName,
                [baseName stringByReplacingOccurrencesOfString:@"-" withString:@""],
                [baseName stringByReplacingOccurrencesOfString:@"SF-Pro-Rounded-" withString:@"SFProRounded-"],
                [baseName stringByReplacingOccurrencesOfString:@"-" withString:@" "]
            ];

            for (NSString *testName in possibleNames) {
                UIFont *font = [UIFont fontWithName:testName size:16.0];
                if (font) {
                    NSLog(@"      ✅ 成功: %@ -> 实际字体名: %@", testName, font.fontName);
                } else {
                    NSLog(@"      ❌ 失败: %@", testName);
                }
            }
        }
    } else {
        NSLog(@"  ❌ Info.plist中没有找到UIAppFonts配置");
    }
}

+ (void)validateFontsInViewController:(UIViewController *)viewController {
    if (!viewController) {
        NSLog(@"❌ 视图控制器为空，无法验证字体");
        return;
    }
    
    NSLog(@"🔍 验证视图控制器字体: %@", NSStringFromClass([viewController class]));
    [self validateFontsInView:viewController.view];
}

+ (void)validateFontsInView:(UIView *)view {
    if (!view) {
        return;
    }
    
    // 检查当前视图的字体
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        [self validateLabelFont:label];
    } else if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        [self validateButtonFont:button];
    } else if ([view isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)view;
        [self validateTextFieldFont:textField];
    } else if ([view isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)view;
        [self validateTextViewFont:textView];
    }
    
    // 递归检查子视图
    for (UIView *subview in view.subviews) {
        [self validateFontsInView:subview];
    }
}

+ (void)validateLabelFont:(UILabel *)label {
    if (label.font) {
        BOOL isSFProRounded = [label.font.fontName containsString:@"SF-Pro-Rounded"];
        NSString *status = isSFProRounded ? @"✅" : @"⚠️";
        NSLog(@"%@ UILabel字体: %@ (%.1fpt)", status, label.font.fontName, label.font.pointSize);
        
        if (!isSFProRounded) {
            NSLog(@"   建议替换为: [ATFontManager regularFontWithSize:%.1f]", label.font.pointSize);
        }
    }
}

+ (void)validateButtonFont:(UIButton *)button {
    if (button.titleLabel.font) {
        BOOL isSFProRounded = [button.titleLabel.font.fontName containsString:@"SF-Pro-Rounded"];
        NSString *status = isSFProRounded ? @"✅" : @"⚠️";
        NSLog(@"%@ UIButton字体: %@ (%.1fpt)", status, button.titleLabel.font.fontName, button.titleLabel.font.pointSize);
        
        if (!isSFProRounded) {
            NSLog(@"   建议替换为: [ATFontManager regularFontWithSize:%.1f]", button.titleLabel.font.pointSize);
        }
    }
}

+ (void)validateTextFieldFont:(UITextField *)textField {
    if (textField.font) {
        BOOL isSFProRounded = [textField.font.fontName containsString:@"SF-Pro-Rounded"];
        NSString *status = isSFProRounded ? @"✅" : @"⚠️";
        NSLog(@"%@ UITextField字体: %@ (%.1fpt)", status, textField.font.fontName, textField.font.pointSize);
        
        if (!isSFProRounded) {
            NSLog(@"   建议替换为: [ATFontManager regularFontWithSize:%.1f]", textField.font.pointSize);
        }
    }
}

+ (void)validateTextViewFont:(UITextView *)textView {
    if (textView.font) {
        BOOL isSFProRounded = [textView.font.fontName containsString:@"SF-Pro-Rounded"];
        NSString *status = isSFProRounded ? @"✅" : @"⚠️";
        NSLog(@"%@ UITextView字体: %@ (%.1fpt)", status, textView.font.fontName, textView.font.pointSize);
        
        if (!isSFProRounded) {
            NSLog(@"   建议替换为: [ATFontManager regularFontWithSize:%.1f]", textView.font.pointSize);
        }
    }
}

@end
