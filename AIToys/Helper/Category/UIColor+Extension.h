//
//  UIColor+Extension.h
//  DistributionStore
//
//  Created by 张海阔 on 2019/11/1.
//  Copyright © 2019 OceanCodes. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Extension)

+ (CAGradientLayer *)setGradualChangingColor:(CGRect )frame fromColor:(NSString *)fromHexColorStr toColor:(NSString *)toHexColorStr;

+ (UIColor *)colorWithHexString:(NSString *)color;

@end

NS_ASSUME_NONNULL_END
