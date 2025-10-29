//
//  VoiceManagementTableViewCell.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VoiceModel;

@interface VoiceManagementTableViewCell : UITableViewCell
// UI元素
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;    // 头像图片
@property (weak, nonatomic) IBOutlet UILabel *voiceNameLabel;        // 音色名称
@property (weak, nonatomic) IBOutlet UIButton *editButton;           // 编辑按钮
@property (weak, nonatomic) IBOutlet UIButton *playButton;           // 播放按钮
@property (weak, nonatomic) IBOutlet UIImageView *createNewImageView;

// ✅ 多选编辑模式相关控件
@property (weak, nonatomic) IBOutlet UIButton *chooseButton;          // 选择按钮

// ✅ XIB中的状态相关控件
@property (weak, nonatomic) IBOutlet UIView *statusView;             // 状态容器视图
@property (weak, nonatomic) IBOutlet UIImageView *faildImgView;      // 失败图标
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;           // 状态文字标签

// ✅ 状态标签左边距约束(需要在XIB中连接)
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusLabelLeadingConstraint;
/// 编辑按钮点击回调
@property (nonatomic, copy) void(^editButtonTapped)(VoiceModel *voice);

/// 播放按钮点击回调
@property (nonatomic, copy) void(^playButtonTapped)(VoiceModel *voice);

/// 配置cell显示声音数据
/// @param voice VoiceModel 数据模型
- (void)configureWithVoiceModel:(VoiceModel *)voice;

/// 判断指定音色是否需要显示statusView（用于动态调整cell高度）
/// @param voice VoiceModel 数据模型
/// @return YES表示需要显示statusView，cell高度需要增加35px
+ (BOOL)needsStatusViewForVoice:(VoiceModel *)voice;

/// 更新编辑模式状态
/// @param isEditingMode 是否处于编辑模式
/// @param isSelected 是否被选中
- (void)updateEditingMode:(BOOL)isEditingMode isSelected:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
