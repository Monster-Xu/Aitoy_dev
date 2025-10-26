//
//  APIRequestModel.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//  Updated: 添加 familyId 到所有请求模型
//

#import <Foundation/Foundation.h>
#import "VoiceStoryModel.h"

NS_ASSUME_NONNULL_BEGIN

// 创建故事请求模型
@interface CreateStoryRequestModel : NSObject

@property (nonatomic, assign) NSInteger familyId;  // ⭐ 新增
@property (nonatomic, copy) NSString *storyName;
@property (nonatomic, copy) NSString *storySummary;
@property (nonatomic, assign) StoryType storyType;
@property (nonatomic, copy) NSString *protagonistName;
@property (nonatomic, assign) NSInteger storyLength;
@property (nonatomic, copy) NSString *illustrationUrl;

// 便利初始化方法
- (instancetype)initWithName:(NSString *)name
                     summary:(NSString *)summary
                        type:(StoryType)type
              protagonistName:(NSString *)protagonistName
                      length:(NSInteger)length
              illustrationUrl:(NSString *)illustrationUrl;

// 验证方法
- (BOOL)isValid;
- (NSString *)validationError;

// 转换为字典
- (NSDictionary *)toDictionary;

@end

// 编辑故事请求模型
@interface UpdateStoryRequestModel : NSObject

@property (nonatomic, assign) NSInteger familyId;  // ⭐ 新增
@property (nonatomic, assign) NSInteger storyId;
@property (nonatomic, copy, nullable) NSString *storyName;
@property (nonatomic, copy, nullable) NSString *storyContent;
@property (nonatomic, copy, nullable) NSString *illustrationUrl;
@property (nonatomic, assign) NSInteger voiceId;

- (instancetype)initWithStoryId:(NSInteger)storyId;
- (instancetype)initWithParams:(NSDictionary *)params;
- (BOOL)hasChanges;
- (NSDictionary *)toDictionary;

@end

// 创建声音（克隆）请求模型
@interface CreateVoiceRequestModel : NSObject

@property (nonatomic, assign) NSInteger familyId;// ⭐ 新增
@property (nonatomic, assign) NSInteger fileId;
@property (nonatomic, copy) NSString *voiceName;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *audioFileUrl;


- (instancetype)initWithName:(NSString *)name
                   avatarUrl:(NSString *)avatarUrl
                audioFileUrl:(NSString *)audioFileUrl fileId:(NSInteger)fileId;

- (BOOL)isValid;
- (NSString *)validationError;
- (NSDictionary *)toDictionary;

@end

// 编辑声音请求模型
@interface UpdateVoiceRequestModel : NSObject

@property (nonatomic, assign) NSInteger familyId;  // ⭐ 新增
@property (nonatomic, assign) NSInteger voiceId;
@property (nonatomic, copy, nullable) NSString *voiceName;
@property (nonatomic, copy, nullable) NSString *avatarUrl;
@property (nonatomic, copy, nullable) NSString *audioFileUrl;

- (instancetype)initWithVoiceId:(NSInteger)voiceId;
- (BOOL)hasChanges;
- (NSDictionary *)toDictionary;

@end

// 故事音频合成请求模型
@interface SynthesizeStoryRequestModel : NSObject

@property (nonatomic, assign) NSInteger familyId;  // ⭐ 新增
@property (nonatomic, assign) NSInteger storyId;
@property (nonatomic, assign) NSInteger voiceId;

- (instancetype)initWithStoryId:(NSInteger)storyId voiceId:(NSInteger)voiceId;
- (BOOL)isValid;
- (NSDictionary *)toDictionary;

@end

// 删除请求模型
@interface DeleteRequestModel : NSObject

@property (nonatomic, assign) NSInteger familyId;  // ⭐ 新增
@property (nonatomic, assign) NSInteger resourceId;

- (instancetype)initWithResourceId:(NSInteger)resourceId;
- (NSDictionary *)toDictionary;

@end

// 分页请求参数
@interface PageRequestModel : NSObject

@property (nonatomic, assign) NSInteger pageNum;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger familyId;
//@property (nonatomic, assign) NSInteger storyStatus;

- (instancetype)initWithPageNum:(NSInteger)pageNum pageSize:(NSInteger)pageSize;
- (NSDictionary *)toQueryParameters;

@end

NS_ASSUME_NONNULL_END
