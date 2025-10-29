// AFStoryAPIManager.h
#import <Foundation/Foundation.h>
#import "APIRequestModel.h"
#import "APIResponseModel.h"
#import "VoiceStoryModel.h"
#import "VoiceModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^StoryAPISuccessBlock)(APIResponseModel *response);
typedef void(^StoryAPIFailureBlock)(NSError *error);

// 音频上传相关的 Block 定义
typedef void(^AudioUploadProgressBlock)(NSProgress *uploadProgress);
typedef void(^AudioUploadSuccessBlock)(NSDictionary *data);  // ⭐ 修改：返回完整的data字典（包含audioFileUrl和fileId）
typedef void(^AudioUploadFailureBlock)(NSError *error);

@interface AFStoryAPIManager : NSObject

+ (instancetype)sharedManager;

#pragma mark - 故事相关接口

// 创建故事
- (void)createStory:(CreateStoryRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure;

// 查询故事列表
- (void)getStoriesWithPage:(PageRequestModel *)page
                   success:(void(^)(StoryListResponseModel *response))success
                   failure:(StoryAPIFailureBlock)failure;

// 查询故事详情
- (void)getStoryDetailWithId:(NSInteger)storyId
                     success:(void(^)(VoiceStoryModel *story))success
                     failure:(StoryAPIFailureBlock)failure;

// 编辑故事
- (void)updateStory:(UpdateStoryRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure;

// 编辑失败的故事（重新生成）
- (void)updateFailedStory:(UpdateFailedStoryRequestModel *)request
                  success:(void(^)(APIResponseModel *response))success
                  failure:(StoryAPIFailureBlock)failure;

// 删除故事
- (void)deleteStoryWithId:(NSInteger)storyId
                  success:(void(^)(APIResponseModel *response))success
                  failure:(StoryAPIFailureBlock)failure;

// 查询故事类型枚举
- (void)getStoryTypesSuccess:(void(^)(APIResponseModel *response))success
                    failure:(StoryAPIFailureBlock)failure;

// 查询故事长度枚举
- (void)getStoryLengthsSuccess:(void(^)(APIResponseModel *response))success
                      failure:(StoryAPIFailureBlock)failure;

/**
 * 合成故事音频
 * @param params 请求参数字典，包含：
 *   - storyId: 故事ID (NSNumber)
 *   - voiceId: 音色ID (NSNumber)
 *   - storyName: 故事名称 (NSString)
 *   - storyContent: 故事内容 (NSString)
 *   - illustrationUrl: 插图URL (NSString)
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)synthesizeStoryAudioWithParams:(NSDictionary *)params
                               success:(void (^)(id response))success
                               failure:(void (^)(NSError *error))failure;

#pragma mark - 声音相关接口

// 创建声音（开始克隆）
- (void)createVoice:(CreateVoiceRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure;

// 查询声音列表
- (void)getVoicesWithStatus:(NSInteger)status
                    success:(void(^)(VoiceListResponseModel *response))success
                    failure:(StoryAPIFailureBlock)failure;

// 查询声音详情
- (void)getVoiceDetailWithId:(NSInteger)voiceId
                     success:(void(^)(VoiceModel *voice))success
                     failure:(StoryAPIFailureBlock)failure;

// 编辑声音
- (void)updateVoice:(UpdateVoiceRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure;

// 删除声音
- (void)deleteVoiceWithId:(NSInteger)voiceId
                  success:(void(^)(APIResponseModel *response))success
                  failure:(StoryAPIFailureBlock)failure;

#pragma mark - 音频上传接口 ⭐

/// 上传音频文件（用于声音克隆）
///
/// @param audioData 音频文件数据（如 MP3、WAV 等）
/// @param fileName 原始音频文件名（可选，用于参考）
/// @param voiceName 声音名称（查询参数，可选）
/// @param progress 上传进度回调
/// @param success 成功回调，返回包含 audioFileUrl 和 fileId 的字典
/// @param failure 失败回调
///
/// @discussion
/// - 音频文件大小建议不超过 50MB
/// - 支持的格式：MP3、WAV、OGG、FLAC 等
/// - 上传超时时间：60秒
/// - 自动在请求头中添加 Authorization Bearer Token
/// - 返回数据格式：@{ @"audioFileUrl": @"...", @"fileId": @(123) }
- (void)uploadAudioData:(NSData *)audioData
               fileName:(NSString *)fileName
             voiceName:(NSString *_Nullable)voiceName
               progress:(AudioUploadProgressBlock _Nullable)progress
                success:(AudioUploadSuccessBlock)success
                failure:(AudioUploadFailureBlock)failure;

/// 上传音频文件（指定URL路径）
///
/// @param audioFilePath 本地音频文件路径
/// @param voiceName 声音名称（查询参数，可选）
/// @param progress 上传进度回调
/// @param success 成功回调，返回包含 audioFileUrl 和 fileId 的字典
/// @param failure 失败回调
///
/// @discussion
/// - 便利方法，自动读取本地文件并调用 uploadAudioData:fileName:voiceName:progress:success:failure:
/// - 返回数据格式：@{ @"audioFileUrl": @"...", @"fileId": @(123) }
- (void)uploadAudioFile:(NSString *)audioFilePath
             voiceName:(NSString *_Nullable)voiceName
               progress:(AudioUploadProgressBlock _Nullable)progress
                success:(AudioUploadSuccessBlock)success
                failure:(AudioUploadFailureBlock)failure;

#pragma mark - 通用资源接口

// 获取官方插画列表
- (void)getIllustrationsSuccess:(void(^)(IllustrationListResponseModel *response))success
                       failure:(StoryAPIFailureBlock)failure;

// 获取官方音色列表
- (void)getOfficialVoicesSuccess:(void(^)(VoiceListResponseModel *response))success
                        failure:(StoryAPIFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
