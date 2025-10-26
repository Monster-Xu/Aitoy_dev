//
//  NSString+Extension.h
//  修罗微博
//
//  Created by xiuluo on 15/11/11.
//  Copyright © 2015年 chengde. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)
- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW;
- (CGSize)sizeWithFont:(UIFont *)font;

/** 判断字符串是否为空，\@"" 返回yes */
+ (BOOL)isNotBlank:(NSString *)str;
+ (NSString *)sha1:(NSString *)input;
+ (NSString *)MD5:(NSString *)input;
+(NSString *)getDeviceIPAddresses;
@end
