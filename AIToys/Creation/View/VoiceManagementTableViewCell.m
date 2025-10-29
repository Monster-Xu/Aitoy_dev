//
//  VoiceManagementTableViewCell.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import "VoiceManagementTableViewCell.h"
#import "VoiceModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface VoiceManagementTableViewCell ()

// 数据
@property (nonatomic, strong) VoiceModel *voiceModel;

// ✅ 编辑模式状态
@property (nonatomic, assign) BOOL isEditingMode;
@property (nonatomic, assign) BOOL isSelected;

@end

@implementation VoiceManagementTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.layer.cornerRadius = 20;
    self.contentView.clipsToBounds = YES;
    
    // 设置选中样式
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 初始化UI
    [self setupUI];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - 初始化UI

- (void)setupUI {
    // 设置背景颜色
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    // 设置按钮交互
    if (self.editButton) {
        [self.editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (self.playButton) {
        [self.playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // ✅ 设置选择按钮
    if (self.chooseButton) {
        [self.chooseButton addTarget:self action:@selector(chooseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        // 初始状态隐藏选择按钮
        self.chooseButton.hidden = YES;
    }
    
    // ✅ 初始化编辑模式状态
    self.isEditingMode = NO;
    self.isSelected = NO;
}

#pragma mark - 数据绑定

/// ✅ 配置cell显示声音数据
- (void)configureWithVoiceModel:(VoiceModel *)voice {
    self.voiceModel = voice;
    
    if (!voice) {
        return;
    }
    
    // 根据createTime判断是否是当天创建的
        if (voice.createTime) {
            // 直接使用doubleValue，无论createTime是NSString还是NSNumber
            NSTimeInterval createTimeInterval = [voice.createTime doubleValue];
            
            // 🔧 处理毫秒时间戳：如果数值大于10位数，说明是毫秒时间戳，需要除以1000
            if (createTimeInterval > 9999999999) { // 10位数以上认为是毫秒时间戳
                createTimeInterval = createTimeInterval / 1000.0;
            }
            
            NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:createTimeInterval];
            
            // 获取当天的开始时间（00:00:00）
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *today = [NSDate date];
            NSDate *startOfToday = [calendar startOfDayForDate:today];
            
            // 获取明天的开始时间（用于判断范围）
            NSDate *startOfTomorrow = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startOfToday options:0];
            
            // 如果创建日期在今天范围内，则显示badge
            BOOL isCreatedToday = ([createDate compare:startOfToday] != NSOrderedAscending) && 
                                  ([createDate compare:startOfTomorrow] == NSOrderedAscending);
            
            
            self.createNewImageView.hidden = !isCreatedToday;
        } else {
            NSLog(@"⚠️ 音色 %@ 没有createTime数据", voice.voiceName ?: @"未知");
            self.createNewImageView.hidden = YES;
        }
    
    // 设置声音名称
    if (self.voiceNameLabel) {
        self.voiceNameLabel.text = voice.voiceName ?: @"未命名";
        self.voiceNameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        self.voiceNameLabel.textColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];
    }
    
    // 设置头像
    if (self.avatarImageView) {
        // ✅ 先清除上一个cell的头像图片，避免重用时的显示错乱
        self.avatarImageView.image = nil;
        
        if (voice.avatarUrl && voice.avatarUrl.length > 0) {
            // 异步加载网络图片
            [self loadImageFromURL:voice.avatarUrl];
        } else {
            // 使用默认图片
            self.avatarImageView.image = [UIImage imageNamed:@"默认头像"];
        }
    }
    
    // 根据音色状态更新UI
    [self updateUIForVoiceStatus:voice];
}



#pragma mark - 根据状态更新UI

/// 根据音色克隆状态更新UI显示
- (void)updateUIForVoiceStatus:(VoiceModel *)voice {
    // 先重置所有按钮状态
    [self resetButtonsState];
    
    
    
    
    
    switch (voice.cloneStatus) {
        case VoiceCloneStatusFailed:
            [self configureFailedState];
            break;
            
        case VoiceCloneStatusCloning:
            [self configureCloningState];
            break;
            
        case VoiceCloneStatusSuccess:
        case VoiceCloneStatusPending:
        default:
            // ✅ 成功状态、待克隆状态等不显示statusView，只配置按钮
            [self configureNormalState:voice];
            break;
    }
}

/// 重置按钮状态和statusView
- (void)resetButtonsState {
    // 隐藏状态视图
    self.statusView.hidden = YES;
    
    // 重置编辑按钮
    self.editButton.enabled = NO;
    self.editButton.hidden = NO;
    [self.editButton setImage:[UIImage imageNamed:@"create_edit"] forState:UIControlStateNormal];
    self.editButton.tintColor = [UIColor lightGrayColor];
    
    // 重置播放按钮
    self.playButton.enabled = NO;
    self.playButton.hidden = NO;
    self.playButton.selected = NO; // ✅ 重置selected状态
    [self.playButton setImage:[UIImage imageNamed:@"create_play"] forState:UIControlStateNormal];
    self.playButton.tintColor = [UIColor lightGrayColor];
    
    // ✅ 重置选择按钮
    if (self.chooseButton) {
        self.chooseButton.hidden = !self.isEditingMode;
        [self updateChooseButtonState];
    }
}

/// 配置克隆失败状态
- (void)configureFailedState {
    NSLog(@"🔴 音色状态: 克隆失败");
    
    // ✅ 显示statusView
    self.statusView.hidden = NO;
    
    // ✅ 设置红色背景，透明度20%
    self.statusView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2];
    
    // ✅ 显示失败图标
    self.faildImgView.hidden = NO;
    
    // ✅ 设置状态文字和颜色
    self.statusLabel.text = @"声音克隆失败，请重新录音";
    self.statusLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]; // 红色文字
    
    // ✅ 当显示失败图标时，statusLabel的左边距由XIB中的约束控制（通常会自动调整）
    // 如果需要特别设置，可以调整约束常量
    
    // 按钮状态：编辑可用（失败后可以重新编辑），播放禁用
    self.editButton.enabled = YES;
    self.editButton.tintColor = [UIColor systemBlueColor];
    
    self.playButton.enabled = NO;
    self.playButton.tintColor = [UIColor lightGrayColor];
}

/// 配置克隆中状态
- (void)configureCloningState {
    NSLog(@"🟡 音色状态: 克隆中");
    
    // ✅ 显示statusView
    self.statusView.hidden = NO;
    
    // ✅ 设置黄色背景，透明度20%
    self.statusView.backgroundColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:0.2];
    
    // ✅ 隐藏失败图标（克隆中不需要显示图标）
    self.faildImgView.hidden = YES;
    
    // ✅ 设置状态文字和颜色
    self.statusLabel.text = @"声音克隆中....";
    self.statusLabel.textColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:1.0]; // 黄色文字
    
    // ✅ 设置statusLabel左边距为16px（当隐藏失败图标时）
    if (self.statusLabelLeadingConstraint) {
        self.statusLabelLeadingConstraint.constant = 16;
    }
    
    // 按钮状态：编辑和播放都禁用（克隆中不能操作）
    self.editButton.hidden = YES;
    self.playButton.hidden = YES;
}


/// 配置正常状态（成功、待克隆等不需要显示statusView的情况）
- (void)configureNormalState:(VoiceModel *)voice {
    NSLog(@"⚪ 音色状态: 正常（不显示statusView）");
    
    // ✅ 隐藏statusView
    self.statusView.hidden = YES;
    
    // ✅ 编辑模式下隐藏编辑和播放按钮，显示选择按钮
    if (self.isEditingMode) {
        self.editButton.hidden = YES;
        self.playButton.hidden = YES;
        self.chooseButton.hidden = NO;
        [self updateChooseButtonState];
        return;
    }
    
    // ✅ 正常模式下显示编辑和播放按钮，隐藏选择按钮
    self.editButton.hidden = NO;
    self.playButton.hidden = NO;
    self.chooseButton.hidden = YES;
    
    // 根据具体状态配置按钮
    switch (voice.cloneStatus) {
        case VoiceCloneStatusSuccess:
            // ✅ 成功状态：编辑和播放都可用
            NSLog(@"🟢 克隆成功状态 - 按钮全部可用");
            self.editButton.enabled = YES;
            self.editButton.tintColor = [UIColor systemBlueColor];
            
            self.playButton.enabled = YES;
            self.playButton.tintColor = [UIColor systemBlueColor];
            
            // ✅ 根据播放状态设置按钮的selected状态
            self.playButton.selected = voice.isPlaying;
            
            break;
            
        case VoiceCloneStatusPending:
            // 待克隆状态：编辑可用，播放禁用
            NSLog(@"🟡 待克隆状态 - 编辑可用");
            self.editButton.enabled = YES;
            self.editButton.tintColor = [UIColor systemBlueColor];
            
            self.playButton.enabled = NO;
            self.playButton.tintColor = [UIColor lightGrayColor];
            break;
            
        default:
            // 其他状态保持禁用
            NSLog(@"❓ 未知状态 - 按钮禁用");
            break;
    }
}

/// 更新状态标签（保留原方法以兼容）
- (void)updateStatusLabel:(NSString *)status color:(UIColor *)color {
    NSLog(@"📋 音色状态更新: %@", status);
}

#pragma mark - 类方法

/// 判断指定音色是否需要显示statusView（用于动态调整cell高度）
+ (BOOL)needsStatusViewForVoice:(VoiceModel *)voice {
    if (!voice) {
        return NO;
    }
    
    // ✅ 只有克隆中和失败状态需要显示statusView
    return (voice.cloneStatus == VoiceCloneStatusCloning || 
            voice.cloneStatus == VoiceCloneStatusFailed);
}

#pragma mark - 网络图片加载

/// 异步加载网络图片（使用缓存）
- (void)loadImageFromURL:(NSString *)urlString {
    if (!urlString || urlString.length == 0) {
        self.avatarImageView.image = [UIImage imageNamed:@"默认头像"];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    // ✅ 使用SDWebImage加载图片，自动处理缓存
    [self.avatarImageView sd_setImageWithURL:url
                            placeholderImage:[UIImage imageNamed:@"默认头像"]
                                   completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error) {
            NSLog(@"⚠️ 头像加载失败: %@", error.localizedDescription);
        } else {
            // 根据缓存类型记录日志
            switch (cacheType) {
                case SDImageCacheTypeNone:
                    NSLog(@"📥 头像从网络加载: %@", urlString);
                    break;
                case SDImageCacheTypeMemory:
                    NSLog(@"💾 头像从内存缓存加载: %@", urlString);
                    break;
                case SDImageCacheTypeDisk:
                    NSLog(@"💿 头像从磁盘缓存加载: %@", urlString);
                    break;
            }
        }
    }];
}

#pragma mark - 按钮点击事件

/// 编辑按钮点击事件
- (void)editButtonAction:(UIButton *)sender {
    NSLog(@"🖊️ 编辑按钮被点击 - 音色: %@, 状态: %ld", self.voiceModel.voiceName, (long)self.voiceModel.cloneStatus);
    
    if (self.editButtonTapped && self.voiceModel) {
        self.editButtonTapped(self.voiceModel);
    }
}

/// 播放按钮点击事件
- (void)playButtonAction:(UIButton *)sender {
    NSLog(@"▶️ 播放按钮被点击 - 音色: %@, 状态: %ld", self.voiceModel.voiceName, (long)self.voiceModel.cloneStatus);
    
    if (self.playButtonTapped && self.voiceModel) {
        self.playButtonTapped(self.voiceModel);
    }
}

#pragma mark - ✅ 编辑模式管理

/// 更新编辑模式状态
- (void)updateEditingMode:(BOOL)isEditingMode isSelected:(BOOL)isSelected {
    self.isEditingMode = isEditingMode;
    self.isSelected = isSelected;
    
    NSLog(@"📝 Cell编辑模式状态更新 - 编辑模式: %@, 选中状态: %@", 
          isEditingMode ? @"是" : @"否", isSelected ? @"是" : @"否");
    
    // 更新按钮显示状态
    if (isEditingMode) {
        // 编辑模式：隐藏编辑和播放按钮，显示选择按钮
        self.editButton.hidden = YES;
        self.playButton.hidden = YES;
        self.chooseButton.hidden = NO;
    } else {
        // 正常模式：显示编辑和播放按钮，隐藏选择按钮
        self.editButton.hidden = NO;
        self.playButton.hidden = NO;
        self.chooseButton.hidden = YES;
    }
    
    // 更新选择按钮状态
    [self updateChooseButtonState];
    
    // 如果退出编辑模式且有音色数据，重新配置按钮状态
    if (!isEditingMode && self.voiceModel) {
        [self updateUIForVoiceStatus:self.voiceModel];
    }
}

/// 更新选择按钮的图片状态
- (void)updateChooseButtonState {
    if (!self.chooseButton) {
        return;
    }
    
    if (self.isSelected) {
        // 选中状态：显示choose_sel图片
        [self.chooseButton setImage:[UIImage imageNamed:@"choose_sel"] forState:UIControlStateNormal];
        NSLog(@"✅ 选择按钮状态: 已选中");
    } else {
        // 未选中状态：显示choose_normal图片
        [self.chooseButton setImage:[UIImage imageNamed:@"choose_normal"] forState:UIControlStateNormal];
        NSLog(@"⭕ 选择按钮状态: 未选中");
    }
}

/// 选择按钮点击事件
- (void)chooseButtonAction:(UIButton *)sender {
    NSLog(@"✅ 选择按钮被点击 - 音色: %@, 当前状态: %@", 
          self.voiceModel.voiceName, self.isSelected ? @"已选中" : @"未选中");
    
    // 选择按钮的点击会通过tableView的didSelectRowAtIndexPath处理
    // 这里不需要额外处理，点击会自动触发cell的选中/取消选中
}

#pragma mark - 重用准备

/// 准备重用时重置状态
- (void)prepareForReuse {
    [super prepareForReuse];
    
    // ✅ 清除头像图片，避免重用时显示错乱
    self.avatarImageView.image = nil;
    
    // 重置回调
    self.editButtonTapped = nil;
    self.playButtonTapped = nil;
    
    // 重置数据
    self.voiceModel = nil;
    
    // ✅ 重置编辑模式状态
    self.isEditingMode = NO;
    self.isSelected = NO;
    
    // 重置UI状态
    [self resetButtonsState];
    
    NSLog(@"🔄 Cell准备重用，状态已重置");
}

@end
