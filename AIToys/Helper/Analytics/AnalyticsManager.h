//
//  AnalyticsManager.h
//  AIToys
//
//  Created by AI Assistant on 2025/8/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EventLogModel.h"
#import "AnalyticsConstants.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 埋点管理器
 * 负责收集设备信息、用户信息，并提供埋点上报接口
 */
@interface AnalyticsManager : NSObject

/// 单例实例
+ (instancetype)sharedManager;

#pragma mark - 埋点开关控制

/**
 * 从服务器加载用户权限设置并缓存
 * @param completion 完成回调，返回是否成功
 */
- (void)loadUserPermissionsWithCompletion:(nullable void(^)(BOOL success))completion;

/**
 * 设置埋点是否启用（同时更新缓存和服务器）
 * @param enabled YES启用埋点，NO禁用埋点
 * @param completion 完成回调
 */
- (void)setAnalyticsEnabled:(BOOL)enabled completion:(nullable void(^)(BOOL success))completion;

/**
 * 设置埋点是否启用（仅更新本地缓存，用于向后兼容）
 * @param enabled YES启用埋点，NO禁用埋点
 */
- (void)setAnalyticsEnabled:(BOOL)enabled;

/**
 * 获取埋点是否启用（从缓存读取）
 * @return YES已启用，NO已禁用
 */
- (BOOL)isAnalyticsEnabled;

/**
 * 调试方法：打印当前埋点状态和缓存信息
 */
- (void)debugPrintAnalyticsStatus;

#pragma mark - 基础埋点上报方法

/**
 * 上报埋点事件
 * @param eventModel 埋点事件模型
 * @param completion 完成回调
 */
- (void)reportEvent:(EventLogModel *)eventModel 
         completion:(nullable void(^)(BOOL success, NSString * _Nullable message))completion;

/**
 * 快速上报埋点事件
 * @param eventName 事件名称
 * @param level1 层级1
 * @param level2 层级2（可选）
 * @param level3 层级3（可选）
 * @param reportTrigger 上报时机（可选）
 * @param properties 事件属性字典（可选）
 * @param completion 完成回调
 */
- (void)reportEventWithName:(NSString *)eventName
                     level1:(nullable NSString *)level1
                     level2:(nullable NSString *)level2
                     level3:(nullable NSString *)level3
              reportTrigger:(nullable NSString *)reportTrigger
                 properties:(nullable NSDictionary *)properties
                 completion:(nullable void(^)(BOOL success, NSString * _Nullable message))completion;

#pragma mark - 便利方法 - 首页相关事件

/**
 * 上报点击运营banner事件
 * @param bannerId banner ID
 * @param bannerName banner名称
 */
- (void)reportClickBannerWithId:(NSString *)bannerId name:(NSString *)bannerName;

/**
 * 上报添加设备点击事件（自动配网）
 * @param pid 产品ID
 */
- (void)reportAddDeviceClickWithPid:(NSString *)pid;

/**
 * 上报添加设备点击事件（手动添加）
 * @param pid 产品ID
 */
- (void)reportAddDeviceManualClickWithPid:(NSString *)pid;



/**
 * 上报添加设备成功事件
 * @param deviceId 设备ID
 * @param pid 产品ID
 */
- (void)reportAddDeviceSuccessWithDeviceId:(NSString *)deviceId pid:(NSString *)pid;

/**
 * 上报添加设备失败事件
 * @param errorCode 错误代码
 */
- (void)reportAddDeviceFailedWithErrorCode:(NSInteger)errorCode;

/**
 * 上报我的设备点击事件
 * @param deviceId 设备ID
 * @param pid 产品ID
 */
- (void)reportMyDeviceClickWithDeviceId:(NSString *)deviceId pid:(NSString *)pid;

/**
 * 上报我的公仔点击事件
 * @param dollId 公仔ID
 * @param dollName 公仔名称
 */
- (void)reportMyDollClickWithId:(NSString *)dollId name:(NSString *)dollName;

/**
 * 上报发现创意公仔事件
 * @param dollId 公仔ID
 * @param dollName 公仔名称
 */
- (void)reportDiscoverCreativeDollWithId:(NSString *)dollId name:(NSString *)dollName;

/**
 * 上报探索点击公仔事件
 * @param dollId 公仔ID
 * @param dollName 公仔名称
 */
- (void)reportExploreClickDollWithId:(NSString *)dollId name:(NSString *)dollName;

#pragma mark - 便利方法 - 账户相关事件



/**
 * 上报账户登录成功事件
 * @param accountId 账户ID
 * @param loginTime 登录时间
 * @param region 登录地区
 */
- (void)reportAccountLoginSuccessWithId:(NSString *)accountId 
                              loginTime:(NSString *)loginTime 
                                 region:(NSString *)region;

#pragma mark - 便利方法 - 家庭相关事件

/**
 * 上报家庭空间添加成员事件
 * @param permission 成员权限
 * @param homeId 家庭ID
 * @param familyMemberId 家庭成员ID
 * @param homeOwnerId 家庭拥有者ID
 */
- (void)reportFamilyAddMemberWithPermission:(NSString *)permission
                                     homeId:(NSString *)homeId
                            familyMemberId:(NSString *)familyMemberId
                               homeOwnerId:(NSString *)homeOwnerId;

/**
 * 上报家庭空间移除成员事件
 * @param homeId 家庭ID
 * @param familyMemberId 家庭成员ID
 * @param homeOwnerId 家庭拥有者ID
 */
- (void)reportFamilyRemoveMemberWithHomeId:(NSString *)homeId
                          familyMemberId:(NSString *)familyMemberId
                             homeOwnerId:(NSString *)homeOwnerId;

/**
 * 上报家庭空间修改成员权限事件
 * @param permission 成员权限
 */
- (void)reportFamilyModifyMemberPermissionWithPermission:(NSString *)permission;

#pragma mark - 工具方法

/**
 * 将属性字典转换为JSON字符串
 * @param properties 属性字典
 * @return JSON字符串，转换失败返回nil
 */
- (nullable NSString *)propertiesJSONStringFromDictionary:(NSDictionary *)properties;

/**
 * 获取当前用户ID
 * @return 当前用户ID，未登录返回nil
 */
- (nullable NSNumber *)getCurrentUserId;

/**
 * 获取当前应用版本号
 * @return 应用版本号
 */
- (NSString *)getCurrentAppVersion;

/**
 * 获取当前系统版本号
 * @return 系统版本号
 */
- (NSString *)getCurrentOSVersion;

@end

NS_ASSUME_NONNULL_END
