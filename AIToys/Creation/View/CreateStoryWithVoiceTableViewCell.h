//
//  CreateStoryWithVoiceTableViewCell.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import <UIKit/UIKit.h>
#import "VoiceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CreateStoryWithVoiceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *voiceNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *voiceNewImage;

/**
 播放按钮点击回调
 参数：voiceModel - 当前音色模型, isPlaying - 是否正在播放
 */
@property (nonatomic, copy) void(^onPlayButtonTapped)(VoiceModel *voiceModel, BOOL isPlaying);

/**
 选择按钮点击回调
 参数：voiceModel - 当前音色模型, isSelected - 是否选中
 */
@property (nonatomic, copy) void(^onSelectButtonTapped)(VoiceModel *voiceModel, BOOL isSelected);

/**
 配置音色数据
 @param voiceModel 音色模型对象
 @param isSelected 是否选中
 */
- (void)configureWithVoiceModel:(VoiceModel *)voiceModel isSelected:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
