//
//  EventLogModel.m
//  AIToys
//
//  Created by AI Assistant on 2025/8/21.
//

#import "EventLogModel.h"

@implementation EventLogModel

+ (instancetype)eventWithName:(NSString *)eventName
                       level1:(nullable NSString *)level1
                       level2:(nullable NSString *)level2
                       level3:(nullable NSString *)level3
                reportTrigger:(nullable NSString *)reportTrigger
                   properties:(nullable NSString *)properties {
    
    EventLogModel *event = [[EventLogModel alloc] init];
    event.eventName = eventName;
    event.level1 = level1;
    event.level2 = level2;
    event.level3 = level3;
    event.reportTrigger = reportTrigger;
    event.properties = properties;
    
    // 设置默认值
    [event setDefaultValues];
    
    return event;
}

- (void)setDefaultValues {
    // 设置当前时间
    [self setCurrentEventTime];
    
    // 设置默认应用版本
    self.appVersion = @"1.0";
    
    // 设置操作系统类型 (1:iOS)
    self.osType = @(1);
    
    // 设置默认系统版本
    self.osVersion = @"1.0";
}

- (void)setCurrentEventTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    formatter.timeZone = [NSTimeZone localTimeZone];
    self.eventTime = [formatter stringFromDate:[NSDate date]];
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // 添加必填字段
    if (self.eventTime) {
        dict[@"eventTime"] = self.eventTime;
    }
    
    if (self.eventName) {
        dict[@"eventName"] = self.eventName;
    }
    
    if (self.osType) {
        dict[@"osType"] = self.osType;
    }
    
    // 添加有默认值的字段
    if (self.appVersion) {
        dict[@"appVersion"] = self.appVersion;
    }
    
    if (self.osVersion) {
        dict[@"osVersion"] = self.osVersion;
    }
    
    // 添加可选字段（仅当非空时）
    if (self.eventId) {
        dict[@"id"] = self.eventId;
    }
    
    // 移除 memberUserId 字段，不再上报用户ID以保护隐私
    // if (self.memberUserId) {
    //     dict[@"memberUserId"] = self.memberUserId;
    // }
    
    if (self.level1 && self.level1.length > 0) {
        dict[@"level1"] = self.level1;
    }
    
    if (self.level2 && self.level2.length > 0) {
        dict[@"level2"] = self.level2;
    }
    
    if (self.level3 && self.level3.length > 0) {
        dict[@"level3"] = self.level3;
    }
    
    if (self.reportTrigger && self.reportTrigger.length > 0) {
        dict[@"reportTrigger"] = self.reportTrigger;
    }
    
    if (self.properties && self.properties.length > 0) {
        dict[@"properties"] = self.properties;
    }
    
    return [dict copy];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"EventLogModel: eventName=%@, level1=%@, level2=%@, level3=%@, eventTime=%@", 
            self.eventName, self.level1, self.level2, self.level3, self.eventTime];
}

@end
