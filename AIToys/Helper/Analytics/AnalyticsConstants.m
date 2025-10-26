//
//  AnalyticsConstants.m
//  AIToys
//
//  Created by AI Assistant on 2025/8/21.
//

#import "AnalyticsConstants.h"

#pragma mark - 层级常量实现

NSString * const kAnalyticsLevel1_Home = @"首页";
NSString * const kAnalyticsLevel1_Login = @"登录";
NSString * const kAnalyticsLevel1_Family = @"家庭";

NSString * const kAnalyticsLevel2_AddDevice = @"添加设备";
NSString * const kAnalyticsLevel2_DevicePanel = @"";
NSString * const kAnalyticsLevel2_AddMember = @"添加成员";
NSString * const kAnalyticsLevel2_RemoveMember = @"移除成员";

#pragma mark - 事件名称常量实现

// 首页相关事件
NSString * const kAnalyticsEvent_ClickBanner = @"点击运营banner";
NSString * const kAnalyticsEvent_AddDevice_Click = @"添加设备_点击";
NSString * const kAnalyticsEvent_AddDevice_ManualClick = @"添加设备_手动点击";

NSString * const kAnalyticsEvent_AddDevice_Success = @"添加设备_添加成功";
NSString * const kAnalyticsEvent_AddDevice_Failed = @"添加设备_添加失败";
NSString * const kAnalyticsEvent_MyDevice_Click = @"设备面板_点击";
NSString * const kAnalyticsEvent_MyDoll_Click = @"我的公仔_点击";
NSString * const kAnalyticsEvent_DiscoverCreativeDoll = @"发现创意公仔";
NSString * const kAnalyticsEvent_Explore_ClickDoll = @"探索_点击公仔";

// 账户相关事件
NSString * const kAnalyticsEvent_Account_LoginSuccess = @"账户_登录成功";

// 家庭相关事件
NSString * const kAnalyticsEvent_Family_AddMember = @"家庭空间_添加成员";
NSString * const kAnalyticsEvent_Family_RemoveMember = @"家庭空间_移除成员";
NSString * const kAnalyticsEvent_Family_ModifyMemberPermission = @"家庭空间_修改成员权限";

#pragma mark - 上报时机常量实现

NSString * const kAnalyticsTrigger_OnClick = @"点击时";
NSString * const kAnalyticsTrigger_OnPairSuccess = @"配对成功时";
NSString * const kAnalyticsTrigger_OnDeviceActivated = @"配网成功，设备ID激活时";
NSString * const kAnalyticsTrigger_OnAddFailed = @"添加失败时";
NSString * const kAnalyticsTrigger_OnLoginSuccess = @"登录成功时";
NSString * const kAnalyticsTrigger_OnAddCompleted = @"添加完成时";
NSString * const kAnalyticsTrigger_OnRemoveCompleted = @"移除完成时";
NSString * const kAnalyticsTrigger_OnModifyCompleted = @"修改完成时";

#pragma mark - 属性键常量实现

NSString * const kAnalyticsProperty_BannerId = @"banner_id";
NSString * const kAnalyticsProperty_BannerName = @"banner_name";
NSString * const kAnalyticsProperty_PID = @"pid";

NSString * const kAnalyticsProperty_DeviceId = @"device_id";
NSString * const kAnalyticsProperty_FailureReason = @"failure_reason";
NSString * const kAnalyticsProperty_ErrorCode = @"error_code";
NSString * const kAnalyticsProperty_DollId = @"doll_id";
NSString * const kAnalyticsProperty_DollName = @"doll_name";
NSString * const kAnalyticsProperty_AccountId = @"account_id";
NSString * const kAnalyticsProperty_LoginTime = @"login_time";
NSString * const kAnalyticsProperty_LoginRegion = @"login_region";
NSString * const kAnalyticsProperty_MemberPermission = @"member_permission";
NSString * const kAnalyticsProperty_FamilyId = @"home_id";
NSString * const kAnalyticsProperty_HomeId = @"home_id";
NSString * const kAnalyticsProperty_FamilyMemberId = @"family_member_id";
NSString * const kAnalyticsProperty_HomeOwnerId = @"home_owner_id";
NSString * const kAnalyticsProperty_UserId = @"family_member_id";

#pragma mark - 权限类型常量实现

NSString * const kAnalyticsPermission_Owner = @"owner";
NSString * const kAnalyticsPermission_Admin = @"admin";
NSString * const kAnalyticsPermission_Normal = @"normal";


