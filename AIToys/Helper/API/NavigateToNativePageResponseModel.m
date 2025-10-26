//
//  NavigateToNativePageResponseModel.m
//  AIToys
//
//  Created by AI Assistant on 2025/8/19.
//

#import "NavigateToNativePageResponseModel.h"

@interface NavigateToNativePageResponseModel ()

@property (nonatomic, assign, readwrite) ThingMiniAppExtApiModelStatus status;
@property (nonatomic, copy,   readwrite) NSString *errorCode;
@property (nonatomic, copy,   readwrite) NSString *errorMsg;
@property (nonatomic, strong, readwrite) id data;

@end

@implementation NavigateToNativePageResponseModel

#pragma mark - Private Initializer

- (instancetype)initWithStatus:(ThingMiniAppExtApiModelStatus)status
                     errorCode:(nullable NSString *)errorCode
                      errorMsg:(nullable NSString *)errorMsg
                          data:(nullable id)data {
    if (self = [super init]) {
        _status = status;
        _errorCode = errorCode ?: @"";
        _errorMsg = errorMsg ?: @"";
        _data = data;
    }
    return self;
}

#pragma mark - Public Factory Methods

+ (instancetype)successExtApiModel {
    NSLog(@"[NavigateToNativePageResponseModel] 创建成功响应模型 (无数据)");
    return [self successExtApiModelWithData:nil];
}

+ (instancetype)successExtApiModelWithData:(nullable id)data {
    NSLog(@"[NavigateToNativePageResponseModel] 创建成功响应模型，数据: %@", data);
    return [[self alloc] initWithStatus:ThingMiniAppExtApiModelStatusSuccess
                              errorCode:nil
                               errorMsg:nil
                                   data:data];
}

+ (instancetype)failureExtApiModel:(nullable NSString *)errorCode {
    NSLog(@"[NavigateToNativePageResponseModel] 创建失败响应模型，错误码: %@", errorCode);
    return [self failureExtApiModel:errorCode errorMsg:nil];
}

+ (instancetype)failureExtApiModel:(nullable NSString *)errorCode
                          errorMsg:(nullable NSString *)errorMsg {
    NSLog(@"[NavigateToNativePageResponseModel] 创建失败响应模型，错误码: %@，错误信息: %@", errorCode, errorMsg);
    return [[self alloc] initWithStatus:ThingMiniAppExtApiModelStatusFailure
                              errorCode:errorCode
                               errorMsg:errorMsg
                                   data:nil];
}

@end
