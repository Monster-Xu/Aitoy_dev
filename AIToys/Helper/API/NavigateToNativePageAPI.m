//
//  NavigateToNativePageAPI.m
//  AIToys
//
//  Created by AI Assistant on 2025/8/19.
//

#import "NavigateToNativePageAPI.h"
#import "NavigateToNativePageResponseModel.h"
#import <UIKit/UIKit.h>
#import "FindDeviceViewController.h"
#import "MyNavigationController.h"
#import "CoreArchive.h"
#import "AppConfigureHeader.h"

// 支持的页面路径常量
static NSString * const kNavigatePageHome = @"home";
static NSString * const kNavigatePageProfile = @"profile";
static NSString * const kNavigatePageAddDevice = @"addDevice";

// 错误码常量
static NSString * const kErrorCodeInvalidPath = @"INVALID_PATH";
static NSString * const kErrorCodeNavigationFailed = @"NAVIGATION_FAILED";

@implementation NavigateToNativePageAPI

#pragma mark - ThingMiniAppExtApiProtocol Required Methods

- (NSString *)apiName {
    NSLog(@"[NavigateToNativePageAPI] apiName 被调用，返回: navigateToNativePage");
    return @"navigateToNativePage";
}

#pragma mark - ThingMiniAppExtApiProtocol Optional Methods

- (BOOL)canIUseExtApi {
    NSLog(@"[NavigateToNativePageAPI] canIUseExtApi 被调用，返回: YES");
    return YES;
}

- (void)invokeExtApi:(nonnull id<ThingMiniAppExtApiContext>)context
              params:(nullable NSDictionary *)params
             success:(nonnull ThingMiniExtApiResponseCallback)success
                fail:(nonnull ThingMiniExtApiResponseCallback)fail {

    NSLog(@"[NavigateToNativePageAPI] ========== API 调用开始 ==========");
    NSLog(@"[NavigateToNativePageAPI] 接收到的参数: %@", params);
    NSLog(@"[NavigateToNativePageAPI] context: %@", context);

    // 参数验证
    NSString *path = params[@"path"];
    NSLog(@"[NavigateToNativePageAPI] 解析出的 path 参数: %@", path ?: @"(nil)");
    if (!path || ![path isKindOfClass:[NSString class]] || path.length == 0) {
        NSLog(@"[NavigateToNativePageAPI] ❌ 参数验证失败: path 参数为空或无效");
        if (fail) {
            NavigateToNativePageResponseModel *failModel =
                [NavigateToNativePageResponseModel failureExtApiModel:kErrorCodeInvalidPath
                                                             errorMsg:@"参数 path 不能为空"];
            NSLog(@"[NavigateToNativePageAPI] 返回失败响应: %@", kErrorCodeInvalidPath);
            fail(failModel);
        }
        NSLog(@"[NavigateToNativePageAPI] ========== API 调用结束 (失败) ==========");
        return;
    }
    
    // 检查路径是否支持
    NSLog(@"[NavigateToNativePageAPI] 检查路径是否支持: %@", path);
    if (![self isSupportedPath:path]) {
        NSLog(@"[NavigateToNativePageAPI] ❌ 不支持的页面路径: %@", path);
        if (fail) {
            NavigateToNativePageResponseModel *failModel =
                [NavigateToNativePageResponseModel failureExtApiModel:kErrorCodeInvalidPath
                                                             errorMsg:[NSString stringWithFormat:@"不支持的页面路径: %@，支持的路径: home, profile, addDevice", path]];
            NSLog(@"[NavigateToNativePageAPI] 返回失败响应: %@", kErrorCodeInvalidPath);
            fail(failModel);
        }
        NSLog(@"[NavigateToNativePageAPI] ========== API 调用结束 (失败) ==========");
        return;
    }

    NSLog(@"[NavigateToNativePageAPI] ✅ 路径验证通过: %@", path);
    
    // 在主线程执行页面跳转
    NSLog(@"[NavigateToNativePageAPI] 准备在主线程执行页面跳转...");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[NavigateToNativePageAPI] 开始执行页面跳转到: %@", path);
        BOOL navigationSuccess = [self navigateToPage:path context:context];

        if (navigationSuccess) {
            NSLog(@"[NavigateToNativePageAPI] ✅ 页面跳转成功!");
            if (success) {
                NavigateToNativePageResponseModel *successModel =
                    [NavigateToNativePageResponseModel successExtApiModelWithData:@{
                        @"path": path,
                        @"message": @"页面跳转成功"
                    }];
                NSLog(@"[NavigateToNativePageAPI] 返回成功响应");
                success(successModel);
            }
        } else {
            NSLog(@"[NavigateToNativePageAPI] ❌ 页面跳转失败!");
            if (fail) {
                NavigateToNativePageResponseModel *failModel =
                    [NavigateToNativePageResponseModel failureExtApiModel:kErrorCodeNavigationFailed
                                                                 errorMsg:@"页面跳转失败"];
                NSLog(@"[NavigateToNativePageAPI] 返回失败响应: %@", kErrorCodeNavigationFailed);
                fail(failModel);
            }
        }
        NSLog(@"[NavigateToNativePageAPI] ========== API 调用结束 ==========");
    });
}

- (id<ThingMiniAppExtApiModelProtocol>)invokeExtApiSync:(nonnull id<ThingMiniAppExtApiContext>)context
                                                 params:(nullable NSDictionary *)params {
    // 同步方法不适用于页面跳转，返回错误
    return [NavigateToNativePageResponseModel failureExtApiModel:kErrorCodeNavigationFailed
                                                        errorMsg:@"页面跳转不支持同步调用"];
}

#pragma mark - MiniApp Lifecycle Methods

- (void)onMiniAppResume {
    NSLog(@"[NavigateToNativePageAPI] 🟢 小程序恢复 (onMiniAppResume)");
    // 小程序恢复时的处理逻辑（可选）
}

- (void)onMiniAppPause {
    NSLog(@"[NavigateToNativePageAPI] 🟡 小程序暂停 (onMiniAppPause)");
    // 小程序暂停时的处理逻辑（可选）
}

- (void)onMiniAppDestroy {
    NSLog(@"[NavigateToNativePageAPI] 🔴 小程序销毁 (onMiniAppDestroy)");
    // 小程序销毁时的处理逻辑（可选）
}

#pragma mark - Private Methods

/**
 * 检查路径是否支持
 */
- (BOOL)isSupportedPath:(NSString *)path {
    BOOL isSupported = [path isEqualToString:kNavigatePageHome] ||
                       [path isEqualToString:kNavigatePageProfile] ||
                       [path isEqualToString:kNavigatePageAddDevice];
    NSLog(@"[NavigateToNativePageAPI] isSupportedPath: %@ -> %@", path, isSupported ? @"YES" : @"NO");
    return isSupported;
}

/**
 * 执行页面跳转
 */
- (BOOL)navigateToPage:(NSString *)path context:(id<ThingMiniAppExtApiContext>)context {
    NSLog(@"[NavigateToNativePageAPI] navigateToPage 开始执行，目标路径: %@", path);

    UIViewController *currentViewController = [self getCurrentViewController];
    NSLog(@"[NavigateToNativePageAPI] 当前视图控制器: %@", currentViewController);
    if (!currentViewController) {
        NSLog(@"[NavigateToNativePageAPI] ❌ 无法获取当前视图控制器");
        return NO;
    }

    UITabBarController *tabBarController = [self getTabBarController];
    NSLog(@"[NavigateToNativePageAPI] TabBarController: %@", tabBarController);
    if (!tabBarController) {
        NSLog(@"[NavigateToNativePageAPI] ❌ 无法获取 TabBarController");
        return NO;
    }

    NSLog(@"[NavigateToNativePageAPI] TabBar 总共有 %ld 个页面", (long)tabBarController.viewControllers.count);
    NSLog(@"[NavigateToNativePageAPI] 当前选中的索引: %ld", (long)tabBarController.selectedIndex);

    // 打印每个 TabBar 页面的详细信息
    for (NSInteger i = 0; i < tabBarController.viewControllers.count; i++) {
        UIViewController *vc = tabBarController.viewControllers[i];
        NSString *title = vc.tabBarItem.title ?: @"(无标题)";
        NSString *className = NSStringFromClass([vc class]);
        NSLog(@"[NavigateToNativePageAPI] 页面 %ld: %@ (%@)", (long)i, title, className);
    }

    NSInteger targetIndex = -1;

    if ([path isEqualToString:kNavigatePageHome]) {
        targetIndex = 0; // 首页通常是第一个 tab
        NSLog(@"[NavigateToNativePageAPI] 目标页面: 首页，索引: %ld", (long)targetIndex);
    } else if ([path isEqualToString:kNavigatePageProfile]) {
        // 根据实际的 TabBar 页面数量调整，通常是最后一个
        targetIndex = tabBarController.viewControllers.count - 1;
        NSLog(@"[NavigateToNativePageAPI] 目标页面: 我的页面，索引: %ld (总页面数: %ld)", (long)targetIndex, (long)tabBarController.viewControllers.count);
    } else if ([path isEqualToString:kNavigatePageAddDevice]) {
        NSLog(@"[NavigateToNativePageAPI] 目标页面: 添加设备页面，需要 push 导航");
        // addDevice 不是 TabBar 页面，需要特殊处理
        return [self navigateToAddDevicePage:context];
    }

    if (targetIndex >= 0 && targetIndex < tabBarController.viewControllers.count) {
        NSInteger currentIndex = tabBarController.selectedIndex;

        if (currentIndex == targetIndex) {
            NSLog(@"[NavigateToNativePageAPI] ℹ️ 当前已经在目标页面 (索引: %ld)，关闭小程序返回原生页面", (long)targetIndex);

            // 即使已经在目标页面，也要关闭小程序返回到原生页面
            [self closeMiniAppAndReturnToNative:context];

            return YES;
        }

        NSLog(@"[NavigateToNativePageAPI] 执行跳转: 从索引 %ld 跳转到索引 %ld", (long)currentIndex, (long)targetIndex);
        tabBarController.selectedIndex = targetIndex;

        // 验证跳转是否成功
        NSInteger newIndex = tabBarController.selectedIndex;
        if (newIndex == targetIndex) {
            NSLog(@"[NavigateToNativePageAPI] ✅ 跳转成功，当前索引: %ld", (long)newIndex);

            // 关闭小程序，返回到原生页面
            [self closeMiniAppAndReturnToNative:context];

            return YES;
        } else {
            NSLog(@"[NavigateToNativePageAPI] ❌ 跳转失败，期望索引: %ld，实际索引: %ld", (long)targetIndex, (long)newIndex);
            return NO;
        }
    } else {
        NSLog(@"[NavigateToNativePageAPI] ❌ 目标索引无效: %ld (总页面数: %ld)", (long)targetIndex, (long)tabBarController.viewControllers.count);
    }

    return NO;
}

/**
 * 获取当前显示的视图控制器
 */
- (UIViewController *)getCurrentViewController {
    NSLog(@"[NavigateToNativePageAPI] getCurrentViewController 开始执行");
    UIWindow *keyWindow = nil;

    if (@available(iOS 13.0, *)) {
        NSLog(@"[NavigateToNativePageAPI] iOS 13+ 系统，使用 WindowScene 方式获取 keyWindow");
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        NSLog(@"[NavigateToNativePageAPI] 找到 keyWindow: %@", keyWindow);
                        break;
                    }
                }
                break;
            }
        }
    } else {
        NSLog(@"[NavigateToNativePageAPI] iOS 13 以下系统，使用传统方式获取 keyWindow");
        keyWindow = [UIApplication sharedApplication].keyWindow;
        NSLog(@"[NavigateToNativePageAPI] keyWindow: %@", keyWindow);
    }

    UIViewController *rootViewController = keyWindow.rootViewController;
    NSLog(@"[NavigateToNativePageAPI] rootViewController: %@", rootViewController);
    UIViewController *currentVC = [self findCurrentViewController:rootViewController];
    NSLog(@"[NavigateToNativePageAPI] 最终找到的当前视图控制器: %@", currentVC);
    return currentVC;
}

/**
 * 递归查找当前显示的视图控制器
 */
- (UIViewController *)findCurrentViewController:(UIViewController *)viewController {
    if (viewController.presentedViewController) {
        return [self findCurrentViewController:viewController.presentedViewController];
    }
    
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)viewController;
        return [self findCurrentViewController:tabBarController.selectedViewController];
    }
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        return [self findCurrentViewController:navigationController.visibleViewController];
    }
    
    return viewController;
}

/**
 * 获取 TabBarController
 */
- (UITabBarController *)getTabBarController {
    NSLog(@"[NavigateToNativePageAPI] getTabBarController 开始执行");
    UIViewController *currentViewController = [self getCurrentViewController];

    // 向上查找 TabBarController
    UIViewController *parentViewController = currentViewController;
    NSLog(@"[NavigateToNativePageAPI] 开始向上查找 TabBarController，起始控制器: %@", parentViewController);

    while (parentViewController) {
        NSLog(@"[NavigateToNativePageAPI] 检查控制器: %@", parentViewController);

        if ([parentViewController isKindOfClass:[UITabBarController class]]) {
            NSLog(@"[NavigateToNativePageAPI] ✅ 找到 TabBarController: %@", parentViewController);
            return (UITabBarController *)parentViewController;
        }

        if (parentViewController.navigationController) {
            NSLog(@"[NavigateToNativePageAPI] 找到 navigationController，继续向上查找");
            parentViewController = parentViewController.navigationController;
        }

        if (parentViewController.tabBarController) {
            NSLog(@"[NavigateToNativePageAPI] ✅ 通过 tabBarController 属性找到: %@", parentViewController.tabBarController);
            return parentViewController.tabBarController;
        }

        parentViewController = parentViewController.parentViewController;
        NSLog(@"[NavigateToNativePageAPI] 继续检查父控制器: %@", parentViewController);
    }

    NSLog(@"[NavigateToNativePageAPI] 向上查找失败，尝试从根视图控制器查找");

    // 如果没有找到，尝试从根视图控制器查找
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
                break;
            }
        }
    } else {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }

    NSLog(@"[NavigateToNativePageAPI] 检查根视图控制器: %@", keyWindow.rootViewController);
    if ([keyWindow.rootViewController isKindOfClass:[UITabBarController class]]) {
        NSLog(@"[NavigateToNativePageAPI] ✅ 根视图控制器就是 TabBarController: %@", keyWindow.rootViewController);
        return (UITabBarController *)keyWindow.rootViewController;
    }

    NSLog(@"[NavigateToNativePageAPI] ❌ 未找到 TabBarController");
    return nil;
}

/**
 * 关闭小程序并返回到原生页面
 */
- (void)closeMiniAppAndReturnToNative:(id<ThingMiniAppExtApiContext>)context {
    NSLog(@"[NavigateToNativePageAPI] 开始关闭小程序...");

    // 立即执行关闭操作
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[NavigateToNativePageAPI] 执行关闭小程序操作");

        // 方法1: 尝试通过 context 关闭（如果支持）
        if (context && [context respondsToSelector:@selector(closeMiniApp)]) {
            NSLog(@"[NavigateToNativePageAPI] 通过 context 关闭小程序");
            [context performSelector:@selector(closeMiniApp)];
            return;
        }

        // 方法2: 查找小程序相关的视图控制器并关闭
        [self findAndCloseMiniAppViewController];
    });
}

/**
 * 查找并关闭小程序视图控制器
 */
- (void)findAndCloseMiniAppViewController {
    NSLog(@"[NavigateToNativePageAPI] 查找小程序视图控制器...");

    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
                break;
            }
        }
    } else {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }

    UIViewController *rootVC = keyWindow.rootViewController;
    [self searchAndCloseMiniAppInViewController:rootVC];
}

/**
 * 递归搜索并关闭小程序视图控制器
 */
- (void)searchAndCloseMiniAppInViewController:(UIViewController *)viewController {
    if (!viewController) return;

    NSString *className = NSStringFromClass([viewController class]);
    NSLog(@"[NavigateToNativePageAPI] 检查视图控制器: %@", className);

    // 检查是否是小程序相关的视图控制器
    if ([className containsString:@"MiniApp"] || [className containsString:@"GZL"]) {
        NSLog(@"[NavigateToNativePageAPI] 找到小程序视图控制器: %@", className);

        // 优先尝试通过导航控制器 pop
        if (viewController.navigationController && viewController.navigationController.viewControllers.count > 1) {
            NSLog(@"[NavigateToNativePageAPI] 通过 navigationController pop 关闭");
            [viewController.navigationController popViewControllerAnimated:YES];
            return;
        }

        // 如果是 presented 的，则 dismiss
        if (viewController.presentingViewController) {
            NSLog(@"[NavigateToNativePageAPI] 通过 presentingViewController 关闭");
            [viewController dismissViewControllerAnimated:YES completion:^{
                NSLog(@"[NavigateToNativePageAPI] ✅ 小程序已关闭");
            }];
            return;
        }

        // 尝试从父视图控制器中移除
        if (viewController.parentViewController) {
            NSLog(@"[NavigateToNativePageAPI] 从父视图控制器中移除");
            [viewController willMoveToParentViewController:nil];
            [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
            return;
        }
    }

    // 检查 presented 视图控制器
    if (viewController.presentedViewController) {
        [self searchAndCloseMiniAppInViewController:viewController.presentedViewController];
        return; // 找到 presented 的就不继续往下找了
    }

    // 检查 TabBarController 的子控制器
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)viewController;
        [self searchAndCloseMiniAppInViewController:tabBarController.selectedViewController];
        return;
    }

    // 检查 NavigationController 的栈顶控制器
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)viewController;
        [self searchAndCloseMiniAppInViewController:navController.topViewController];
        return;
    }

    // 最后检查子视图控制器
    for (UIViewController *childVC in viewController.childViewControllers) {
        [self searchAndCloseMiniAppInViewController:childVC];
    }
}

/**
 * 跳转到添加设备页面
 */
- (BOOL)navigateToAddDevicePage:(id<ThingMiniAppExtApiContext>)context {
    NSLog(@"[NavigateToNativePageAPI] navigateToAddDevicePage 开始执行");

    // 先关闭小程序，然后再进行页面跳转
    NSLog(@"[NavigateToNativePageAPI] 先关闭小程序，然后跳转到添加设备页面");
    [self closeMiniAppAndReturnToNative:context];

    // 延迟执行页面跳转，确保小程序关闭完成
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"[NavigateToNativePageAPI] 开始执行添加设备页面跳转");

        // 获取主应用的导航控制器
        UINavigationController *navigationController = [self getCurrentNavigationController];
        if (!navigationController) {
            NSLog(@"[NavigateToNativePageAPI] ❌ 无法获取导航控制器");
            return;
        }

        NSLog(@"[NavigateToNativePageAPI] 找到导航控制器: %@", navigationController);

        // 创建 FindDeviceViewController
        FindDeviceViewController *findDeviceVC = [[FindDeviceViewController alloc] init];

        // 设置 homeId
        NSString *currentHomeId = [self getCurrentHomeId];
        if (currentHomeId) {
            findDeviceVC.homeId = [currentHomeId longLongValue];
            NSLog(@"[NavigateToNativePageAPI] 设置 homeId: %@", currentHomeId);
        } else {
            NSLog(@"[NavigateToNativePageAPI] ⚠️ 无法获取 homeId，使用默认值");
            findDeviceVC.homeId = 0;
        }

        NSLog(@"[NavigateToNativePageAPI] 创建 FindDeviceViewController: %@", findDeviceVC);

        // Push 到导航栈
        [navigationController pushViewController:findDeviceVC animated:YES];
        NSLog(@"[NavigateToNativePageAPI] ✅ 成功 push FindDeviceViewController 到主应用导航栈");
    });

    return YES;
}

/**
 * 获取当前的导航控制器（优先获取主应用的导航控制器）
 */
- (UINavigationController *)getCurrentNavigationController {
    NSLog(@"[NavigateToNativePageAPI] getCurrentNavigationController 开始执行");

    // 方法1: 优先从 TabBarController 获取主应用的导航控制器
    UITabBarController *tabBarController = [self getTabBarController];
    if (tabBarController && tabBarController.selectedViewController) {
        UIViewController *selectedVC = tabBarController.selectedViewController;
        NSLog(@"[NavigateToNativePageAPI] TabBar 选中的控制器: %@", selectedVC);

        if ([selectedVC isKindOfClass:[UINavigationController class]]) {
            NSLog(@"[NavigateToNativePageAPI] ✅ 找到主应用的导航控制器");
            return (UINavigationController *)selectedVC;
        }

        if (selectedVC.navigationController) {
            NSLog(@"[NavigateToNativePageAPI] ✅ 通过 TabBar 选中控制器找到导航控制器");
            return selectedVC.navigationController;
        }
    }

    // 方法2: 从当前视图控制器获取（可能是小程序的导航控制器）
    UIViewController *currentVC = [self getCurrentViewController];
    NSLog(@"[NavigateToNativePageAPI] 当前视图控制器: %@", currentVC);

    // 跳过小程序相关的导航控制器，查找主应用的
    if (currentVC.navigationController) {
        NSString *navClassName = NSStringFromClass([currentVC.navigationController class]);
        if (![navClassName containsString:@"MiniApp"] && ![navClassName containsString:@"GZL"]) {
            NSLog(@"[NavigateToNativePageAPI] ✅ 找到非小程序的导航控制器: %@", navClassName);
            return currentVC.navigationController;
        } else {
            NSLog(@"[NavigateToNativePageAPI] ⚠️ 跳过小程序导航控制器: %@", navClassName);
        }
    }

    // 方法3: 直接检查是否是导航控制器
    if ([currentVC isKindOfClass:[UINavigationController class]]) {
        NSString *className = NSStringFromClass([currentVC class]);
        if (![className containsString:@"MiniApp"] && ![className containsString:@"GZL"]) {
            NSLog(@"[NavigateToNativePageAPI] ✅ 当前控制器就是主应用导航控制器");
            return (UINavigationController *)currentVC;
        }
    }

    NSLog(@"[NavigateToNativePageAPI] ❌ 未找到合适的导航控制器");
    return nil;
}

/**
 * 获取当前的 homeId
 */
- (NSString *)getCurrentHomeId {
    NSLog(@"[NavigateToNativePageAPI] getCurrentHomeId 开始执行");

    // 方法1: 使用正确的 key 从 CoreArchive 获取 (KCURRENT_HOME_ID 定义为 "KHomeID")
    NSString *homeId = [CoreArchive strForKey:KCURRENT_HOME_ID];
    if (homeId && homeId.length > 0 && ![homeId isEqualToString:@"(null)"]) {
        NSLog(@"[NavigateToNativePageAPI] 从 CoreArchive 获取到 homeId: %@", homeId);
        return homeId;
    }

    // 方法2: 直接使用 "KHomeID" key
    homeId = [CoreArchive strForKey:@"KHomeID"];
    if (homeId && homeId.length > 0 && ![homeId isEqualToString:@"(null)"]) {
        NSLog(@"[NavigateToNativePageAPI] 从 CoreArchive (KHomeID) 获取到 homeId: %@", homeId);
        return homeId;
    }

    // 方法3: 从 UserDefaults 获取
    homeId = [[NSUserDefaults standardUserDefaults] stringForKey:KCURRENT_HOME_ID];
    if (homeId && homeId.length > 0 && ![homeId isEqualToString:@"(null)"]) {
        NSLog(@"[NavigateToNativePageAPI] 从 UserDefaults 获取到 homeId: %@", homeId);
        return homeId;
    }

    // 方法4: 从 UserDefaults 直接使用 "KHomeID" key
    homeId = [[NSUserDefaults standardUserDefaults] stringForKey:@"KHomeID"];
    if (homeId && homeId.length > 0 && ![homeId isEqualToString:@"(null)"]) {
        NSLog(@"[NavigateToNativePageAPI] 从 UserDefaults (KHomeID) 获取到 homeId: %@", homeId);
        return homeId;
    }

    // 方法5: 尝试通过 ThingSmartSDK 获取当前用户的默认家庭
    NSLog(@"[NavigateToNativePageAPI] 尝试通过 ThingSmartSDK 获取默认家庭...");
    // 这里可以添加通过 SDK 获取的逻辑，但需要异步处理

    NSLog(@"[NavigateToNativePageAPI] ❌ 无法获取 homeId，将使用默认值 0");
    return nil;
}

@end
