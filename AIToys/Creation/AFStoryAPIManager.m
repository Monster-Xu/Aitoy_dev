//
// AFStoryAPIManager.m
// AIToys
//
// Created by xuxuxu on 2025/10/15.
// 更新: 所有请求默认带上 familyId,集成音频上传功能
// 修复: 支持API返回的id字段和直接数组格式
//

#import "AFStoryAPIManager.h"
#import "APIManager.h"
#import "APIPortConfiguration.h"
#import "StoryBoundDoll.h"

@implementation AFStoryAPIManager

+ (instancetype)sharedManager {
    static AFStoryAPIManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFStoryAPIManager alloc] init];
    });
    return manager;
}

#pragma mark - Helper Methods

/// 获取当前家庭ID
- (NSInteger)getCurrentFamilyId {
    return [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
}

/// 添加 familyId 到参数字典
- (NSDictionary *)addFamilyIdToParameters:(NSDictionary *)parameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters ?: @{}];
    params[@"familyId"] = @([self getCurrentFamilyId]);
    return [params copy];
}

- (APIResponseModel *)parseResponseObject:(id)responseObject {
    APIResponseModel *response = [[APIResponseModel alloc] init];
    
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        response.code = [dict[@"code"] integerValue];
        response.message = dict[@"msg"] ?: dict[@"message"] ?: @"";
        response.data = dict[@"data"];
        response.timestamp = [dict[@"timestamp"] longLongValue];
        response.requestId = dict[@"requestId"] ?: @"";
    } else {
        response.code = -1;
        response.message = @"响应格式错误";
    }
    
    return response;
}

/// 解析绑定公仔数组
- (NSArray<StoryBoundDoll *> *)parseBoundDollsFromArray:(NSArray *)dollsArray {
    if (![dollsArray isKindOfClass:[NSArray class]]) {
        return @[];
    }
    
    NSMutableArray<StoryBoundDoll *> *dolls = [NSMutableArray array];
    for (NSDictionary *dollDict in dollsArray) {
        if ([dollDict isKindOfClass:[NSDictionary class]]) {
            StoryBoundDoll *doll = [[StoryBoundDoll alloc] init];
            doll.dollId = [dollDict[@"dollId"] integerValue];
            doll.dollModelId = dollDict[@"dollModelId"];
            doll.customName = dollDict[@"customName"];
            doll.dollModelType = dollDict[@"dollModelType"];
            doll.bindTime = dollDict[@"bindTime"];
            doll.sortOrder = [dollDict[@"sortOrder"] integerValue];
            [dolls addObject:doll];
        }
    }
    return [dolls copy];
}

- (VoiceStoryModel *)parseStoryFromDict:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return [[VoiceStoryModel alloc] init];
    }
    
    VoiceStoryModel *story = [[VoiceStoryModel alloc] init];
    
    // ⭐ API文档使用 "id"，内部模型使用 "storyId"
    // 优先使用 storyId，如果不存在则使用 id
    if (dict[@"storyId"]) {
        story.storyId = [dict[@"storyId"] integerValue];
    } else if (dict[@"id"]) {
        story.storyId = [dict[@"id"] integerValue];
    }
    
    story.storyName = dict[@"storyName"] ?: @"";
    story.storyContent = dict[@"storyContent"];
    story.storySummary = dict[@"storySummary"];
    story.storyType = [dict[@"storyType"] integerValue];
    story.storyTypeDesc = dict[@"storyTypeDesc"];
    story.protagonistName = dict[@"protagonistName"];
    story.storyLength = [dict[@"storyLength"] integerValue];
    story.illustrationUrl = dict[@"illustrationUrl"];
    story.voiceId = [dict[@"voiceId"] integerValue];
    story.voiceName = dict[@"voiceName"];
    story.audioUrl = dict[@"audioUrl"];
    story.storyStatus = [dict[@"storyStatus"] integerValue];
    story.statusDesc = dict[@"statusDesc"];
    story.errorMsg = dict[@"errorMsg"];
    
    // ⭐ 解析 boundDolls 数组（新版本）
    NSArray *boundDollsArray = dict[@"boundDolls"];
    if (boundDollsArray) {
        story.boundDolls = [self parseBoundDollsFromArray:boundDollsArray];
    }
    
    // 保持对旧版本 dollId 的兼容（文档中标记为已废弃）
    story.dollId = [dict[@"dollId"] integerValue];
    story.dollName = dict[@"dollName"];
    
    story.createTime = dict[@"createTime"];
    story.updateTime = dict[@"updateTime"];
    
    return story;
}

- (VoiceModel *)parseVoiceFromDict:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return [[VoiceModel alloc] init];
    }
    
    VoiceModel *voice = [[VoiceModel alloc] init];
    
    // ⭐⭐ 修复：支持 "voiceId" 和 "id" 两种字段名
    // 优先使用 voiceId，如果不存在则使用 id
    if (dict[@"voiceId"]) {
        voice.voiceId = [dict[@"voiceId"] integerValue];
    } else if (dict[@"id"]) {
        voice.voiceId = [dict[@"id"] integerValue];
    }
    
    voice.voiceName = dict[@"voiceName"] ?: @"";
    voice.avatarUrl = dict[@"avatarUrl"];
    voice.cloneStatus = [dict[@"cloneStatus"] integerValue];
    voice.statusDesc = dict[@"statusDesc"];
    voice.errorMsg = dict[@"errorMsg"];
    voice.sampleAudioUrl = dict[@"sampleAudioUrl"];
    voice.sampleText = dict[@"sampleText"];
    voice.bindStoryCount = [dict[@"bindStoryCount"] integerValue];
    voice.createTime = dict[@"createTime"];
    voice.updateTime = dict[@"updateTime"];
    
    return voice;
}

#pragma mark - 故事相关接口

- (void)createStory:(CreateStoryRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = [request toDictionary];
    
    [[APIManager shared] POSTJSON:[APIPortConfiguration getCreateStoryUrl]
                        parameter:parameters
                          success:^(id result, id data, NSString *msg) {
        APIResponseModel *response = [self parseResponseObject:result];
        if (success) success(response);
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)getStoriesWithPage:(PageRequestModel *)page
                   success:(void(^)(StoryListResponseModel *response))success
                   failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = [page toQueryParameters];
    
    [[APIManager shared] GET:[APIPortConfiguration getStoriesListUrl]
                   parameter:parameters
                     success:^(id result, id data, NSString *msg) {
        APIResponseModel *apiResponse = [self parseResponseObject:result];
        if (apiResponse.isSuccess) {
            StoryListResponseModel *storyResponse = [[StoryListResponseModel alloc] init];
            
            if ([apiResponse.data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = apiResponse.data;
                storyResponse.total = [data[@"total"] integerValue];
                
                NSArray *list = data[@"list"];
                NSMutableArray<VoiceStoryModel *> *stories = [NSMutableArray array];
                for (NSDictionary *item in list) {
                    VoiceStoryModel *story = [self parseStoryFromDict:item];
                    [stories addObject:story];
                }
                storyResponse.list = stories;
            }
            
            if (success) success(storyResponse);
        } else {
            NSError *error = [NSError errorWithDomain:@"APIError"
                                                 code:apiResponse.code
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)getStoryDetailWithId:(NSInteger)storyId
                     success:(void(^)(VoiceStoryModel *story))success
                     failure:(StoryAPIFailureBlock)failure {
    
    // ⭐ 自动添加 familyId
    NSDictionary *parameters = [self addFamilyIdToParameters:@{@"storyId": @(storyId)}];
    
    [[APIManager shared] GET:[APIPortConfiguration getStoryDetailUrl]
                   parameter:parameters
                     success:^(id result, id data, NSString *msg) {
        APIResponseModel *apiResponse = [self parseResponseObject:result];
        if (apiResponse.isSuccess) {
            VoiceStoryModel *story = [self parseStoryFromDict:apiResponse.data];
            if (success) success(story);
        } else {
            NSError *error = [NSError errorWithDomain:@"APIError"
                                                 code:apiResponse.code
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)updateStory:(UpdateStoryRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = [request toDictionary];
    
    [[APIManager shared] POSTJSON:[APIPortConfiguration getUpdateStoryUrl]
                        parameter:parameters
                          success:^(id result, id data, NSString *msg) {
        APIResponseModel *response = [self parseResponseObject:result];
        if (success) success(response);
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)deleteStoryWithId:(NSInteger)storyId
                  success:(void(^)(APIResponseModel *response))success
                  failure:(StoryAPIFailureBlock)failure {
    
    // ⭐ 自动添加 familyId
    NSDictionary *parameters = [self addFamilyIdToParameters:@{@"storyId": @(storyId)}];
    
    [[APIManager shared] POSTJSON:[APIPortConfiguration getDeleteStoryUrl]
                        parameter:parameters
                          success:^(id result, id data, NSString *msg) {
        APIResponseModel *response = [self parseResponseObject:result];
        if (success) success(response);
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}
-(void)synthesizeStoryAudioWithParams:(NSDictionary *)params success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
    
    
    [[APIManager shared] POSTJSON:[APIPortConfiguration getSynthesizeStoryUrl]
                        parameter:params
                          success:^(id result, id data, NSString *msg) {
        APIResponseModel *response = [self parseResponseObject:result];
        if (success) success(response);
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
    
}


#pragma mark - 声音相关接口

- (void)createVoice:(CreateVoiceRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = [request toDictionary];
    
    [[APIManager shared] POSTJSON:[APIPortConfiguration getCreateVoiceUrl]
                        parameter:parameters
                          success:^(id result, id data, NSString *msg) {
        APIResponseModel *response = [self parseResponseObject:result];
        if (success) success(response);
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)getVoicesWithStatus:(NSInteger)status
                    success:(void(^)(VoiceListResponseModel *response))success
                    failure:(StoryAPIFailureBlock)failure {
    
    // ⭐ 构造参数时自动添加 familyId
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"familyId"] = @([self getCurrentFamilyId]);
    if (status > 0) {
        params[@"cloneStatus"] = @(status);
    }
    NSDictionary *parameters = [params copy];
    
    [[APIManager shared] GET:[APIPortConfiguration getVoicesListUrl]
                   parameter:parameters
                     success:^(id result, id data, NSString *msg) {
        APIResponseModel *apiResponse = [self parseResponseObject:result];
        if (apiResponse.isSuccess) {
            VoiceListResponseModel *voiceResponse = [[VoiceListResponseModel alloc] init];
            
            // ⭐⭐ 修复：支持两种数据格式
            // 格式1: data 是字典 {total: ..., list: [...]}
            // 格式2: data 直接是数组 [...]
            
            if ([apiResponse.data isKindOfClass:[NSDictionary class]]) {
                // 格式1: 包含 total 和 list 的字典
                NSDictionary *data = apiResponse.data;
                voiceResponse.total = [data[@"total"] integerValue];
                
                NSArray *list = data[@"list"];
                NSMutableArray<VoiceModel *> *voices = [NSMutableArray array];
                for (NSDictionary *item in list) {
                    VoiceModel *voice = [self parseVoiceFromDict:item];
                    [voices addObject:voice];
                }
                voiceResponse.list = voices;
                
            } else if ([apiResponse.data isKindOfClass:[NSArray class]]) {
                // 格式2: data 直接是数组
                NSArray *list = apiResponse.data;
                voiceResponse.total = list.count;
                
                NSMutableArray<VoiceModel *> *voices = [NSMutableArray array];
                for (NSDictionary *item in list) {
                    if ([item isKindOfClass:[NSDictionary class]]) {
                        VoiceModel *voice = [self parseVoiceFromDict:item];
                        [voices addObject:voice];
                    }
                }
                voiceResponse.list = voices;
            }
            
            NSLog(@"[AFStoryAPIManager] 解析声音列表成功，共 %ld 条数据", (long)voiceResponse.list.count);
            
            if (success) success(voiceResponse);
        } else {
            NSError *error = [NSError errorWithDomain:@"APIError"
                                                 code:apiResponse.code
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)getVoiceDetailWithId:(NSInteger)voiceId
                     success:(void(^)(VoiceModel *voice))success
                     failure:(StoryAPIFailureBlock)failure {
    
    // ⭐ 自动添加 familyId
    NSDictionary *parameters = [self addFamilyIdToParameters:@{@"voiceId": @(voiceId)}];
    
    [[APIManager shared] GET:[APIPortConfiguration getVoiceDetailUrl]
                   parameter:parameters
                     success:^(id result, id data, NSString *msg) {
        APIResponseModel *apiResponse = [self parseResponseObject:result];
        if (apiResponse.isSuccess) {
            VoiceModel *voice = [self parseVoiceFromDict:apiResponse.data];
            if (success) success(voice);
        } else {
            NSError *error = [NSError errorWithDomain:@"APIError"
                                                 code:apiResponse.code
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)updateVoice:(UpdateVoiceRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = [request toDictionary];
    
    [[APIManager shared] POSTJSON:[APIPortConfiguration getUpdateVoiceUrl]
                        parameter:parameters
                          success:^(id result, id data, NSString *msg) {
        APIResponseModel *response = [self parseResponseObject:result];
        if (success) success(response);
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)deleteVoiceWithId:(NSInteger)voiceId
                  success:(void(^)(APIResponseModel *response))success
                  failure:(StoryAPIFailureBlock)failure {
    
    // ⭐ 自动添加 familyId
    NSDictionary *parameters = [self addFamilyIdToParameters:@{@"voiceId": @(voiceId)}];
    
    [[APIManager shared] POSTJSON:[APIPortConfiguration getDeleteVoiceUrl]
                        parameter:parameters
                          success:^(id result, id data, NSString *msg) {
        APIResponseModel *response = [self parseResponseObject:result];
        if (success) success(response);
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

#pragma mark - 音频上传接口 ⭐

- (void)uploadAudioData:(NSData *)audioData
               fileName:(NSString *)fileName
             voiceName:(NSString *_Nullable)voiceName
               progress:(AudioUploadProgressBlock _Nullable)progress
                success:(AudioUploadSuccessBlock)success
                failure:(AudioUploadFailureBlock)failure {
    
    // 参数验证
    if (!audioData || audioData.length == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"AudioUploadError"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey: @"音频数据为空"}];
            failure(error);
        }
        return;
    }
    
    // 检查文件大小（建议不超过 50MB）
    NSInteger maxSize = 50 * 1024 * 1024; // 50MB
    if (audioData.length > maxSize) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"AudioUploadError"
                                                 code:-2
                                             userInfo:@{NSLocalizedDescriptionKey: @"音频文件大小不能超过50MB"}];
            failure(error);
        }
        return;
    }
    
    // 构建上传 URL（包含查询参数 name）
    NSString *baseUrl = [APIPortConfiguration getUploadAudioUrl];
    NSString *uploadUrl = baseUrl;
    
    // 如果提供了 voiceName，添加为查询参数
    if (voiceName && voiceName.length > 0) {
//        uploadUrl = [baseUrl stringByAppendingFormat:@"?name=%@",
//                     [voiceName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        uploadUrl = [baseUrl stringByAppendingFormat:@"?name"];
       //                     [voiceName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    }
    
    NSLog(@"开始上传音频 - URL: %@, 文件大小: %.2f MB", uploadUrl, audioData.length / (1024.0 * 1024.0));
    
    // 获取 AFHTTPSessionManager
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    
    // 配置请求头
    if (kMyUser.accessToken && kMyUser.accessToken.length > 0) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", kMyUser.accessToken]
                         forHTTPHeaderField:@"Authorization"];
    }
    
    // 设置超时时间为 60 秒（上传可能较慢）
    manager.requestSerializer.timeoutInterval = 60.0;
    
    // 配置响应序列化
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                @"application/json",
                                                @"text/json",
                                                @"text/plain",
                                                nil];
    manager.responseSerializer = responseSerializer;
    
    // 证书验证设置（根据需要调整）
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    [manager setSecurityPolicy:securityPolicy];
    
    // 执行上传
    NSURLSessionDataTask *uploadTask = [manager POST:uploadUrl
                                           parameters:nil
                                              headers:@{}
                                constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        // 生成文件名（如果未提供）
        NSString *finalFileName = fileName;
        if (!finalFileName || finalFileName.length == 0) {
            finalFileName = [self generateAudioFileName];
        }
        
        NSLog(@"添加文件到表单 - 字段名: file, 文件名: %@", finalFileName);
        
        // 添加音频文件到 multipart form data
        // 根据文件扩展名判断 MIME 类型
        NSString *mimeType = [self getMimeTypeForFileName:finalFileName];
        
        [formData appendPartWithFileData:audioData
                                    name:@"file"
                                fileName:finalFileName
                                mimeType:mimeType];
        
    } progress:^(NSProgress *uploadProgress) {
        // 上传进度回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) {
                progress(uploadProgress);
                NSLog(@"上传进度: %.2f%%", uploadProgress.fractionCompleted * 100);
            }
        });
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"音频上传成功 - 响应: %@", responseObject);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 解析响应
            NSDictionary *dataDic = [self parseAudioUploadResponse:responseObject];
            
            if (dataDic) {
                if (success) {
                    success(dataDic);  // ⭐ 返回完整的data字典
                }
            } else {
                NSError *error = [NSError errorWithDomain:@"AudioUploadError"
                                                     code:-3
                                                 userInfo:@{NSLocalizedDescriptionKey: @"无法解析上传结果"}];
                if (failure) {
                    failure(error);
                }
            }
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"音频上传失败 - 错误: %@", error.localizedDescription);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                NSError *uploadError = [NSError errorWithDomain:@"AudioUploadError"
                                                            code:error.code
                                                        userInfo:@{NSLocalizedDescriptionKey: error.localizedDescription ?: @"上传失败"}];
                failure(uploadError);
            }
        });
    }];
}

- (void)uploadAudioFile:(NSString *)audioFilePath
             voiceName:(NSString *_Nullable)voiceName
               progress:(AudioUploadProgressBlock _Nullable)progress
                success:(AudioUploadSuccessBlock)success
                failure:(AudioUploadFailureBlock)failure {
    
    // 参数验证
    if (!audioFilePath || audioFilePath.length == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"AudioUploadError"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey: @"文件路径为空"}];
            failure(error);
        }
        return;
    }
    
    // 检查文件是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:audioFilePath]) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"AudioUploadError"
                                                 code:-2
                                             userInfo:@{NSLocalizedDescriptionKey: @"文件不存在"}];
            failure(error);
        }
        return;
    }
    
    // 读取文件数据
    NSError *readError = nil;
    NSData *audioData = [NSData dataWithContentsOfFile:audioFilePath
                                               options:NSDataReadingMappedIfSafe
                                                 error:&readError];
    
    if (!audioData || readError) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"AudioUploadError"
                                                 code:-3
                                             userInfo:@{NSLocalizedDescriptionKey: @"无法读取文件"}];
            failure(error);
        }
        return;
    }
    
    // 获取文件名
    NSString *fileName = [audioFilePath lastPathComponent];
    
    // 调用数据上传方法
    [self uploadAudioData:audioData
                fileName:fileName
              voiceName:voiceName
                progress:progress
                 success:success
                 failure:failure];
}

#pragma mark - 音频上传辅助方法

/// 生成音频文件名（时间戳格式）
- (NSString *)generateAudioFileName {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%@.mp3", timestamp];
}

/// 根据文件扩展名获取 MIME 类型
- (NSString *)getMimeTypeForFileName:(NSString *)fileName {
    NSString *extension = [fileName pathExtension].lowercaseString;
    
    NSDictionary *mimeTypes = @{
        @"mp3": @"audio/mpeg",
        @"wav": @"audio/wav",
        @"ogg": @"audio/ogg",
        @"flac": @"audio/flac",
        @"m4a": @"audio/mp4",
        @"aac": @"audio/aac",
        @"aiff": @"audio/aiff",
        @"wma": @"audio/x-ms-wma"
    };
    
    return mimeTypes[extension] ?: @"audio/mpeg"; // 默认为 MP3
}

/// 解析上传响应获取文件 URL
/// ⭐ 修改：返回完整的data字典，包含 audioFileUrl 和 fileId
- (NSDictionary *)parseAudioUploadResponse:(id)responseObject {
    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSDictionary *response = (NSDictionary *)responseObject;
    
    // 检查响应格式: { code: 0, data: { audioFileUrl: "...", fileId: 123 }, msg: "..." }
    if ([response[@"code"] integerValue] == 0) {
        id data = response[@"data"];
        if ([data isKindOfClass:[NSDictionary class]]) {
            return data;  // ⭐ 直接返回data字典，包含 audioFileUrl 和 fileId
        }
    }
    
    return nil;
}

#pragma mark - 通用资源接口

- (void)getIllustrationsSuccess:(void(^)(IllustrationListResponseModel *response))success
                       failure:(StoryAPIFailureBlock)failure {
    
    // ⭐ 通用资源接口也添加 familyId
    NSDictionary *parameters = @{@"familyId": @([self getCurrentFamilyId])};
    
    [[APIManager shared] GET:[APIPortConfiguration getIllustrationsUrl]
                   parameter:parameters
                     success:^(id result, id data, NSString *msg) {
        APIResponseModel *apiResponse = [self parseResponseObject:result];
        if (apiResponse.isSuccess) {
            IllustrationListResponseModel *illustrationResponse = [[IllustrationListResponseModel alloc] init];
            
            if ([apiResponse.data isKindOfClass:[NSArray class]]) {
                NSArray *list = apiResponse.data;
                NSMutableArray<IllustrationModel *> *illustrations = [NSMutableArray array];
                for (NSDictionary *item in list) {
                    IllustrationModel *illustration = [[IllustrationModel alloc] init];
                    illustration.avatarName = item[@"avatarName"] ?: @"";
                    illustration.avatarUrl = item[@"avatarUrl"] ?: @"";
                    [illustrations addObject:illustration];
                }
                illustrationResponse.list = illustrations;
                illustrationResponse.total = illustrations.count;
            }
            
            if (success) success(illustrationResponse);
        } else {
            NSError *error = [NSError errorWithDomain:@"APIError"
                                                 code:apiResponse.code
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)getOfficialVoicesSuccess:(void(^)(VoiceListResponseModel *response))success
                        failure:(StoryAPIFailureBlock)failure {
    
    // ⭐ 通用资源接口也添加 familyId
    NSDictionary *parameters = @{@"familyId": @([self getCurrentFamilyId])};
    
    [[APIManager shared] GET:[APIPortConfiguration getOfficialVoicesUrl]
                   parameter:parameters
                     success:^(id result, id data, NSString *msg) {
        APIResponseModel *apiResponse = [self parseResponseObject:result];
        if (apiResponse.isSuccess) {
            VoiceListResponseModel *voiceResponse = [[VoiceListResponseModel alloc] init];
            
            if ([apiResponse.data isKindOfClass:[NSArray class]]) {
                NSArray *list = apiResponse.data;
                NSMutableArray<VoiceModel *> *voices = [NSMutableArray array];
                for (NSDictionary *item in list) {
                    VoiceModel *voice = [self parseVoiceFromDict:item];
                    [voices addObject:voice];
                }
                voiceResponse.list = voices;
                voiceResponse.total = voices.count;
            }
            
            if (success) success(voiceResponse);
        } else {
            NSError *error = [NSError errorWithDomain:@"APIError"
                                                 code:apiResponse.code
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

@end
