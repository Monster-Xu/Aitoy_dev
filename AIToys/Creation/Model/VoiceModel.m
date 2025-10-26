//
//  VoiceModel.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//

#import "VoiceModel.h"

@implementation VoiceModel

- (instancetype)init {
    if (self = [super init]) {
        _voiceId = 0;
        _cloneStatus = VoiceCloneStatusPending;
        _bindStoryCount = 0;
        _sampleText = @"Hello, let's play together";
    }
    return self;
}

- (BOOL)canDelete {
    return self.bindStoryCount == 0;
}

- (BOOL)canUse {
    return self.cloneStatus == VoiceCloneStatusSuccess;
}

- (BOOL)isCloning {
    return self.cloneStatus == VoiceCloneStatusCloning;
}

- (NSString *)cloneStatusDescription {
    if (self.statusDesc) {
        return self.statusDesc;
    }
    
    switch (self.cloneStatus) {
        case VoiceCloneStatusPending:
            return @"待克隆";
        case VoiceCloneStatusCloning:
            return @"克隆中";
        case VoiceCloneStatusSuccess:
            return @"克隆成功";
        case VoiceCloneStatusFailed:
            return @"克隆失败";
        default:
            return @"待克隆";
    }
}

@end