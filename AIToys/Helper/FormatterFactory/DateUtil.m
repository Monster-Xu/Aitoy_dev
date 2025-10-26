//
//  DateUtil.m
//  FurnitureHelp
//
//  Created by 智剿 on 2018/2/6.
//  Copyright © 2018年 智剿. All rights reserved.
//

#import "DateUtil.h"

@implementation DateUtil
////获得当地当前时间：
+ (NSDate *)getNowDate
{
    NSDate *date = [NSDate date];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: date];
    
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    return localeDate;
}

//获取系统当前时间
+ (NSString *)getCurrentTimeFormat:(NSString *)formatStr {
    /* yyyy-MM-dd HH:mm:ss
     yyyy-MM-dd-mm-ss
     时间格式
     */
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:formatStr];
    NSString *ret = [formatter stringFromDate:[NSDate date]];
    return ret;
}
//获取当前时间的时间戳
+ (NSString*)getCurrentTimestamp;{
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    return timeString;
}

//根据时间戳转换成时间
+ (NSString *)CommontimeIntervalSince1970timeIntervalSince1970:(NSTimeInterval)secs Format:(NSString*)formatStr{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:secs];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatStr];
    NSString *ret = [formatter stringFromDate:date];
    return ret;
}

//String ====> Date  （字符串转时间）
+ (NSDate *)dateFromString:(NSString *)dateString
                  Formater:(NSString *)formater {
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    [dateFormater setDateFormat:formater];
    [dateFormater setTimeZone:zone];
    NSDate *date = [dateFormater dateFromString:dateString];
    return date;
}



//Date =====> String （时间转字符串）
+ (NSString *)stringFromDate:(NSDate *)date
                    Formater:(NSString *)formater {
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:formater];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [dateFormater setTimeZone:timeZone];
    NSString *dateString = [dateFormater stringFromDate:date];
    return dateString;
}

////将现在的时间转化成当前所在时区的时间
+ (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}
//距离现在的天、时、分、秒
+ (NSString *)compareCurrentTime:(NSTimeInterval) interval {
    //    int timeInterval = abs(interval) / 1000;   修改之前
    int timeInterval = fabs(interval) / 1000;
    int daySec  = 60 * 60 * 24;
    int hourSec = 60 * 60;
    int tmpDay, tmpHour;
    NSMutableString *result = [NSMutableString string];
    if (timeInterval / daySec > 0) {
        tmpDay = timeInterval / daySec;
        [result appendFormat:@"%d天", tmpDay];
        if ((timeInterval % daySec) / hourSec > 0) {
            tmpHour = (timeInterval % daySec) / hourSec;
            [result appendFormat:@"%d时", tmpHour];
        }
    } else {
        if (timeInterval / hourSec > 0) {
            tmpHour = timeInterval / hourSec;
            if (timeInterval % hourSec == 0) {
                [result appendFormat:@"%d时", tmpHour];
            } else {
                [result appendFormat:@"%d.5时", tmpHour];
            }
        } else {
            [result appendString:@"0.5时"];
        }
    }
    return  result;
}

//重新调整时间
+ (NSDate *)reSetCurrentDate:(NSDate *)date {
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    return [date dateByAddingTimeInterval:interval];
}
//输入NSDate 返回星期几
+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    /*  例子
     NSTimeInterval shijianINt = [[NSDate date] timeIntervalSince1970];
     NSDate *datedd = [NSDate dateWithTimeIntervalSince1970:shijianINt];
     NSString *shijian = [self CommontimeIntervalSince1970timeIntervalSince1970:shijianINt Format:@"MM月dd日"];
     NSString *xingqi = [self weekdayStringFromDate:datedd];
     */
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    return [weekdays objectAtIndex:theComponents.weekday];
}

//格式化时间戳
+ (NSString *)formatTimeStamp:(NSString *)format withTime:(NSString *)timeStr {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStr integerValue]];
    formatter.dateFormat = format;
    NSString *time = [formatter stringFromDate:date];
    
    return time;
}

//将某个时间转化成 时间戳
#pragma mark - 将某个时间转化成 时间戳
+(NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format]; //(@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:formatTime]; //------------将字符串按formatter转成nsdate
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];

    NSLog(@"将某个时间转化成 时间戳&&&&&&&timeSp:%ld",(long)timeSp); //时间戳的值
    return timeSp;
}

@end
