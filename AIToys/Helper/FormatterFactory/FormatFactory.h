//
//  FormatFactory.h
//  DateFormatterDemo
//
//  Created by 张海阔 on 2019/7/11.
//  Copyright © 2019 ZhangHaiKuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormatFactory : NSObject
@property (nonatomic, assign) NSUInteger cacheLimit;// 默认 5

+ (instancetype)shared;

// custom Style
- (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format;
- (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format andLocale:(NSLocale *)locale;
- (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format andLocaleIdentifier:(NSString *)localeIdentifier;

// system style
- (NSDateFormatter *)dateFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle andLocale:(NSLocale *)locale;
- (NSDateFormatter *)dateFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle andLocaleIdentifier:(NSString *)localeIdentifier;
- (NSDateFormatter *)dateFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle andTimeStyle:(NSDateFormatterStyle)timeStyle;

- (NSDate *)becomeDateStr:(NSString *)dateStr withFormat:(NSString *)format;

-(int)sinceCurrentCompareDate:(NSString *)dateStr;

//比较两个时间的大小
-(int)CompareStartDate:(NSString *)startStr
               endDate:(NSString *)endStr;
//计算到期时间与当前时间的差
- (int)intervalSinceNow:(NSString *)theDate;

/**
*  获取当天的字符串
*
*  @return 格式为年-月-日 时分秒
*/
- (NSString *)getCurrentTimeyyyymmdd;

/**
 *  获取时间差值  截止时间-当前时间
 *  nowDateStr : 当前时间
 *  deadlineStr : 截止时间
 *  @return 时间戳差值
 */
-(NSInteger)getDateDifferenceWithNowDateStr:(NSString*)nowDateStr deadlineStr:(NSString*)deadlineStr;

/**
 *  获取时间差值  截止时间-当前时间
 *  nowDateStr : 当前时间
 *  deadlineStr : 截止时间
 *  @return 分钟数
 */
-(NSString *)getDurationWithNowDateStr:(NSString*)nowDateStr deadlineStr:(NSString*)deadlineStr;
@end
