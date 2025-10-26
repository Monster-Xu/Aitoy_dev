//
//  APIManager.h
//  KunQiTong
//
//  Created by 乔不赖 on 2021/8/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define PageSize 20
#define PicPATH [NSString stringWithFormat:@"%@", PATH]

typedef NS_ENUM(NSInteger, NetStatus) {
    NetStatus_Unknown  = -1,
    NetStatus_NoNet    =  0,
    NetStatus_WWAN     =  1,
    NetStatus_WiFi     =  2,
};

typedef void(^failBlock)(NSString *msg);

@interface APIManager : NSObject

@property (nonatomic, assign) NetStatus netStatus;

//构造单例
+ (instancetype)shared;

//开始监听网络状态
- (void)startNetStatusNotify;

//取消所有网络请求
- (void)cancelAllTasks;

//保存用户信息
- (void)saveSelfData:(NSDictionary *)dic;


#pragma mark -- 上传图片
- (void)uploadImg:(UIImage *)img
             isH5:(BOOL)isH5
             Succ:(void(^)(NSString *data))succ
             fail:(failBlock)fail;

#pragma mark -- 获取当前VC
- (UIViewController *)getCurrentViewController;

#pragma mark -- GET请求
- (void)GET:(NSString *)urlStr
   parameter:(NSDictionary *_Nullable)parameter
     success:(void(^)(id result, id data, NSString *msg))success
    failure:(void(^)(NSError *error, NSString *msg))failure;

- (void)GETTxt:(NSString *)urlStr
   parameter:(NSDictionary *)parameter
     success:(void(^)(id result, id data, NSString *msg))success
       failure:(void(^)(NSError *error, NSString *msg))failure;

#pragma mark -- Post请求
- (void)POST:(NSString *)urlStr
   parameter:(NSDictionary *_Nullable)parameter
     success:(void(^)(id result, id data, NSString *msg))success
     failure:(void(^)(NSError *error, NSString *msg))failure;

- (void)POSTJSON:(NSString *)urlStr
   parameter:(NSDictionary *_Nullable)parameter
     success:(void(^)(id result, id data, NSString *msg))success
         failure:(void(^)(NSError *error, NSString *msg))failure;

#pragma mark -- PUT请求
- (void)PUT:(NSString *)urlStr
   parameter:(NSDictionary *_Nullable)parameter
     success:(void(^)(id result, id data, NSString *msg))success
        failure:(void(^)(NSError *error, NSString *msg))failure;

- (void)PUTJSON:(NSString *)urlStr
   parameter:(NSDictionary *_Nullable)parameter
     success:(void(^)(id result, id data, NSString *msg))success
        failure:(void(^)(NSError *error, NSString *msg))failure;

#pragma mark -- delete请求
- (void)DELETE:(NSString *)urlStr
  parameter:(NSDictionary *_Nullable)parameter
    success:(void(^)(id result, id data, NSString *msg))success
       failure:(void(^)(NSError *error, NSString *msg))failure;
@end

NS_ASSUME_NONNULL_END
