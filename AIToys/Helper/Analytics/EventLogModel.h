//
//  EventLogModel.h
//  AIToys
//
//  Created by AI Assistant on 2025/8/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 埋点事件数据模型
 * 根据接口文档定义的埋点上报参数结构
 */
@interface EventLogModel : NSObject

/// 主键ID (可选，服务端生成)
@property (nonatomic, strong, nullable) NSNumber *eventId;

/// 事件发生时间（用户行为实际发生的时间）- 必填
@property (nonatomic, copy) NSString *eventTime;

/// 用户token（未登录时为NULL）- 可选
@property (nonatomic, strong, nullable) NSNumber *memberUserId;

/// 应用版本号 - 默认1.0
@property (nonatomic, copy) NSString *appVersion;

/// 操作系统类型（1:iOS, 2:Android）- 必填
@property (nonatomic, strong) NSNumber *osType;

/// 系统版本号 - 默认1.0
@property (nonatomic, copy) NSString *osVersion;

/// 层级1（如"首页"）- 可选
@property (nonatomic, copy, nullable) NSString *level1;

/// 层级2（无子层级时为NULL）- 可选
@property (nonatomic, copy, nullable) NSString *level2;

/// 层级3（无子层级时为NULL）- 可选
@property (nonatomic, copy, nullable) NSString *level3;

/// 事件名称（如"点击运营banner"）- 必填
@property (nonatomic, copy) NSString *eventName;

/// 上报时机（如"点击时"）- 可选
@property (nonatomic, copy, nullable) NSString *reportTrigger;

/// 事件相关属性（JSON格式，如banner_id、设备ID等）- 可选
@property (nonatomic, copy, nullable) NSString *properties;

/**
 * 创建埋点事件模型的便利构造方法
 * @param eventName 事件名称
 * @param level1 层级1
 * @param level2 层级2
 * @param level3 层级3
 * @param reportTrigger 上报时机
 * @param properties 事件属性（JSON字符串）
 * @return EventLogModel实例
 */
+ (instancetype)eventWithName:(NSString *)eventName
                       level1:(nullable NSString *)level1
                       level2:(nullable NSString *)level2
                       level3:(nullable NSString *)level3
                reportTrigger:(nullable NSString *)reportTrigger
                   properties:(nullable NSString *)properties;

/**
 * 将模型转换为字典，用于网络请求
 * @return 包含所有非空字段的字典
 */
- (NSDictionary *)toDictionary;

/**
 * 设置当前时间为事件时间
 */
- (void)setCurrentEventTime;

@end

NS_ASSUME_NONNULL_END
