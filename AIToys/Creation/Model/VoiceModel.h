//
//  VoiceModel.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 声音克隆状态枚举
typedef NS_ENUM(NSInteger, VoiceCloneStatus) {
    VoiceCloneStatusPending = 0,    // 待克隆
    VoiceCloneStatusCloning = 1,    // 克隆中
    VoiceCloneStatusSuccess = 2,    // 克隆成功
    VoiceCloneStatusFailed = 3      // 克隆失败
};

@interface VoiceModel : NSObject

// 基本信息
@property (nonatomic, assign) NSInteger voiceId;
@property (nonatomic, copy) NSString *voiceName;
@property (nonatomic, copy, nullable) NSString *avatarUrl;

// 克隆状态
@property (nonatomic, assign) VoiceCloneStatus cloneStatus;
@property (nonatomic, copy, nullable) NSString *statusDesc;
@property (nonatomic, copy, nullable) NSString *errorMsg;

// 示例音频
@property (nonatomic, copy, nullable) NSString *sampleAudioUrl;
@property (nonatomic, copy, nullable) NSString *sampleText;

// 业务信息
@property (nonatomic, assign) NSInteger bindStoryCount;

// 时间信息
@property (nonatomic, copy, nullable) NSString *createTime;
@property (nonatomic, copy, nullable) NSString *updateTime;

@property (nonatomic,assign)BOOL isPlaying;

// 便利方法
- (BOOL)canDelete;
- (BOOL)canUse;
- (BOOL)isCloning;
- (NSString *)cloneStatusDescription;

@end

NS_ASSUME_NONNULL_END
