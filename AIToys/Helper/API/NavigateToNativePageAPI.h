//
//  NavigateToNativePageAPI.h
//  AIToys
//
//  Created by AI Assistant on 2025/8/19.
//

#import <Foundation/Foundation.h>
#import <ThingSmartMiniAppBizBundle/ThingMiniAppExtApiProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 原生页面跳转自定义 API
 * 实现 ThingMiniAppExtApiProtocol 协议
 *
 * 支持的页面路径：
 * - "home": 跳转到首页
 * - "profile": 跳转到我的页面
 * - "addDevice": 跳转到添加设备页面
 */
@interface NavigateToNativePageAPI : NSObject <ThingMiniAppExtApiProtocol>

@end

NS_ASSUME_NONNULL_END
