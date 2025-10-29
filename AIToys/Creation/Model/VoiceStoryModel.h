//
//  VoiceStoryModel.h
//  AIToys
//

//  Updated by xuxuxu on 2025/10/15.

//

#import <Foundation/Foundation.h>

@class StoryBoundDoll;

NS_ASSUME_NONNULL_BEGIN

// 故事状态枚举
typedef NS_ENUM(NSInteger, StoryStatus) {
    StoryStatusPending = 0,       // 故事待生成
    StoryStatusGenerating = 1,    // 故事生成中
    StoryStatusGenerated = 2,     // 故事生成成功
    StoryStatusGenerateFailed = 3,// 故事生成失败
    StoryStatusAudioGenerating = 4,// 音频生成中
    StoryStatusCompleted = 5,     // 音频生成成功
    StoryStatusAudioFailed = 6    // 音频生成失败
};

// 故事类型枚举
typedef NS_ENUM(NSInteger, StoryType) {
    StoryTypeFairyTale = 1,       // 童话
    StoryTypeFable = 2,           // 寓言
    StoryTypeAdventure = 3,       // 冒险
    StoryTypeSuperhero = 4,       // 超级英雄
    StoryTypeScienceFiction = 5,  // 科幻
    StoryTypeEducational = 6,     // 教育
    StoryTypeBedtime = 7          // 睡前故事
};

@interface VoiceStoryModel : NSObject

// 基本信息
@property (nonatomic, assign) NSInteger storyId;
@property (nonatomic, copy) NSString *storyName;
@property (nonatomic, copy, nullable) NSString *storyContent;
@property (nonatomic, copy, nullable) NSString *storySummary;
@property (nonatomic, assign) StoryType storyType;
@property (nonatomic, copy, nullable) NSString *storyTypeDesc;
@property (nonatomic, copy) NSString *protagonistName;
@property (nonatomic, assign) NSInteger storyLength;
@property (nonatomic, copy, nullable) NSString *illustrationUrl;

// 声音和音频信息
@property (nonatomic, assign) NSInteger voiceId;
@property (nonatomic, copy, nullable) NSString *voiceName;
@property (nonatomic, copy, nullable) NSString *audioUrl;

// 状态信息
@property (nonatomic, assign) StoryStatus storyStatus;
@property (nonatomic, copy, nullable) NSString *statusDesc;
@property (nonatomic, copy, nullable) NSString *errorMsg;

// 公仔关联 - 新版本（支持多公仔绑定）
/// 绑定的公仔列表
@property (nonatomic, strong, nullable) NSArray<StoryBoundDoll *> *boundDolls;

// 公仔关联 - 旧版本（已废弃，保留用于兼容）
/// @deprecated 使用 boundDolls 代替。此属性已废弃，仅保留用于向后兼容
@property (nonatomic, assign) NSInteger dollId DEPRECATED_MSG_ATTRIBUTE("Use boundDolls instead");
/// @deprecated 使用 boundDolls 代替。此属性已废弃，仅保留用于向后兼容
@property (nonatomic, copy, nullable) NSString *dollName DEPRECATED_MSG_ATTRIBUTE("Use boundDolls instead");

// 时间信息
@property (nonatomic, copy, nullable) NSString *createTime;
@property (nonatomic, copy, nullable) NSString *updateTime;

// 兼容旧版本的属性
@property (nonatomic, copy) NSString *status; // 兼容旧版本，映射到 statusDesc

// UI状态属性
@property (nonatomic, assign) BOOL isNew;       // 是否显示New标签
@property (nonatomic, assign) BOOL isPlaying;   // 是否正在播放
@property (nonatomic, assign) BOOL isLoading;   // 是否正在加载音频

// 便利方法
- (NSString *)storyTypeDescription;
- (BOOL)canPlay;
- (BOOL)canEdit;
- (BOOL)isGenerating;
- (BOOL)hasFailed;

/// 获取主要绑定的公仔（第一个公仔）
- (nullable StoryBoundDoll *)primaryBoundDoll;

/// 是否有绑定的公仔
- (BOOL)hasBoundDolls;

@end

NS_ASSUME_NONNULL_END
