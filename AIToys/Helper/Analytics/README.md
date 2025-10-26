# 埋点系统使用说明

## 概述

本埋点系统为AIToys项目提供完整的用户行为数据收集功能，支持自动收集设备信息、用户信息，并提供便利的API接口进行事件上报。

## 文件结构

```
AIToys/Helper/Analytics/
├── EventLogModel.h/.m          # 埋点事件数据模型
├── AnalyticsConstants.h/.m     # 埋点常量定义
├── AnalyticsManager.h/.m       # 埋点管理器
├── AnalyticsUsageExample.h/.m  # 使用示例
└── README.md                   # 使用说明
```

## 核心组件

### 1. EventLogModel
埋点事件的数据模型，包含以下字段：
- `eventTime`: 事件发生时间（必填，自动生成）
- ~~`memberUserId`: 用户ID（已移除，保护用户隐私）~~
- `appVersion`: 应用版本号（自动获取）
- `osType`: 操作系统类型（iOS=1，自动设置）
- `osVersion`: 系统版本号（自动获取）
- `level1/level2/level3`: 事件层级
- `eventName`: 事件名称（必填）
- `reportTrigger`: 上报时机
- `properties`: 事件属性（JSON格式）

### 2. AnalyticsConstants
定义了所有埋点相关的常量，包括：
- 层级常量（如 `kAnalyticsLevel1_Home`）
- 事件名称常量（如 `kAnalyticsEvent_ClickBanner`）
- 上报时机常量（如 `kAnalyticsTrigger_OnClick`）
- 属性键常量（如 `kAnalyticsProperty_BannerId`）

### 3. AnalyticsManager
埋点管理器，提供单例模式，主要功能：
- 自动收集用户信息和设备信息
- 提供便利的埋点上报方法
- 处理网络请求和错误处理

## 使用方法

### 1. 埋点开关控制

```objc
#import "AnalyticsManager.h"

// 启用埋点（默认启用）
[[AnalyticsManager sharedManager] setAnalyticsEnabled:YES];

// 禁用埋点
[[AnalyticsManager sharedManager] setAnalyticsEnabled:NO];

// 检查埋点状态
BOOL isEnabled = [[AnalyticsManager sharedManager] isAnalyticsEnabled];
```

**重要说明**：
- 埋点开关与用户的"功能体验升级计划"权限绑定
- 当用户关闭"功能体验升级计划"时，所有埋点上报将被跳过
- 默认情况下埋点是启用的

### 2. 基础使用

```objc
#import "AnalyticsManager.h"

// 简单的事件上报
[[AnalyticsManager sharedManager] reportClickBannerWithId:@"banner_001" 
                                                      name:@"新年活动banner"];
```

### 2. 自定义事件上报

```objc
// 使用自定义属性
NSDictionary *properties = @{
    @"custom_key": @"custom_value",
    @"user_action": @"swipe_left"
};

[[AnalyticsManager sharedManager] reportEventWithName:@"自定义事件"
                                                level1:@"首页"
                                                level2:@"轮播图"
                                                level3:nil
                                         reportTrigger:@"滑动时"
                                            properties:properties
                                            completion:^(BOOL success, NSString *message) {
    if (success) {
        NSLog(@"埋点上报成功");
    } else {
        NSLog(@"埋点上报失败: %@", message);
    }
}];
```

### 3. 预定义的便利方法

#### 首页相关
```objc
// 点击运营banner
[[AnalyticsManager sharedManager] reportClickBannerWithId:@"banner_001" name:@"活动banner"];

// 添加设备点击
[[AnalyticsManager sharedManager] reportAddDeviceClickWithPid:@"product_123"];

// 设备添加成功
[[AnalyticsManager sharedManager] reportAddDeviceSuccessWithDeviceId:@"device_123" pid:@"product_123"];
```

#### 账户相关
```objc
// 登录成功
[[AnalyticsManager sharedManager] reportAccountLoginSuccessWithId:@"user_123"
                                                        loginTime:@"2025-08-21 10:35:00"
                                                           region:@"CN"];
```

#### 家庭相关
```objc
// 添加家庭成员
[[AnalyticsManager sharedManager] reportFamilyAddMemberWithPermission:kAnalyticsPermission_Admin
                                                                homeId:@"259105712"
                                                       familyMemberId:@"240056360"
                                                          homeOwnerId:@"az1754967928341QVbwf"];

// 移除家庭成员
[[AnalyticsManager sharedManager] reportFamilyRemoveMemberWithHomeId:@"259105712"
                                                     familyMemberId:@"240056360"
                                                        homeOwnerId:@"az1754967928341QVbwf"];
```

## 接口配置

埋点上报接口已在 `APIPortConfiguration` 中配置：
- 接口地址：`/app-api/content/app-event-log/create`
- 请求方式：POST
- 内容类型：application/json

## 自动收集的信息

系统会自动收集以下信息：
1. **用户信息**：当前登录用户的ID
2. **设备信息**：
   - 应用版本号（从Info.plist获取）
   - 系统版本号（iOS系统版本）
   - 操作系统类型（iOS=1）
3. **时间信息**：事件发生的准确时间

## 注意事项

1. **网络依赖**：埋点上报需要网络连接，建议在网络可用时进行
2. **性能考虑**：埋点上报是异步进行的，不会阻塞主线程
3. **错误处理**：系统会自动处理网络错误，并在控制台输出日志
4. **数据格式**：属性数据会自动转换为JSON格式
5. **用户隐私**：只收集必要的用户行为数据，不涉及敏感信息

## 扩展使用

如需添加新的埋点事件：
1. 在 `AnalyticsConstants.h/.m` 中定义新的常量
2. 在 `AnalyticsManager.h/.m` 中添加对应的便利方法
3. 按照现有模式实现具体的上报逻辑

## 调试

在开发阶段，可以通过控制台日志查看埋点上报的详细信息：
```
[AnalyticsManager] 上报埋点事件: {...}
[AnalyticsManager] 埋点上报成功: 操作成功
```
