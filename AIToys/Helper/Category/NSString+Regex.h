//
//  NSString+Regex.h
//  HFKitDemo
//
//  Created by helfy on 16/6/29.
//  Copyright © 2016年 helfy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Regex)

//用户姓名 6到20个字符
+(NSString *)userNameRegex;
//密码 8到15个字符
+(NSString *)passWordRegex;
//邮箱地址
+(NSString *)emailRegex;
//电话号码 1开头的11位数字
+(NSString *)phoneNumberRegex;
//车牌号
+(NSString *)carNoRegex;

//身份证
+(NSString *)identityCardPredicate;

//str转VC
+ (UIViewController*)stringChangeToClass:(NSString *)str;
- (BOOL)validateForRegex:(NSString *)regex;

//银行卡号验证
+ (BOOL)checkCardNo:(NSString*)cardNo;
@end
