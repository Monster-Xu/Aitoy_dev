//
//  FormatFactory.m
//  DateFormatterDemo
//
//  Created by 张海阔 on 2019/7/11.
//  Copyright © 2019 ZhangHaiKuo. All rights reserved.
//

#import "FormatFactory.h"
#import <UIKit/UIKit.h>

static NSUInteger const kDataFormatterCache_countLimit = 5;

@interface FormatFactory ()<NSCacheDelegate>
{
    NSCache *dataFormatterCache;
}
@end

@implementation FormatFactory

+ (instancetype)shared {
    static FormatFactory *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        dataFormatterCache = [[NSCache alloc] init];
        dataFormatterCache.countLimit = kDataFormatterCache_countLimit;
        dataFormatterCache.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:dataFormatterCache selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:dataFormatterCache selector:@selector(removeAllObjects) name:NSCurrentLocaleDidChangeNotification  object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:dataFormatterCache];
    NSLog(@"%@ -- dealloc", self.class);
}

#pragma mark -- NSDateFormatter Initialization Methods

// custom Style

- (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format andLocale:(NSLocale *)locale {
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%@|%@", format, locale.localeIdentifier];
        
        NSDateFormatter *dateFormatter = [dataFormatterCache objectForKey:key];
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = format;
            dateFormatter.locale = locale;
            [dataFormatterCache setObject:dateFormatter forKey:key];
        }
        
        return dateFormatter;
    }
}

- (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format andLocaleIdentifier:(NSString *)localeIdentifier {
    return [self dateFormatterWithFormat:format andLocale:[[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier]];
}

- (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format {
    return [self dateFormatterWithFormat:format andLocale:[NSLocale currentLocale]];
}

// system style

- (NSDateFormatter *)dateFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle andLocale:(NSLocale *)locale {
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"d%lu|t%lu%@", (unsigned long)dateStyle, (unsigned long)timeStyle, locale.localeIdentifier];
        
        NSDateFormatter *dateFormatter = [dataFormatterCache objectForKey:key];
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateStyle = dateStyle;
            dateFormatter.timeStyle = timeStyle;
            dateFormatter.locale = locale;
            [dataFormatterCache setObject:dateFormatter forKey:key];
        }
        
        return dateFormatter;
    }
}

- (NSDateFormatter *)dateFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle andLocaleIdentifier:(NSString *)localeIdentifier {
    return [self dateFormatterWithDateStyle:dateStyle timeStyle:timeStyle andLocale:[[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier]];
}

- (NSDateFormatter *)dateFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle andTimeStyle:(NSDateFormatterStyle)timeStyle {
    return [self dateFormatterWithDateStyle:dateStyle timeStyle:timeStyle andLocale:[NSLocale currentLocale]];
}

#pragma mark -- CacheLimit Methods

- (void)setCacheLimit:(NSUInteger)cacheLimit {
    @synchronized (self) {
        dataFormatterCache.countLimit = cacheLimit;
    }
}

- (NSUInteger)cacheLimit {
    @synchronized(self) {
        return dataFormatterCache.countLimit;
    }
}

- (NSDate *)becomeDateStr:(NSString *)dateStr withFormat:(NSString *)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (format) {
        [dateFormatter setDateFormat:format];
    }else{
         [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    return date;
}

-(int)sinceCurrentCompareDate:(NSString *)dateStr{
    int ci;
    NSDate *nowDate = [NSDate date];
    NSDate *dt = [self becomeDateStr:dateStr withFormat:@"yyyy-MM-dd HH:mm"];
    NSComparisonResult result = [nowDate compare:dt];
    switch (result)

    {
    //大于当前时间

    case NSOrderedAscending: ci= 1; break;

    //小于当前时间
            
    case NSOrderedDescending: ci=-1; break;

    //等于当前时间

    case NSOrderedSame: ci=0; break;
    }
    return ci;
}

//比较两个时间的大小
-(int)CompareStartDate:(NSString *)startStr
               endDate:(NSString *)endStr{
    int ci;
    NSDate *startDt = [self becomeDateStr:startStr withFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *endDt = [self becomeDateStr:endStr withFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSComparisonResult result = [startDt compare:endDt];
    switch (result)

    {
    //大于前者

    case NSOrderedAscending: ci= 1; break;

    //小于前者
            
    case NSOrderedDescending: ci=-1; break;

    //等于前者

    case NSOrderedSame: ci=0; break;
    }
    return ci;
}

//计算到期时间与当前时间的差
- (int)intervalSinceNow:(NSString *) theDate {
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    NSTimeInterval cha=late-now;
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        return [timeString intValue];
    }
    return 0;
}

/**
 *  获取当天的字符串
 *
 *  @return 格式为年-月-日 时分秒
 */
- (NSString *)getCurrentTimeyyyymmdd {
    NSDate *now = [NSDate date];
    NSDateFormatter *formatDay = [[NSDateFormatter alloc] init];
    formatDay.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dayStr = [formatDay stringFromDate:now];
    return dayStr;
}
/**
 *  获取时间差值  截止时间-当前时间
 *  nowDateStr : 当前时间
 *  deadlineStr : 截止时间
 *  @return 时间戳差值
 */
-(NSInteger)getDateDifferenceWithNowDateStr:(NSString*)nowDateStr deadlineStr:(NSString*)deadlineStr {
    NSInteger timeDifference = 0;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
    NSDate *nowDate = [formatter dateFromString:nowDateStr];
    NSDate *deadline = [formatter dateFromString:deadlineStr];
    NSTimeInterval oldTime = [nowDate timeIntervalSince1970];
    NSTimeInterval newTime = [deadline timeIntervalSince1970];
    timeDifference = newTime - oldTime;
    return timeDifference;
}

-(NSString *)getDurationWithNowDateStr:(NSString*)nowDateStr deadlineStr:(NSString*)deadlineStr{
    NSInteger timeInterval = [self getDateDifferenceWithNowDateStr:nowDateStr deadlineStr:deadlineStr];
    NSString *result;
    NSInteger tmpMinute = 0;
    if (timeInterval/60 > 0) {
        tmpMinute = timeInterval / 60;
    }
    result = [NSString stringWithFormat:@"%ld分钟",(long)tmpMinute];
    return result;
}

#pragma mark -- NSCacheDelegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    NSLog(@"cache: %@ removed : %@", cache.name, obj);
}

@end
