//
//  NSDate+Extension.h
//
//  Created by 任玉飞 on 16/4/1.
//  Copyright © 2016年 任玉飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)

+ (NSDateComponents *)deltaFrom:(NSDate *)from;

- (BOOL)isThisYear;

- (BOOL)isToday;

- (BOOL)isYesterday;

//生成当前时间戳
+ (NSInteger)getNowTimestamp;

+ (NSInteger)get13NowTimestamp;

//时间戳转时间
+ (NSDate *)timestampToDate:(NSString *)timestamp;

//时间戳转时间,带格式
+ (NSString *)timestampToDate:(NSString *)timestamp formatter:(NSString *)fmt;

/**
 *  获取与当前时间的差距
 */
- (NSDateComponents *)deltaToNow;
@end
