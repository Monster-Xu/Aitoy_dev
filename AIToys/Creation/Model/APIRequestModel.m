//
//  APIRequestModel.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//  Updated by xuxuxu on 2025/10/15.
//  更新：修改分页参数映射 pageNum -> pageNo
//

#import "APIRequestModel.h"

@implementation CreateStoryRequestModel

- (instancetype)init {
    if (self = [super init]) {
        _storyType = StoryTypeFairyTale;
        _storyLength = 180;
        // ⭐ 自动获取当前 familyId
        _familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
                     summary:(NSString *)summary
                        type:(StoryType)type
              protagonistName:(NSString *)protagonistName
                      length:(NSInteger)length
              illustrationUrl:(NSString *)illustrationUrl {
    if (self = [super init]) {
        _storyName = [name copy];
        _storySummary = [summary copy];
        _storyType = type;
        _protagonistName = [protagonistName copy];
        _storyLength = length;
        _illustrationUrl = [illustrationUrl copy];
        // ⭐ 自动获取当前 familyId
        _familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    }
    return self;
}

- (BOOL)isValid {
    return [self validationError] == nil;
}

- (NSString *)validationError {
    if (self.familyId <= 0) {
        return @"familyId 不能为空";
    }
    
    if (self.storyName.length == 0 || self.storyName.length > 120) {
        return @"故事名称长度必须在1-120字符之间";
    }
    
    if (self.storySummary.length == 0 || self.storySummary.length > 2400) {
        return @"故事概述长度必须在1-2400字符之间";
    }
    
    if (self.protagonistName.length == 0 || self.protagonistName.length > 30) {
        return @"主角姓名长度必须在1-30字符之间";
    }
    
    NSArray *validLengths = @[@90, @180, @270, @360];
    if (!(self.storyLength>0)) {
        return @"请选择故事时长";
    }
    
//    if (self.illustrationUrl.length == 0) {
//        return @"插画URL不能为空";
//    }
    
    return nil;
}

- (NSDictionary *)toDictionary {
    return @{
        @"familyId": @(self.familyId),
        @"storyName": self.storyName ?: @"",
        @"storySummary": self.storySummary ?: @"",
        @"storyType": @(self.storyType),
        @"protagonistName": self.protagonistName ?: @"",
        @"storyLength": @(self.storyLength),
        @"illustrationUrl": self.illustrationUrl ?: @""
    };
}

@end

@implementation UpdateStoryRequestModel

- (instancetype)initWithStoryId:(NSInteger)storyId {
    if (self = [super init]) {
        _storyId = storyId;
        // ⭐ 自动获取当前 familyId
        _familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    }
    return self;
}

- (instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super init]) {
        _familyId = [params[@"familyId"] integerValue];
        _storyId = [params[@"storyId"] integerValue];
        _storyName = params[@"storyName"];
        _storyContent = params[@"storyContent"];
        _illustrationUrl = params[@"illustrationUrl"];
        _voiceId = [params[@"voiceId"] integerValue];
    }
    return self;
}

- (BOOL)hasChanges {
    return self.storyName != nil ||
           self.storyContent != nil ||
           self.illustrationUrl != nil ||
           self.voiceId > 0;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[@"familyId"] = @(self.familyId);
    dict[@"storyId"] = @(self.storyId);
    
    if (self.storyName) {
        dict[@"storyName"] = self.storyName;
    }
    if (self.storyContent) {
        dict[@"storyContent"] = self.storyContent;
    }
    if (self.illustrationUrl) {
        dict[@"illustrationUrl"] = self.illustrationUrl;
    }
    if (self.voiceId > 0) {
        dict[@"voiceId"] = @(self.voiceId);
    }
    
    return [dict copy];
}

@end

#pragma mark - UpdateFailedStoryRequestModel

@implementation UpdateFailedStoryRequestModel

- (instancetype)initWithStoryId:(NSInteger)storyId
                       familyId:(NSInteger)familyId
                      storyName:(NSString *)storyName
                   storySummary:(NSString *)storySummary
                      storyType:(StoryType)storyType
                 protagonistName:(NSString *)protagonistName
                    storyLength:(NSInteger)storyLength {
    if (self = [super init]) {
        _storyId = storyId;
        _familyId = familyId;
        _storyName = [storyName copy];
        _storySummary = [storySummary copy];
        _storyType = storyType;
        _protagonistName = [protagonistName copy];
        _storyLength = storyLength;
    }
    return self;
}

- (BOOL)isValid {
    return [self validationError] == nil;
}

- (NSString *)validationError {
    if (self.storyId <= 0) {
        return @"故事ID不能为空";
    }
    
    if (self.familyId <= 0) {
        return @"家庭ID不能为空";
    }
    
    if (self.storyName.length == 0 || self.storyName.length > 120) {
        return @"故事名称长度必须在1-120字符之间";
    }
    
    if (self.storySummary.length == 0 || self.storySummary.length > 2400) {
        return @"故事摘要长度必须在1-2400字符之间";
    }
    
    if (self.storyType < 1 || self.storyType > 7) {
        return @"故事类型必须在1-7之间";
    }
    
    if (self.protagonistName.length == 0 || self.protagonistName.length > 30) {
        return @"主角名称长度必须在1-30字符之间";
    }
    
    if (self.storyLength <= 0) {
        return @"故事长度必须大于0";
    }
    
    return nil;
}

- (NSDictionary *)toDictionary {
    return @{
        @"storyId": @(self.storyId),
        @"familyId": @(self.familyId),
        @"storyName": self.storyName ?: @"",
        @"storySummary": self.storySummary ?: @"",
        @"storyType": @(self.storyType),
        @"protagonistName": self.protagonistName ?: @"",
        @"storyLength": @(self.storyLength)
    };
}

@end

@implementation CreateVoiceRequestModel

- (instancetype)init {
    if (self = [super init]) {
        // ⭐ 自动获取当前 familyId
        _familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
                   avatarUrl:(NSString *)avatarUrl
                audioFileUrl:(NSString *)audioFileUrl fileId:(NSInteger)fileId{
    if (self = [super init]) {
        _voiceName = [name copy];
        _avatarUrl = [avatarUrl copy];
        _audioFileUrl = [audioFileUrl copy];
        _fileId = fileId;
        // ⭐ 自动获取当前 familyId
        _familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    }
    return self;
}

- (BOOL)isValid {
    return [self validationError] == nil;
}

- (NSString *)validationError {
    if (self.familyId <= 0) {
        return @"familyId 不能为空";
    }
    
    if (self.voiceName.length == 0 || self.voiceName.length > 30) {
        return @"声音名称长度必须在1-30字符之间";
    }
    
    if (self.avatarUrl.length == 0) {
        return @"头像URL不能为空";
    }
    
    if (self.audioFileUrl.length == 0) {
        return @"录音文件URL不能为空";
    }
    
    return nil;
}

- (NSDictionary *)toDictionary {
    return @{
        @"familyId": @(self.familyId),
        @"voiceName": self.voiceName ?: @"",
        @"avatarUrl": self.avatarUrl ?: @"",
        @"audioFileUrl": self.audioFileUrl ?: @"",
        @"fileId":@(self.fileId)
    };
}

@end

@implementation UpdateVoiceRequestModel

- (instancetype)initWithVoiceId:(NSInteger)voiceId {
    if (self = [super init]) {
        _voiceId = voiceId;
        // ⭐ 自动获取当前 familyId
        _familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    }
    return self;
}

- (BOOL)hasChanges {
    return self.voiceName != nil ||
           self.avatarUrl != nil ||
           self.audioFileUrl != nil;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[@"familyId"] = @(self.familyId);
    dict[@"voiceId"] = @(self.voiceId);
    
    if (self.voiceName) {
        dict[@"voiceName"] = self.voiceName;
    }
    if (self.avatarUrl) {
        dict[@"avatarUrl"] = self.avatarUrl;
    }
    if (self.audioFileUrl) {
        dict[@"audioFileUrl"] = self.audioFileUrl;
    }
    
    return [dict copy];
}

@end

@implementation SynthesizeStoryRequestModel

- (instancetype)initWithStoryId:(NSInteger)storyId voiceId:(NSInteger)voiceId {
    if (self = [super init]) {
        _storyId = storyId;
        _voiceId = voiceId;
        // ⭐ 自动获取当前 familyId
        _familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    }
    return self;
}

- (BOOL)isValid {
    return self.familyId > 0 && self.storyId > 0 && self.voiceId > 0;
}

- (NSDictionary *)toDictionary {
    return @{
        @"familyId": @(self.familyId),
        @"storyId": @(self.storyId),
        @"voiceId": @(self.voiceId)
    };
}

@end

@implementation DeleteRequestModel

- (instancetype)initWithResourceId:(NSInteger)resourceId {
    if (self = [super init]) {
        _resourceId = resourceId;
        // ⭐ 自动获取当前 familyId
        _familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    return @{
        @"familyId": @(self.familyId),
        @"storyId": @(self.resourceId)
    };
}

@end

@implementation PageRequestModel

- (instancetype)init {
    if (self = [super init]) {
        _pageNum = 1;
        _pageSize = 20;
        _familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    }
    return self;
}

- (instancetype)initWithPageNum:(NSInteger)pageNum pageSize:(NSInteger)pageSize {
    if (self = [super init]) {
        _pageNum = pageNum;
        _pageSize = pageSize;
        // ⭐ 自动获取当前 familyId
        _familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    }
    return self;
}

- (NSDictionary *)toQueryParameters {
    // ⭐ 注意：这里将 pageNum 映射为 pageNo 以匹配API文档
    return @{
        @"pageNo": @(self.pageNum),      // pageNum -> pageNo 映射
        @"pageSize": @(self.pageSize),
        @"familyId": @(self.familyId)
    };
}

@end
