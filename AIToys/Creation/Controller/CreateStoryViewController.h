//
//  CreateStoryViewController.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//

#import <UIKit/UIKit.h>

@class VoiceStoryModel;

NS_ASSUME_NONNULL_BEGIN

@interface CreateStoryViewController : BaseViewController

/// 用于编辑模式的故事数据（生成失败时重新编辑）
@property (nonatomic, strong, nullable) VoiceStoryModel *storyModel;

@end

NS_ASSUME_NONNULL_END
