//
//  APIResponseModel.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//

#import "APIResponseModel.h"
#import "VoiceStoryModel.h"
#import "VoiceModel.h"

@implementation APIResponseModel

- (BOOL)isSuccess {
    return self.code == 0;
}

- (NSString *)errorMessage {
    if (self.isSuccess) {
        return nil;
    }
    
    switch (self.code) {
        case 10001:
            return @"故事数量已达上限";
        case 10002:
            return @"声音数量已达上限";
        case 10003:
            return @"故事名称重复";
        case 10004:
            return @"故事不存在";
        case 10005:
            return @"声音不存在";
        case 10006:
            return @"声音已绑定故事，无法删除";
        case 10007:
            return @"录音时长不足30秒";
        case 10008:
            return @"故事生成失败";
        case 10009:
            return @"声音克隆失败";
        case 10010:
            return @"音频合成失败";
        case 10011:
            return @"故事已关联公仔";
        case 10012:
            return @"故事状态不允许该操作";
        case 10013:
            return @"声音克隆中，请稍后";
        default:
            return self.message ?: @"请求失败";
    }
}

@end

@implementation PageResponseModel

- (instancetype)init {
    if (self = [super init]) {
        _total = 0;
        _list = @[];
    }
    return self;
}

@end

@implementation StoryListResponseModel
@dynamic list;
@end

@implementation VoiceListResponseModel
@dynamic list;
@end

@implementation IllustrationModel
@end

@implementation IllustrationListResponseModel
@dynamic list;
@end
