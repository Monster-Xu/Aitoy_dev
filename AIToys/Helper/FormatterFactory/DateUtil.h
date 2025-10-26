//
//  DateUtil.h
//  FurnitureHelp
//
//  Created by 智剿 on 2018/2/6.
//  Copyright © 2018年 智剿. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject
///获得当地当前时间：
+ (NSDate *)getNowDate;
///获取系统当前时间
+ (NSString *)getCurrentTimeFormat:(NSString *)formatStr;
///获取当前时间的时间戳
+ (NSString*)getCurrentTimestamp;
///根据时间戳转换成时间
+ (NSString *)CommontimeIntervalSince1970timeIntervalSince1970:(NSTimeInterval)secs Format:(NSString*)formatStr;
///String ====> Date  （字符串转时间）
+ (NSDate *)dateFromString:(NSString *)dateString Formater:(NSString *)formater;
///Date =====> String （时间转字符串）
+ (NSString *)stringFromDate:(NSDate *)date Formater:(NSString *)formater;
///将现在的时间转化成当前所在时区的时间
+ (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate;
///距离现在的天、时、分、秒
+ (NSString *)compareCurrentTime:(NSTimeInterval) interval;
///重新调整时间
+ (NSDate *)reSetCurrentDate:(NSDate *)date;
///输入NSDate 返回星期几
+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate;
/**
 * 格式化时间戳
 * format 时间格式
 * timeStr 时间戳字符串
 */
+ (NSString *)formatTimeStamp:(NSString *)format withTime:(NSString *)timeStr;

//将某个时间转化成 时间戳
#pragma mark - 将某个时间转化成 时间戳
+(NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format;
@end
