//
//  AnalyticsManager.m
//  AIToys
//
//  Created by AI Assistant on 2025/8/21.
//

#import "AnalyticsManager.h"
#import "APIManager.h"
#import "APIPortConfiguration.h"
#import "UserInfo.h"

@implementation AnalyticsManager

#pragma mark - 单例

+ (instancetype)sharedManager {
    static AnalyticsManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AnalyticsManager alloc] init];
    });
    return manager;
}

#pragma mark - 埋点开关控制

- (void)loadUserPermissionsWithCompletion:(nullable void(^)(BOOL success))completion {
    // 检查是否是首次使用
    NSString *existingValue = [CoreArchive strForKey:KISAgreeImprovement];
    BOOL isFirstTime = (existingValue == nil);

    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"1" forKey:@"propKey"]; // 功能体验升级计划

    [[APIManager shared] GET:[APIPortConfiguration getAppPropertyByKeyUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        if ([data isKindOfClass:NSDictionary.class]) {
            NSDictionary *responseData = (NSDictionary *)data;
            id propValueObj = responseData[@"propValue"];

            // 详细日志：打印原始数据类型和值
            NSLog(@"[AnalyticsManager] 接口返回原始数据: %@", responseData);
            NSLog(@"[AnalyticsManager] propValue原始值: %@, 类型: %@", propValueObj, [propValueObj class]);

            // 兼容处理：支持数字和字符串类型
            BOOL isEnabled = NO;
            if ([propValueObj isKindOfClass:[NSString class]]) {
                isEnabled = [propValueObj isEqualToString:@"1"];
            } else if ([propValueObj isKindOfClass:[NSNumber class]]) {
                isEnabled = [propValueObj boolValue] || [propValueObj integerValue] == 1;
            }

            // 缓存到本地
            [CoreArchive setBool:isEnabled key:KISAgreeImprovement];

            NSLog(@"[AnalyticsManager] 权限加载成功，埋点状态: %@ (propValue: %@)", isEnabled ? @"启用" : @"禁用", propValueObj);

            if (completion) {
                completion(YES);
            }
        } else {
            NSLog(@"[AnalyticsManager] 权限加载失败，使用默认设置");
            // 如果是首次使用且加载失败，设置默认值为启用
            if (isFirstTime) {
                [CoreArchive setBool:YES key:KISAgreeImprovement];
                NSLog(@"[AnalyticsManager] 首次使用，设置默认埋点状态: 启用");
            }
            if (completion) {
                completion(NO);
            }
        }
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        NSLog(@"[AnalyticsManager] 权限加载失败: %@", msg);
        // 如果是首次使用且加载失败，设置默认值为启用
        if (isFirstTime) {
            [CoreArchive setBool:YES key:KISAgreeImprovement];
            NSLog(@"[AnalyticsManager] 首次使用，设置默认埋点状态: 启用");
        }
        if (completion) {
            completion(NO);
        }
    }];
}

- (void)setAnalyticsEnabled:(BOOL)enabled completion:(nullable void(^)(BOOL success))completion {
    // 立即更新本地缓存
    [CoreArchive setBool:enabled key:KISAgreeImprovement];

    // 同步到服务器
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:[PublicObj isEmptyObject:kMyUser.userId] ? @"" : kMyUser.userId forKey:@"memberUserId"];
    [param setValue:@"1" forKey:@"propKey"];
    [param setValue:enabled ? @"1" : @"0" forKey:@"propValue"];
    [param setValue:@"功能体验升级计划" forKey:@"description"];

    [[APIManager shared] POSTJSON:[APIPortConfiguration getAppPropertyCreateUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        NSLog(@"[AnalyticsManager] 权限设置成功: %@", enabled ? @"启用" : @"禁用");
        if (completion) {
            completion(YES);
        }
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        NSLog(@"[AnalyticsManager] 权限设置失败: %@", msg);
        if (completion) {
            completion(NO);
        }
    }];
}

- (void)setAnalyticsEnabled:(BOOL)enabled {
    // 仅更新本地缓存，用于向后兼容
    [CoreArchive setBool:enabled key:KISAgreeImprovement];
}

- (BOOL)isAnalyticsEnabled {
    // 从缓存读取埋点状态
    return [CoreArchive boolForKey:KISAgreeImprovement];
}

- (void)debugPrintAnalyticsStatus {
    NSString *cachedValue = [CoreArchive strForKey:KISAgreeImprovement];
    BOOL boolValue = [CoreArchive boolForKey:KISAgreeImprovement];

    NSLog(@"=== 埋点状态调试信息 ===");
    NSLog(@"缓存字符串值: %@", cachedValue ?: @"nil");
    NSLog(@"缓存布尔值: %@", boolValue ? @"YES" : @"NO");
    NSLog(@"isAnalyticsEnabled: %@", [self isAnalyticsEnabled] ? @"YES" : @"NO");
    NSLog(@"========================");
}

#pragma mark - 基础埋点上报方法

- (void)reportEvent:(EventLogModel *)eventModel
         completion:(nullable void(^)(BOOL success, NSString * _Nullable message))completion {

    // 检查埋点是否启用
    BOOL isEnabled = [self isAnalyticsEnabled];
    NSLog(@"[AnalyticsManager] 埋点上报检查 - isEnabled: %@, 事件: %@", isEnabled ? @"YES" : @"NO", eventModel.eventName ?: @"未知事件");

    if (!isEnabled) {
        NSLog(@"[AnalyticsManager] 埋点已禁用，跳过上报事件: %@", eventModel.eventName ?: @"未知事件");
        if (completion) {
            completion(YES, @"埋点已禁用，跳过上报");
        }
        return;
    }

    NSLog(@"[AnalyticsManager] 埋点已启用，继续上报事件: %@", eventModel.eventName ?: @"未知事件");

    if (!eventModel) {
        if (completion) {
            completion(NO, @"事件模型不能为空");
        }
        return;
    }
    
    // 自动填充用户信息
    [self fillUserInfoForEvent:eventModel];
    
    // 自动填充设备信息
    [self fillDeviceInfoForEvent:eventModel];
    
    // 转换为字典
    NSDictionary *parameters = [eventModel toDictionary];

    NSLog(@"[AnalyticsManager] 上报埋点事件: %@", parameters);
    
    // 发送网络请求
    [[APIManager shared] POSTJSON:[APIPortConfiguration getEventLogCreateUrl] 
                        parameter:parameters 
                          success:^(id result, id data, NSString *msg) {
        NSLog(@"[AnalyticsManager] 埋点上报成功: %@", msg);
        if (completion) {
            completion(YES, msg);
        }
    } failure:^(NSError *error, NSString *msg) {
        NSLog(@"[AnalyticsManager] 埋点上报失败: %@", msg);
        if (completion) {
            completion(NO, msg);
        }
    }];
}

- (void)reportEventWithName:(NSString *)eventName
                     level1:(nullable NSString *)level1
                     level2:(nullable NSString *)level2
                     level3:(nullable NSString *)level3
              reportTrigger:(nullable NSString *)reportTrigger
                 properties:(nullable NSDictionary *)properties
                 completion:(nullable void(^)(BOOL success, NSString * _Nullable message))completion {
    
    // 转换属性字典为JSON字符串
    NSString *propertiesJSON = nil;
    if (properties && properties.count > 0) {
        propertiesJSON = [self propertiesJSONStringFromDictionary:properties];
    }
    
    // 创建事件模型
    EventLogModel *eventModel = [EventLogModel eventWithName:eventName
                                                       level1:level1
                                                       level2:level2
                                                       level3:level3
                                                reportTrigger:reportTrigger
                                                   properties:propertiesJSON];
    
    // 上报事件
    [self reportEvent:eventModel completion:completion];
}

#pragma mark - 便利方法 - 首页相关事件

- (void)reportClickBannerWithId:(NSString *)bannerId name:(NSString *)bannerName {
    NSDictionary *properties = @{
        kAnalyticsProperty_BannerId: bannerId ?: @"",
        kAnalyticsProperty_BannerName: bannerName ?: @""
    };
    
    [self reportEventWithName:kAnalyticsEvent_ClickBanner
                       level1:kAnalyticsLevel1_Home
                       level2:nil
                       level3:nil
                reportTrigger:kAnalyticsTrigger_OnClick
                   properties:properties
                   completion:nil];
}

- (void)reportAddDeviceClickWithPid:(NSString *)pid {
    NSDictionary *properties = @{
        kAnalyticsProperty_PID: pid ?: @""
    };

    [self reportEventWithName:kAnalyticsEvent_AddDevice_Click
                       level1:kAnalyticsLevel1_Home
                       level2:kAnalyticsLevel2_AddDevice
                       level3:nil
                reportTrigger:kAnalyticsTrigger_OnClick
                   properties:properties
                   completion:nil];
}

- (void)reportAddDeviceManualClickWithPid:(NSString *)pid {
    NSDictionary *properties = @{
        kAnalyticsProperty_PID: pid ?: @""
    };

    [self reportEventWithName:kAnalyticsEvent_AddDevice_ManualClick
                       level1:kAnalyticsLevel1_Home
                       level2:kAnalyticsLevel2_AddDevice
                       level3:nil
                reportTrigger:kAnalyticsTrigger_OnClick
                   properties:properties
                   completion:nil];
}



- (void)reportAddDeviceSuccessWithDeviceId:(NSString *)deviceId pid:(NSString *)pid {
    NSDictionary *properties = @{
        kAnalyticsProperty_DeviceId: deviceId ?: @"",
        kAnalyticsProperty_PID: pid ?: @""
    };
    
    [self reportEventWithName:kAnalyticsEvent_AddDevice_Success
                       level1:kAnalyticsLevel1_Home
                       level2:kAnalyticsLevel2_AddDevice
                       level3:nil
                reportTrigger:kAnalyticsTrigger_OnDeviceActivated
                   properties:properties
                   completion:nil];
}

- (void)reportAddDeviceFailedWithErrorCode:(NSInteger)errorCode {
    NSDictionary *properties = @{
        kAnalyticsProperty_ErrorCode: [NSString stringWithFormat:@"%ld", (long)errorCode]
    };
    
    [self reportEventWithName:kAnalyticsEvent_AddDevice_Failed
                       level1:kAnalyticsLevel1_Home
                       level2:kAnalyticsLevel2_AddDevice
                       level3:nil
                reportTrigger:kAnalyticsTrigger_OnAddFailed
                   properties:properties
                   completion:nil];
}

- (void)reportMyDeviceClickWithDeviceId:(NSString *)deviceId pid:(NSString *)pid {
    NSLog(@"[AnalyticsManager] 调用 reportMyDeviceClickWithDeviceId - deviceId: %@, pid: %@", deviceId ?: @"nil", pid ?: @"nil");

    NSDictionary *properties = @{
        kAnalyticsProperty_DeviceId: deviceId ?: @"",
        kAnalyticsProperty_PID: pid ?: @""
    };

    [self reportEventWithName:kAnalyticsEvent_MyDevice_Click
                       level1:kAnalyticsLevel1_Home
                       level2:kAnalyticsLevel2_DevicePanel
                       level3:nil
                reportTrigger:kAnalyticsTrigger_OnClick
                   properties:properties
                   completion:nil];
}

- (void)reportMyDollClickWithId:(NSString *)dollId name:(NSString *)dollName {
    NSDictionary *properties = @{
        kAnalyticsProperty_DollId: dollId ?: @"",
        kAnalyticsProperty_DollName: dollName ?: @""
    };

    [self reportEventWithName:kAnalyticsEvent_MyDoll_Click
                       level1:kAnalyticsLevel1_Home
                       level2:nil
                       level3:nil
                reportTrigger:kAnalyticsTrigger_OnClick
                   properties:properties
                   completion:nil];
}

- (void)reportDiscoverCreativeDollWithId:(NSString *)dollId name:(NSString *)dollName {
    NSDictionary *properties = @{
        kAnalyticsProperty_DollId: dollId ?: @"",
        kAnalyticsProperty_DollName: dollName ?: @""
    };

    [self reportEventWithName:kAnalyticsEvent_DiscoverCreativeDoll
                       level1:kAnalyticsLevel1_Home
                       level2:nil
                       level3:nil
                reportTrigger:kAnalyticsTrigger_OnClick
                   properties:properties
                   completion:nil];
}

- (void)reportExploreClickDollWithId:(NSString *)dollId name:(NSString *)dollName {
    NSDictionary *properties = @{
        kAnalyticsProperty_DollId: dollId ?: @"",
        kAnalyticsProperty_DollName: dollName ?: @""
    };
    
    [self reportEventWithName:kAnalyticsEvent_Explore_ClickDoll
                       level1:kAnalyticsLevel1_Home
                       level2:nil
                       level3:nil
                reportTrigger:kAnalyticsTrigger_OnClick
                   properties:properties
                   completion:nil];
}

#pragma mark - 便利方法 - 账户相关事件



- (void)reportAccountLoginSuccessWithId:(NSString *)accountId 
                              loginTime:(NSString *)loginTime 
                                 region:(NSString *)region {
    NSDictionary *properties = @{
        kAnalyticsProperty_AccountId: accountId ?: @"",
        kAnalyticsProperty_LoginTime: loginTime ?: @"",
        kAnalyticsProperty_LoginRegion: region ?: @""
    };
    
    [self reportEventWithName:kAnalyticsEvent_Account_LoginSuccess
                       level1:kAnalyticsLevel1_Login
                       level2:nil
                       level3:nil
                reportTrigger:kAnalyticsTrigger_OnLoginSuccess
                   properties:properties
                   completion:nil];
}

#pragma mark - 便利方法 - 家庭相关事件

- (void)reportFamilyAddMemberWithPermission:(NSString *)permission
                                     homeId:(NSString *)homeId
                            familyMemberId:(NSString *)familyMemberId
                               homeOwnerId:(NSString *)homeOwnerId {
    NSDictionary *properties = @{
        kAnalyticsProperty_MemberPermission: permission ?: @"",
        kAnalyticsProperty_HomeId: homeId ?: @"",
        kAnalyticsProperty_FamilyMemberId: familyMemberId ?: @"",
        kAnalyticsProperty_HomeOwnerId: homeOwnerId ?: @""
    };

    [self reportEventWithName:kAnalyticsEvent_Family_AddMember
                       level1:kAnalyticsLevel1_Family
                       level2:kAnalyticsLevel2_AddMember
                       level3:nil
                reportTrigger:kAnalyticsTrigger_OnAddCompleted
                   properties:properties
                   completion:nil];
}

- (void)reportFamilyRemoveMemberWithHomeId:(NSString *)homeId
                          familyMemberId:(NSString *)familyMemberId
                             homeOwnerId:(NSString *)homeOwnerId {
    NSDictionary *properties = @{
        kAnalyticsProperty_HomeId: homeId ?: @"",
        kAnalyticsProperty_FamilyMemberId: familyMemberId ?: @"",
        kAnalyticsProperty_HomeOwnerId: homeOwnerId ?: @""
    };

    [self reportEventWithName:kAnalyticsEvent_Family_RemoveMember
                       level1:kAnalyticsLevel1_Family
                       level2:kAnalyticsLevel2_RemoveMember
                       level3:nil
                reportTrigger:kAnalyticsTrigger_OnRemoveCompleted
                   properties:properties
                   completion:nil];
}

- (void)reportFamilyModifyMemberPermissionWithPermission:(NSString *)permission {
    NSDictionary *properties = @{
        kAnalyticsProperty_MemberPermission: permission ?: @""
    };

    [self reportEventWithName:kAnalyticsEvent_Family_ModifyMemberPermission
                       level1:kAnalyticsLevel1_Family
                       level2:nil
                       level3:nil
                reportTrigger:kAnalyticsTrigger_OnModifyCompleted
                   properties:properties
                   completion:nil];
}

#pragma mark - 私有方法

- (void)fillUserInfoForEvent:(EventLogModel *)eventModel {
    // 不再自动填充用户ID到埋点数据中
    // 移除 memberUserId 字段以保护用户隐私
}

- (void)fillDeviceInfoForEvent:(EventLogModel *)eventModel {
    // 获取应用版本号
    NSString *appVersion = [self getCurrentAppVersion];
    if (appVersion && appVersion.length > 0) {
        eventModel.appVersion = appVersion;
    }

    // 获取系统版本号
    NSString *osVersion = [self getCurrentOSVersion];
    if (osVersion && osVersion.length > 0) {
        eventModel.osVersion = osVersion;
    }

    // 设置操作系统类型 (iOS = 1)
    eventModel.osType = @(1);
}

#pragma mark - 工具方法

- (nullable NSString *)propertiesJSONStringFromDictionary:(NSDictionary *)properties {
    if (!properties || properties.count == 0) {
        return nil;
    }

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:properties
                                                       options:0
                                                         error:&error];
    if (error) {
        NSLog(@"[AnalyticsManager] 属性字典转JSON失败: %@", error.localizedDescription);
        return nil;
    }

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (nullable NSNumber *)getCurrentUserId {
    // 从UserInfo获取当前用户ID
    if (kMyUser.userId && kMyUser.userId.length > 0) {
        return @([kMyUser.userId integerValue]);
    }
    return nil;
}

- (NSString *)getCurrentAppVersion {
    // 从Info.plist获取应用版本号
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return version ?: @"1.0";
}

- (NSString *)getCurrentOSVersion {
    // 获取iOS系统版本号
    return [[UIDevice currentDevice] systemVersion] ?: @"1.0";
}

@end
