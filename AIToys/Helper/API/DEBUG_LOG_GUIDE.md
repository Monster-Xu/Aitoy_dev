# 调试日志查看指南

## 概述

我已经为 `NavigateToNativePageAPI` 添加了详细的调试日志，现在您可以在 iOS 控制台中看到 API 的完整调用过程。

## 日志标识

所有日志都以 `[NavigateToNativePageAPI]` 开头，便于过滤和查找：

```
[NavigateToNativePageAPI] ========== API 调用开始 ==========
[NavigateToNativePageAPI] 接收到的参数: {path = "home"}
[NavigateToNativePageAPI] ✅ 页面跳转成功!
[NavigateToNativePageAPI] ========== API 调用结束 ==========
```

## 如何查看日志

### 1. Xcode 控制台
1. 在 Xcode 中运行项目
2. 打开 **Console** 面板 (View → Debug Area → Console)
3. 在小程序中调用 API
4. 查看控制台输出

### 2. 过滤日志
在 Xcode 控制台底部的搜索框中输入：
```
NavigateToNativePageAPI
```

### 3. 设备控制台 (真机调试)
1. 打开 **Console.app** (在 Applications/Utilities 中)
2. 连接您的设备
3. 选择您的设备
4. 在搜索框中输入 `NavigateToNativePageAPI`

## 日志内容说明

### 应用启动时的日志
```
========== 开始注册自定义 MiniApp API ==========
创建 NavigateToNativePageAPI 实例...
NavigateToNativePageAPI 实例创建成功: <NavigateToNativePageAPI: 0x...>
获取 ThingMiniAppClient developClient...
developClient: <...>
注册 API 到 developClient...
✅ 自定义 MiniApp API 注册完成!
API 名称: navigateToNativePage
API 是否可用: YES
========== 自定义 MiniApp API 注册结束 ==========
```

### API 调用时的日志
```
[NavigateToNativePageAPI] ========== API 调用开始 ==========
[NavigateToNativePageAPI] 接收到的参数: {
    path = "home";
}
[NavigateToNativePageAPI] context: <...>
[NavigateToNativePageAPI] 解析出的 path 参数: home
[NavigateToNativePageAPI] 检查路径是否支持: home
[NavigateToNativePageAPI] isSupportedPath: home -> YES
[NavigateToNativePageAPI] ✅ 路径验证通过: home
[NavigateToNativePageAPI] 准备在主线程执行页面跳转...
[NavigateToNativePageAPI] 开始执行页面跳转到: home
```

### 页面跳转过程的日志
```
[NavigateToNativePageAPI] navigateToPage 开始执行，目标路径: home
[NavigateToNativePageAPI] getCurrentViewController 开始执行
[NavigateToNativePageAPI] iOS 13+ 系统，使用 WindowScene 方式获取 keyWindow
[NavigateToNativePageAPI] 找到 keyWindow: <UIWindow: 0x...>
[NavigateToNativePageAPI] rootViewController: <MyTabBarController: 0x...>
[NavigateToNativePageAPI] 最终找到的当前视图控制器: <HomeViewController: 0x...>
[NavigateToNativePageAPI] 当前视图控制器: <HomeViewController: 0x...>
[NavigateToNativePageAPI] getTabBarController 开始执行
[NavigateToNativePageAPI] ✅ 通过 tabBarController 属性找到: <MyTabBarController: 0x...>
[NavigateToNativePageAPI] TabBarController: <MyTabBarController: 0x...>
[NavigateToNativePageAPI] TabBar 总共有 4 个页面
[NavigateToNativePageAPI] 当前选中的索引: 2
[NavigateToNativePageAPI] 目标页面: 首页，索引: 0
[NavigateToNativePageAPI] 执行跳转: 从索引 2 跳转到索引 0
[NavigateToNativePageAPI] ✅ 跳转完成，当前索引: 0
[NavigateToNativePageAPI] ✅ 页面跳转成功!
[NavigateToNativePageAPI] 返回成功响应
[NavigateToNativePageAPI] ========== API 调用结束 ==========
```

### 错误情况的日志
```
[NavigateToNativePageAPI] ❌ 参数验证失败: path 参数为空或无效
[NavigateToNativePageAPI] 返回失败响应: INVALID_PATH
[NavigateToNativePageAPI] ========== API 调用结束 (失败) ==========
```

## 小程序生命周期日志
```
[NavigateToNativePageAPI] 🟢 小程序恢复 (onMiniAppResume)
[NavigateToNativePageAPI] 🟡 小程序暂停 (onMiniAppPause)
[NavigateToNativePageAPI] 🔴 小程序销毁 (onMiniAppDestroy)
```

## 测试建议

### 1. 测试正常跳转
在小程序中调用：
```javascript
ty.extApiInvoke({
    api: 'navigateToNativePage',
    params: { path: 'home' },
    success: (res) => console.log('成功:', res),
    fail: (err) => console.log('失败:', err)
});
```

### 2. 测试错误处理
```javascript
// 测试空参数
ty.extApiInvoke({
    api: 'navigateToNativePage',
    params: { path: '' },
    success: (res) => console.log('成功:', res),
    fail: (err) => console.log('失败:', err)
});

// 测试无效路径
ty.extApiInvoke({
    api: 'navigateToNativePage',
    params: { path: 'invalid' },
    success: (res) => console.log('成功:', res),
    fail: (err) => console.log('失败:', err)
});
```

## 常见问题排查

### 1. 看不到任何日志
- 确认项目已正确编译和运行
- 检查 AppDelegate 中的注册代码是否被调用
- 确认小程序确实调用了 API

### 2. API 注册失败
查看启动日志中是否有：
```
✅ 自定义 MiniApp API 注册完成!
```

### 3. 页面跳转失败
查看日志中的：
- TabBarController 是否找到
- 目标索引是否有效
- 当前页面数量是否正确

### 4. 调整 TabBar 索引
如果跳转到错误的页面，请修改 `NavigateToNativePageAPI.m` 中的索引：
```objective-c
if ([path isEqualToString:kNavigatePageHome]) {
    targetIndex = 0; // 修改为实际的首页索引
} else if ([path isEqualToString:kNavigatePageProfile]) {
    targetIndex = 3; // 修改为实际的我的页面索引
}
```

## 日志符号说明

- ✅ 成功操作
- ❌ 失败操作
- 🟢 小程序恢复
- 🟡 小程序暂停
- 🔴 小程序销毁

现在您应该能够在 iOS 控制台中看到详细的 API 调用日志了！
