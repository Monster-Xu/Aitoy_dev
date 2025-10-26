//
//  VoiceStoryModel.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/1.
//

#import "VoiceStoryModel.h"

@implementation VoiceStoryModel

- (instancetype)init {
    if (self = [super init]) {
        _storyId = 0;
        _voiceId = 0;
        _dollId = 0;
        _storyStatus = StoryStatusPending;
        _storyType = StoryTypeFairyTale;
        _storyLength = 180;
        _isNew = NO;
        _isPlaying = NO;
    }
    return self;
}

- (NSString *)storyTypeDescription {
    switch (self.storyType) {
        case StoryTypeFairyTale:
            return @"童话";
        case StoryTypeFable:
            return @"寓言";
        case StoryTypeAdventure:
            return @"冒险";
        case StoryTypeSuperhero:
            return @"超级英雄";
        case StoryTypeScienceFiction:
            return @"科幻";
        case StoryTypeEducational:
            return @"教育";
        case StoryTypeBedtime:
            return @"睡前故事";
        default:
            return @"童话";
    }
}

- (BOOL)canPlay {
    return self.storyStatus == StoryStatusCompleted && self.audioUrl.length > 0;
}

- (BOOL)canEdit {
    return self.storyStatus == StoryStatusGenerated || 
           self.storyStatus == StoryStatusCompleted || 
           self.storyStatus == StoryStatusAudioFailed;
}

- (BOOL)isGenerating {
    return self.storyStatus == StoryStatusGenerating || 
           self.storyStatus == StoryStatusAudioGenerating;
}

// 兼容旧版本的 status 属性
- (NSString *)status {
    if (self.statusDesc) {
        return self.statusDesc;
    }
    
    switch (self.storyStatus) {
        case StoryStatusPending:
            return @"pending";
        case StoryStatusGenerating:
            return @"generating";
        case StoryStatusGenerated:
            return @"generated";
        case StoryStatusGenerateFailed:
            return @"failed";
        case StoryStatusAudioGenerating:
            return @"generating";
        case StoryStatusCompleted:
            return @"completed";
        case StoryStatusAudioFailed:
            return @"failed";
        default:
            return @"pending";
    }
}

- (void)setStatus:(NSString *)status {
    self.statusDesc = status;
    
    // 映射到新的枚举状态
    if ([status isEqualToString:@"completed"]) {
        self.storyStatus = StoryStatusCompleted;
    } else if ([status isEqualToString:@"generating"]) {
        self.storyStatus = StoryStatusGenerating;
    } else if ([status isEqualToString:@"pending"]) {
        self.storyStatus = StoryStatusPending;
    }
}

- (BOOL)hasFailed {
    return [self.status isEqualToString:@"failed"];
}

@end
