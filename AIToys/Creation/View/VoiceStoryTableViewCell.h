//
//  VoiceStoryTableViewCell.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/1.
//

#import <UIKit/UIKit.h>
@class VoiceStoryModel;
NS_ASSUME_NONNULL_BEGIN

@interface VoiceStoryTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *storyNameLabel;
@property (nonatomic, strong) UILabel *voiceLabel;
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) VoiceStoryModel *model;
@property (nonatomic, copy) void(^settingsButtonTapped)(void);
@property (nonatomic, copy) void(^playButtonTapped)(void);

// 根据设计图新增的属性
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIImageView *badgeImageView;
@property (nonatomic, strong) UIView *statusView;

// ⭐️ 关键属性：明确标记是否为批量编辑模式
@property (nonatomic, assign) BOOL isBatchEditingMode;

// 标识当前故事的跳转目标
@property (nonatomic, assign) BOOL shouldJumpToVoiceVC; // YES: 跳转到 CreateStoryWithVoiceVC, NO: 跳转到 CreateStoryVC

@end

NS_ASSUME_NONNULL_END
