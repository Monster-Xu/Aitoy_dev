//
//  AnalyticsUsageExample.m
//  AIToys
//
//  Created by AI Assistant on 2025/8/21.
//

#import "AnalyticsUsageExample.h"
#import "AnalyticsManager.h"

@implementation AnalyticsUsageExample

+ (void)analyticsControlExamples {
    NSLog(@"=== 埋点开关控制示例 ===");

    // 1. 加载用户权限设置（通常在首页调用）
    [[AnalyticsManager sharedManager] loadUserPermissionsWithCompletion:^(BOOL success) {
        NSLog(@"权限加载%@", success ? @"成功" : @"失败");
    }];

    // 2. 设置埋点开关（同时更新缓存和服务器）
    [[AnalyticsManager sharedManager] setAnalyticsEnabled:YES completion:^(BOOL success) {
        NSLog(@"埋点开关设置%@", success ? @"成功" : @"失败");
    }];

    // 3. 仅更新本地缓存（向后兼容）
    [[AnalyticsManager sharedManager] setAnalyticsEnabled:NO];

    // 4. 检查埋点状态（从缓存读取）
    BOOL isEnabled = [[AnalyticsManager sharedManager] isAnalyticsEnabled];
    NSLog(@"埋点状态: %@", isEnabled ? @"已启用" : @"已禁用");

    // 注意：当埋点被禁用时，所有埋点上报都会被跳过
}

+ (void)homePageExamples {
    NSLog(@"=== 首页相关埋点使用示例 ===");
    
    // 1. 点击运营banner
    [[AnalyticsManager sharedManager] reportClickBannerWithId:@"banner_001" 
                                                          name:@"新年活动banner"];
    
    // 2. 点击添加设备（自动配网）
    [[AnalyticsManager sharedManager] reportAddDeviceClickWithPid:DEVICE_PRODUCT_ID];

    // 3. 点击添加设备（手动添加）
    [[AnalyticsManager sharedManager] reportAddDeviceManualClickWithPid:DEVICE_PRODUCT_ID];

    // 4. 设备添加成功
    [[AnalyticsManager sharedManager] reportAddDeviceSuccessWithDeviceId:@"device_123"
                                                                     pid:DEVICE_PRODUCT_ID];
    
    // 5. 设备添加失败
    [[AnalyticsManager sharedManager] reportAddDeviceFailedWithErrorCode:1001]; // 直接传入错误码数字
    
    // 6. 点击我的设备
    [[AnalyticsManager sharedManager] reportMyDeviceClickWithDeviceId:@"device_123" pid:DEVICE_PRODUCT_ID];
    
    // 7. 点击我的公仔
    [[AnalyticsManager sharedManager] reportMyDollClickWithId:@"doll_001"
                                                          name:@"小熊公仔"];

    // 8. 发现创意公仔
    [[AnalyticsManager sharedManager] reportDiscoverCreativeDollWithId:@"doll_C001"
                                                                   name:@"创意小熊公仔"];
    
    // 9. 探索页面点击公仔
    [[AnalyticsManager sharedManager] reportExploreClickDollWithId:@"doll_002" 
                                                              name:@"小兔公仔"];
}

+ (void)authenticationExamples {
    NSLog(@"=== 登录相关埋点使用示例 ===");

    // 登录成功
    [[AnalyticsManager sharedManager] reportAccountLoginSuccessWithId:@"user_123" 
                                                            loginTime:@"2025-08-21 10:35:00" 
                                                               region:@"CN"];
}

+ (void)deviceExamples {
    NSLog(@"=== 设备相关埋点使用示例 ===");
    
    // 使用自定义属性的设备事件
    NSDictionary *deviceProperties = @{
        @"device_type": @"smart_toy",
        @"firmware_version": @"1.2.3",
        @"battery_level": @"85%"
    };
    
    [[AnalyticsManager sharedManager] reportEventWithName:@"设备状态检查"
                                                    level1:kAnalyticsLevel1_Home
                                                    level2:@"设备管理"
                                                    level3:@"状态监控"
                                             reportTrigger:@"定时检查"
                                                properties:deviceProperties
                                                completion:^(BOOL success, NSString * _Nullable message) {
        if (success) {
            NSLog(@"设备状态埋点上报成功: %@", message);
        } else {
            NSLog(@"设备状态埋点上报失败: %@", message);
        }
    }];
}

+ (void)familyExamples {
    NSLog(@"=== 家庭相关埋点使用示例 ===");
    
    // 1. 添加家庭成员
    [[AnalyticsManager sharedManager] reportFamilyAddMemberWithPermission:kAnalyticsPermission_Admin
                                                                    homeId:@"259105712"
                                                           familyMemberId:@"240056360"
                                                              homeOwnerId:@"az1754967928341QVbwf"];
    
    // 2. 移除家庭成员
    [[AnalyticsManager sharedManager] reportFamilyRemoveMemberWithHomeId:@"259105712"
                                                         familyMemberId:@"240056360"
                                                            homeOwnerId:@"az1754967928341QVbwf"];
    
    // 3. 修改成员权限
    [[AnalyticsManager sharedManager] reportFamilyModifyMemberPermissionWithPermission:kAnalyticsPermission_Normal];
}

@end
