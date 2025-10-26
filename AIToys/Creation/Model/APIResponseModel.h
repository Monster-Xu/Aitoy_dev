//
//  APIResponseModel.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//

#import <Foundation/Foundation.h>

@class VoiceStoryModel;
@class VoiceModel;

NS_ASSUME_NONNULL_BEGIN

// 通用API响应模型
@interface APIResponseModel : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong, nullable) id data;
@property (nonatomic, assign) long long timestamp;
@property (nonatomic, copy) NSString *requestId;

// 便利方法
- (BOOL)isSuccess;
- (NSString *)errorMessage;

@end

// 分页响应数据模型
@interface PageResponseModel : NSObject

@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSArray *list;

@end

// 故事列表响应模型
@interface StoryListResponseModel : PageResponseModel
@property (nonatomic, strong) NSArray<VoiceStoryModel *> *list;
@end

// 声音列表响应模型
@interface VoiceListResponseModel : PageResponseModel
@property (nonatomic, strong) NSArray<VoiceModel *> *list;
@end

// 插画模型
@interface IllustrationModel : NSObject
@property (nonatomic, copy) NSString *avatarName;
@property (nonatomic, copy) NSString *avatarUrl;
@end

// 插画列表响应模型
@interface IllustrationListResponseModel : PageResponseModel
@property (nonatomic, strong) NSArray<IllustrationModel *> *list;
@end

NS_ASSUME_NONNULL_END
