//
//  NSDate+Extension.m
//
//  Created by 任玉飞 on 16/4/1.
//  Copyright © 2016年 任玉飞. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

- (NSDateComponents *)deltaToNow {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    return [calendar components:unit fromDate:self toDate:[NSDate date] options:0];
}

+ (NSDateComponents *)deltaFrom:(NSDate *)from {
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //这个是可选的 年月日时分秒
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ;
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    //设置时间格式
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDateComponents *cms = [calendar components:unit fromDate:from toDate:now options:0];
    
    return cms;
    
}

- (BOOL)isThisYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger nowYear = [calendar component:NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger selfYear = [calendar component:NSCalendarUnitYear fromDate:self];
    return nowYear == selfYear;
    
}

- (BOOL)isToday
{
    //1.
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    NSString *now = [fmt stringFromDate:[NSDate date]];
    NSString *selfString = [fmt stringFromDate:self];
    
    return [now isEqualToString:selfString];
    
    /*
    //2.
    NSCalendar *calendat = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateComponents *nowCmps = [calendat components:unit fromDate:[NSDate date]];
    NSDateComponents *selfCmps = [calendat components:unit fromDate:self];
    
    return nowCmps.year == selfCmps.year && nowCmps.month == nowCmps.month && nowCmps.day == selfCmps.day;
     */
    
}

- (BOOL)isYesterday
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    NSDate *nowDate = [fmt dateFromString:[fmt stringFromDate:[NSDate date]]];
    
    NSDate *selfDate =  [fmt dateFromString:[fmt stringFromDate:self]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth fromDate:selfDate toDate:nowDate options:0];
    
    return cmps.year == 0 && cmps.month == 0 && cmps.day == 1;
}

//生成当前时间戳
+ (NSInteger)getNowTimestamp
{
    NSDate *datenow = [NSDate date];//现在时间
    
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[datenow timeIntervalSince1970]] integerValue];
    
//    NSLog(@"设备当前的时间戳:%ld",(long)timeSp); //时间戳的值
    
    return timeSp;
}

+ (NSInteger)get13NowTimestamp
{
    NSDate *datenow = [NSDate date];//现在时间
    
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[datenow timeIntervalSince1970]] integerValue];
    
    NSInteger finalSp = timeSp * 1000;
    
//    NSLog(@"设备当前的时间戳:%ld",(long)timeSp); //时间戳的值
    
    return finalSp;
}

//时间戳转时间
+ (NSDate *)timestampToDate:(NSString *)timestamp
{
    NSTimeInterval interval = [timestamp doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    return date;
}

//时间戳转时间,带格式
+ (NSString *)timestampToDate:(NSString *)timestamp formatter:(NSString *)fmt
{
    NSTimeInterval interval = [timestamp doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];

    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = fmt;

    return [formatter stringFromDate:date];

}


@end
