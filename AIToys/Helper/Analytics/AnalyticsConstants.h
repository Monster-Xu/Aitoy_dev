//
//  AnalyticsConstants.h
//  AIToys
//
//  Created by AI Assistant on 2025/8/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 层级常量定义

/// 层级1 - 首页
FOUNDATION_EXPORT NSString * const kAnalyticsLevel1_Home;

/// 层级1 - 登录
FOUNDATION_EXPORT NSString * const kAnalyticsLevel1_Login;

/// 层级1 - 家庭
FOUNDATION_EXPORT NSString * const kAnalyticsLevel1_Family;

/// 层级2 - 添加设备
FOUNDATION_EXPORT NSString * const kAnalyticsLevel2_AddDevice;

/// 层级2 - 设备面板
FOUNDATION_EXPORT NSString * const kAnalyticsLevel2_DevicePanel;

/// 层级2 - 添加成员
FOUNDATION_EXPORT NSString * const kAnalyticsLevel2_AddMember;

/// 层级2 - 移除成员
FOUNDATION_EXPORT NSString * const kAnalyticsLevel2_RemoveMember;

#pragma mark - 事件名称常量定义

// 首页相关事件
/// 点击运营banner
FOUNDATION_EXPORT NSString * const kAnalyticsEvent_ClickBanner;

/// 添加设备_点击（自动配网）
FOUNDATION_EXPORT NSString * const kAnalyticsEvent_AddDevice_Click;

/// 添加设备_点击（手动添加）
FOUNDATION_EXPORT NSString * const kAnalyticsEvent_AddDevice_ManualClick;



/// 添加设备_添加成功
FOUNDATION_EXPORT NSString * const kAnalyticsEvent_AddDevice_Success;

/// 添加设备_添加失败
FOUNDATION_EXPORT NSString * const kAnalyticsEvent_AddDevice_Failed;

/// 我的设备_点击
FOUNDATION_EXPORT NSString * const kAnalyticsEvent_MyDevice_Click;

/// 我的公仔_点击
FOUNDATION_EXPORT NSString * const kAnalyticsEvent_MyDoll_Click;

/// 发现创意公仔
FOUNDATION_EXPORT NSString * const kAnalyticsEvent_DiscoverCreativeDoll;

/// 探索_点击公仔
FOUNDATION_EXPORT NSString * const kAnalyticsEvent_Explore_ClickDoll;

// 账户相关事件
/// 账户_登录成功
FOUNDATION_EXPORT NSString * const kAnalyticsEvent_Account_LoginSuccess;

// 家庭相关事件
/// 家庭空间_添加成员
FOUNDATION_EXPORT NSString * const kAnalyticsEvent_Family_AddMember;

/// 家庭空间_移除成员
FOUNDATION_EXPORT NSString * const kAnalyticsEvent_Family_RemoveMember;

/// 家庭空间_修改成员权限
FOUNDATION_EXPORT NSString * const kAnalyticsEvent_Family_ModifyMemberPermission;

#pragma mark - 上报时机常量定义

/// 点击时
FOUNDATION_EXPORT NSString * const kAnalyticsTrigger_OnClick;

/// 配对成功时
FOUNDATION_EXPORT NSString * const kAnalyticsTrigger_OnPairSuccess;

/// 配网成功，设备ID激活时
FOUNDATION_EXPORT NSString * const kAnalyticsTrigger_OnDeviceActivated;

/// 添加失败时
FOUNDATION_EXPORT NSString * const kAnalyticsTrigger_OnAddFailed;

/// 登录成功时
FOUNDATION_EXPORT NSString * const kAnalyticsTrigger_OnLoginSuccess;

/// 添加完成时
FOUNDATION_EXPORT NSString * const kAnalyticsTrigger_OnAddCompleted;

/// 移除完成时
FOUNDATION_EXPORT NSString * const kAnalyticsTrigger_OnRemoveCompleted;

/// 修改完成时
FOUNDATION_EXPORT NSString * const kAnalyticsTrigger_OnModifyCompleted;

#pragma mark - 属性键常量定义

/// banner ID
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_BannerId;

/// banner名称
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_BannerName;

/// PID
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_PID;



/// 设备ID
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_DeviceId;

/// 失败原因
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_FailureReason;

/// 错误代码
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_ErrorCode;

/// 公仔ID
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_DollId;

/// 公仔名称
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_DollName;

/// 账户ID
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_AccountId;

/// 登录成功时间
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_LoginTime;

/// 登录成功地区
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_LoginRegion;

/// 成员权限
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_MemberPermission;

/// 家庭ID
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_FamilyId;

/// 家庭ID (与Android保持一致的字段名)
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_HomeId;

/// 家庭成员ID
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_FamilyMemberId;

/// 家庭拥有者ID
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_HomeOwnerId;

/// 用户ID
FOUNDATION_EXPORT NSString * const kAnalyticsProperty_UserId;

#pragma mark - 权限类型常量

/// 权限类型 - 拥有者
FOUNDATION_EXPORT NSString * const kAnalyticsPermission_Owner;

/// 权限类型 - 管理员
FOUNDATION_EXPORT NSString * const kAnalyticsPermission_Admin;

/// 权限类型 - 普通成员
FOUNDATION_EXPORT NSString * const kAnalyticsPermission_Normal;



NS_ASSUME_NONNULL_END
