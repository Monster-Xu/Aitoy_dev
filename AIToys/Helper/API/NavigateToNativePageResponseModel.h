//
//  NavigateToNativePageResponseModel.h
//  AIToys
//
//  Created by AI Assistant on 2025/8/19.
//

#import <Foundation/Foundation.h>
#import <ThingSmartMiniAppBizBundle/ThingMiniAppExtApiModelProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 原生页面跳转 API 响应数据模型
 * 实现 ThingMiniAppExtApiModelProtocol 协议
 */
@interface NavigateToNativePageResponseModel : NSObject <ThingMiniAppExtApiModelProtocol>

@property (nonatomic, assign, readonly) ThingMiniAppExtApiModelStatus status;
@property (nonatomic, copy,   readonly) NSString *errorCode;
@property (nonatomic, copy,   readonly) NSString *errorMsg;
@property (nonatomic, strong, readonly) id data;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * 创建成功响应模型
 */
+ (instancetype)successExtApiModel;

/**
 * 创建带数据的成功响应模型
 * @param data 响应数据
 */
+ (instancetype)successExtApiModelWithData:(nullable id)data;

/**
 * 创建失败响应模型
 * @param errorCode 错误码
 */
+ (instancetype)failureExtApiModel:(nullable NSString *)errorCode;

/**
 * 创建带错误信息的失败响应模型
 * @param errorCode 错误码
 * @param errorMsg 错误信息
 */
+ (instancetype)failureExtApiModel:(nullable NSString *)errorCode
                          errorMsg:(nullable NSString *)errorMsg;

@end

NS_ASSUME_NONNULL_END
