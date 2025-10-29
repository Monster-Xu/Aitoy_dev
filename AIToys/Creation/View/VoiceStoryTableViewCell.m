//
//  VoiceStoryTableViewCell.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/1.
//

#import "VoiceStoryTableViewCell.h"
#import "VoiceStoryModel.h"
#import "AudioPlayerView.h"

@implementation VoiceStoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 默认不是批量编辑模式
        _isBatchEditingMode = NO;
        
        // 设置 cell 背景为透明，显示父视图背景色
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 配置选择样式
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.tintColor = [UIColor systemBlueColor];
    
    // 创建白色卡片容器视图
    UIView *cardContainerView = [[UIView alloc] init];
    cardContainerView.backgroundColor = [UIColor whiteColor];
    cardContainerView.layer.cornerRadius = 20;
    cardContainerView.layer.masksToBounds = YES;
    [self.contentView addSubview:cardContainerView];
    
    // 使用Masonry设置卡片容器的约束：左右各16，上下填满（无边距）
    [cardContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.top.equalTo(self.contentView);      // ✅ 移除上边距
        make.bottom.equalTo(self.contentView);   // ✅ 移除下边距
    }];
    
    // 封面图
    self.coverImageView = [[UIImageView alloc] init];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.layer.cornerRadius = 8;
    self.coverImageView.image = [UIImage imageNamed:@"默认头像"];
    self.coverImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [cardContainerView addSubview:self.coverImageView];
    
    // New标签
    self.badgeImageView = [[UIImageView alloc] init];
    self.badgeImageView.image = [UIImage imageNamed:@"create_new"];
    self.badgeImageView.hidden = YES;
    [cardContainerView addSubview:self.badgeImageView];
    
    
    // ⭐️ 状态视图 - 显示在封面图下方
    self.statusView = [[UIView alloc] init];
    self.statusView.layer.cornerRadius = 8;
    self.statusView.hidden = YES;
    [cardContainerView addSubview:self.statusView];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont systemFontOfSize:14]; // 更小的字体
    self.statusLabel.textAlignment = NSTextAlignmentLeft;
    self.statusLabel.numberOfLines = 2; // 允许两行显示
    [self.statusView addSubview:self.statusLabel];
    
    // 使用Masonry设置statusLabel约束
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.statusView).offset(4);
        make.right.equalTo(self.statusView).offset(-4);
        make.top.equalTo(self.statusView).offset(3);
        make.bottom.equalTo(self.statusView).offset(-3);
    }];
    
    // 标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.numberOfLines = 2;
    [cardContainerView addSubview:self.titleLabel];
    
    // 副标题
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.borderWidth = 1;
    self.subtitleLabel.borderColor = [UIColor lightGrayColor];
    self.subtitleLabel.cornerRadius = 4;
    self.subtitleLabel.clipsToBounds = YES;
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel.font = [UIFont systemFontOfSize:9];
    
    [cardContainerView addSubview:self.subtitleLabel];
    
    // 编辑按钮
    self.editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    // 默认使用disable状态的图片
    [self.editButton setImage:[UIImage imageNamed:@"create_disedit"] forState:UIControlStateNormal];
    self.editButton.tintColor = [UIColor systemGrayColor];
    self.editButton.enabled = NO; // 默认禁用
    [self.editButton addTarget:self action:@selector(editButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cardContainerView addSubview:self.editButton];
    
    // 播放按钮
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // 默认使用disable状态的图片
    [self.playButton setImage:[UIImage imageNamed:@"create_display"] forState:UIControlStateNormal];
    self.playButton.tintColor = [UIColor systemGrayColor];
    self.playButton.enabled = NO; // 默认禁用
    [self.playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cardContainerView addSubview:self.playButton];
    
    // ✅ 音频加载指示器
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingIndicator.color = [UIColor systemBlueColor];
    self.loadingIndicator.hidesWhenStopped = YES;
    self.loadingIndicator.hidden = YES;
    [cardContainerView addSubview:self.loadingIndicator];
    
    // 初始化加载状态
    self.isAudioLoading = NO;
    
    // ✅ 自定义选择按钮
    [self setupChooseButton:cardContainerView];
    
    [self setupConstraintsWithContainer:cardContainerView];
}

 - (void)setupConstraintsWithContainer:(UIView *)cardContainer {
    // 封面图 - 左上角
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cardContainer).offset(12);
        make.top.equalTo(cardContainer).offset(12);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(64);
    }];
    
    // New标签 - 在封面图上层
    [self.badgeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView).offset(0);
        make.top.equalTo(self.coverImageView).offset(0);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(20);
    }];
    
    // 播放按钮 - 最右侧居中（先布局，因为标题需要参考它）
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(cardContainer).offset(-16);
        make.centerY.equalTo(cardContainer);
        make.width.height.mas_equalTo(24);
    }];
    
    // ✅ 加载指示器 - 与播放按钮相同位置
    [self.loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playButton);
        make.width.height.mas_equalTo(20);
    }];
    
    // 编辑按钮 - 播放按钮左侧居中
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.playButton.mas_left).offset(-12);
        make.centerY.equalTo(cardContainer);
        make.width.height.mas_equalTo(24);
    }];
    
    // 标题 - 封面图右侧顶部对齐
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView.mas_right).offset(12);
        make.top.equalTo(cardContainer).offset(14);
        make.right.equalTo(self.editButton.mas_left).offset(-8);
    }];
    
    // 副标题 - 标题下方
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.bottom.equalTo(self.coverImageView.mas_bottom).offset(0);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(55);
    }];
    
    // 状态视图 - 卡片底部，左右各12边距
    [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cardContainer).offset(12);
        make.right.equalTo(cardContainer).offset(-12);
        make.bottom.equalTo(cardContainer).offset(-12);
        make.height.mas_equalTo(28);
    }];
}

- (void)setModel:(VoiceStoryModel *)model {
    _model = model;
    
    self.titleLabel.text = model.storyName;
    
    if (model.illustrationUrl && model.illustrationUrl.length > 0) {
        self.coverImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.illustrationUrl]];
    }
    
    
    
    // 根据createTime判断是否是当天创建的
        if (model.createTime) {
            // 直接使用doubleValue，无论createTime是NSString还是NSNumber
            NSTimeInterval createTimeInterval = [model.createTime doubleValue];
            
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
            
            // 🔍 调试信息（修复后）
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

            self.badgeImageView.hidden = !isCreatedToday;
        } else {
            self.badgeImageView.hidden = YES;
        }
    
    // 根据 storyStatus 配置按钮状态和可见性
    switch (model.storyStatus) {
        case 1:
            [self configureGeneratingState];
            break;
        case 2:
            [self configureStatus2State]; // 生成完成，需要编辑跳转到 CreateStoryWithVoiceVC
            break;
        case 3:
            [self configureStatus3State]; // 失败状态，需要编辑跳转到 CreateStoryVC
            break;
        case 4:
            [self configureAudioGeneratingState]; // 音频生成中
            break;
        case 5:
            [self configureStatus5State]; // 可播放状态，跳转到 CreateStoryWithVoiceVC
            break;
        case 6:
            [self configureStatus6State]; // 跳转到 CreateStoryWithVoiceVC，播放按钮不可用
            break;
        default:
            [self configurePendingState];
            break;
    }
}



- (void)configureGeneratingState {
    // ⭐️ 状态提示显示在封面图下方
    self.statusView.hidden = NO;
    self.statusView.backgroundColor = [UIColor colorWithRed:1.0 green:0.95 blue:0.8 alpha:1.0]; // 浅橙色
    self.statusView.layer.cornerRadius = 4;
    self.statusLabel.text = @"  Story Generation...";
    self.statusLabel.textColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:1.0]; // 橙色文字
    
    // 确保显示副标题
    self.subtitleLabel.hidden = NO;
    
    // 设置声音信息
    if (self.model.voiceName && self.model.voiceName.length > 0 && ![self.model.voiceName isEqualToString:@"--"]) {
        self.subtitleLabel.text = [NSString stringWithFormat:@"Voice - %@", self.model.voiceName];
        self.subtitleLabel.textColor = [UIColor systemBlueColor];
    } else {
        self.subtitleLabel.text = @"No Voice";
        self.subtitleLabel.textColor = [UIColor systemGrayColor];
    }
    
    // 禁用播放按钮
    self.playButton.enabled = NO;
    [self.playButton setImage:[UIImage imageNamed:@"create_display"] forState:UIControlStateNormal];
    self.playButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    // 禁用编辑按钮
    self.editButton.enabled = NO;
    [self.editButton setImage:[UIImage imageNamed:@"create_disedit"] forState:UIControlStateNormal];
    self.editButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    // 其他状态时编辑按钮不可用，不设置跳转目标
    self.shouldJumpToVoiceVC = NO;
}

- (void)configureAudioGeneratingState {
    // ⭐️ 音频生成中状态：显示生成横幅和音色名称
    self.statusView.hidden = NO;
    self.statusView.backgroundColor = [UIColor colorWithRed:1.0 green:0.95 blue:0.8 alpha:1.0]; // 浅橙色
    self.statusView.layer.cornerRadius = 4;
    self.statusLabel.text = @"  Audio Generation...";
    self.statusLabel.textColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:1.0]; // 橙色文字
    
    // 设置声音信息 - 确保显示音色名称
    if (self.model.voiceName && self.model.voiceName.length > 0 && ![self.model.voiceName isEqualToString:@"--"]) {
        self.subtitleLabel.text = [NSString stringWithFormat:@"Voice - %@", self.model.voiceName];
        self.subtitleLabel.textColor = [UIColor systemBlueColor];
        self.subtitleLabel.hidden = NO;
    } else {
        self.subtitleLabel.text = @"No Voice";
        self.subtitleLabel.textColor = [UIColor systemGrayColor];
        self.subtitleLabel.hidden = NO;
    }
    
    // 禁用播放按钮
    self.playButton.enabled = NO;
    [self.playButton setImage:[UIImage imageNamed:@"create_display"] forState:UIControlStateNormal];
    self.playButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    // 禁用编辑按钮
    self.editButton.enabled = NO;
    [self.editButton setImage:[UIImage imageNamed:@"create_disedit"] forState:UIControlStateNormal];
    self.editButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    // 音频生成中时不设置跳转目标
    self.shouldJumpToVoiceVC = NO;
}

- (void)configureStatus2State {
    // status = 2: 编辑和点击跳转到 CreateStoryWithVoiceVC，播放按钮不可用
    self.statusView.hidden = YES;
    self.subtitleLabel.hidden = NO;
    
    // 设置声音信息
    if (self.model.voiceName && self.model.voiceName.length > 0 && ![self.model.voiceName isEqualToString:@"--"]) {
        self.subtitleLabel.text = [NSString stringWithFormat:@"Voice - %@", self.model.voiceName];
        self.subtitleLabel.textColor = [UIColor systemBlueColor];
    } else {
        self.subtitleLabel.text = @"No Voice";
        self.subtitleLabel.textColor = [UIColor systemGrayColor];
    }
    
    // 显示编辑按钮并启用
    self.editButton.hidden = NO;
    self.editButton.enabled = YES;
    [self.editButton setImage:[UIImage imageNamed:@"create_edit"] forState:UIControlStateNormal];
    self.editButton.tintColor = [UIColor systemGrayColor];
    
    // 播放按钮不可用
    self.playButton.enabled = NO;
    [self.playButton setImage:[UIImage imageNamed:@"create_display"] forState:UIControlStateNormal];
    self.playButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    // 设置跳转目标为 CreateStoryWithVoiceVC
    self.shouldJumpToVoiceVC = YES;
}

- (void)configureStatus3State {
    // status = 3: 编辑和点击跳转到 CreateStoryVC，播放按钮不可用
    self.statusView.hidden = NO;
    self.statusView.backgroundColor = [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1.0]; // 浅红色
    self.statusLabel.text = @"   Failed, Try Again";
    self.statusLabel.textColor = [UIColor systemRedColor];
    
    // 确保显示副标题
    self.subtitleLabel.hidden = NO;
    
    // 设置声音信息
    if (self.model.voiceName && self.model.voiceName.length > 0 && ![self.model.voiceName isEqualToString:@"--"]) {
        self.subtitleLabel.text = [NSString stringWithFormat:@"Voice - %@", self.model.voiceName];
        self.subtitleLabel.textColor = [UIColor systemBlueColor];
    } else {
        self.subtitleLabel.text = @"No Voice";
        self.subtitleLabel.textColor = [UIColor systemGrayColor];
    }
    
    // 显示编辑按钮并启用
    self.editButton.hidden = NO;
    self.editButton.enabled = YES;
    [self.editButton setImage:[UIImage imageNamed:@"create_edit"] forState:UIControlStateNormal];
    self.editButton.tintColor = [UIColor systemGrayColor];
    
    // 播放按钮不可用
    self.playButton.enabled = NO;
    [self.playButton setImage:[UIImage imageNamed:@"create_display"] forState:UIControlStateNormal];
    self.playButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    // 设置跳转目标为 CreateStoryVC
    self.shouldJumpToVoiceVC = NO;
}

- (void)configureStatus5State {
    // status = 5: 编辑和点击跳转到 CreateStoryWithVoiceVC，播放按钮可用
    self.statusView.hidden = YES;
    self.subtitleLabel.hidden = NO;
    
    // 设置声音信息
    if (self.model.voiceName && self.model.voiceName.length > 0 && ![self.model.voiceName isEqualToString:@"--"]) {
        self.subtitleLabel.text = [NSString stringWithFormat:@"Voice - %@", self.model.voiceName];
        self.subtitleLabel.textColor = [UIColor systemBlueColor];
    } else {
        self.subtitleLabel.text = @"No Voice";
        self.subtitleLabel.textColor = [UIColor systemGrayColor];
    }
    
    // 显示编辑按钮并启用
    self.editButton.hidden = NO;
    self.editButton.enabled = YES;
    [self.editButton setImage:[UIImage imageNamed:@"create_edit"] forState:UIControlStateNormal];
    self.editButton.tintColor = [UIColor systemGrayColor];
    
    // 播放按钮可用
    self.playButton.enabled = YES;
    if (self.model.isPlaying) {
        [self.playButton setImage:[UIImage imageNamed:@"create_pause"] forState:UIControlStateNormal];
        self.playButton.tintColor = [UIColor systemBlueColor];
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"create_play"] forState:UIControlStateNormal];
        self.playButton.tintColor = [UIColor systemGrayColor];
    }
    
    // 设置跳转目标为 CreateStoryWithVoiceVC
    self.shouldJumpToVoiceVC = YES;
}

- (void)configureStatus6State {
    // status = 6: 编辑和点击跳转到 CreateStoryWithVoiceVC，播放按钮不可用
    self.statusView.hidden = YES;
    self.subtitleLabel.hidden = NO;
    
    // 设置声音信息
    if (self.model.voiceName && self.model.voiceName.length > 0 && ![self.model.voiceName isEqualToString:@"--"]) {
        self.subtitleLabel.text = [NSString stringWithFormat:@"Voice - %@", self.model.voiceName];
        self.subtitleLabel.textColor = [UIColor systemBlueColor];
    } else {
        self.subtitleLabel.text = @"No Voice";
        self.subtitleLabel.textColor = [UIColor systemGrayColor];
    }
    
    // 显示编辑按钮并启用
    self.editButton.hidden = NO;
    self.editButton.enabled = YES;
    [self.editButton setImage:[UIImage imageNamed:@"create_edit"] forState:UIControlStateNormal];
    self.editButton.tintColor = [UIColor systemGrayColor];
    
    // 播放按钮不可用
    self.playButton.enabled = NO;
    [self.playButton setImage:[UIImage imageNamed:@"create_display"] forState:UIControlStateNormal];
    self.playButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    // 设置跳转目标为 CreateStoryWithVoiceVC
    self.shouldJumpToVoiceVC = YES;
}

- (void)configureFailedState {
    // 保持原有的失败状态配置（兼容性）
    [self configureStatus3State];
}

- (void)configureCompletedState {
    // 保持原有的完成状态配置（兼容性）
    [self configureStatus5State];
}

- (void)configurePendingState {
    // ⭐️ 隐藏状态视图，显示副标题
    self.statusView.hidden = YES;
    self.subtitleLabel.hidden = NO;
    self.subtitleLabel.text = @"No Voice";
    self.subtitleLabel.textColor = [UIColor systemGrayColor];
        
    // 禁用播放按钮
    self.playButton.enabled = NO;
    [self.playButton setImage:[UIImage imageNamed:@"create_display"] forState:UIControlStateNormal];
    self.playButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    // 禁用编辑按钮
    self.editButton.enabled = NO;
    [self.editButton setImage:[UIImage imageNamed:@"create_disedit"] forState:UIControlStateNormal];
    self.editButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    // 其他状态不设置跳转目标
    self.shouldJumpToVoiceVC = NO;
}


#pragma mark - Actions

- (void)editButtonTapped:(UIButton *)sender {
    if (self.settingsButtonTapped) {
        self.settingsButtonTapped();
    }
}

- (void)playButtonTapped:(UIButton *)sender {
    if (self.playButtonTapped) {
        self.playButtonTapped();
    }
}

#pragma mark - ✅ Custom Selection Setup

/// 设置自定义选择按钮（参考音色管理实现）
- (void)setupChooseButton:(UIView *)cardContainerView {
    // 创建选择按钮
    self.chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.chooseButton.hidden = YES; // 默认隐藏
    
    // 设置默认未选中状态的图片
    [self.chooseButton setImage:[UIImage imageNamed:@"choose_normal"] forState:UIControlStateNormal];
    
    // 添加点击事件（虽然在批量编辑模式下主要通过cell点击处理，但保持一致性）
    [self.chooseButton addTarget:self action:@selector(chooseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [cardContainerView addSubview:self.chooseButton];
    
    // 设置约束 - 与编辑和播放按钮相同位置
    [self.chooseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(cardContainerView).offset(-16);
        make.centerY.equalTo(cardContainerView);
        make.width.height.mas_equalTo(24);
    }];
    
    // 初始化选中状态
    self.isCustomSelected = NO;
}

/// 选择按钮点击事件
- (void)chooseButtonTapped:(UIButton *)sender {
    NSLog(@"✅ 选择按钮被点击");
    sender.selected = !sender.selected;
    [self updateSelectionState:sender.selected];
}

/// 更新自定义选择状态（参考音色管理实现）
- (void)updateSelectionState:(BOOL)selected {
    self.isCustomSelected = selected;
    
    if (selected) {
        // 选中状态：显示choose_sel图片
        [self.chooseButton setImage:[UIImage imageNamed:@"choose_sel"] forState:UIControlStateNormal];
        NSLog(@"✅ Cell 选择状态更新: 选中");
    } else {
        // 未选中状态：显示choose_normal图片
        [self.chooseButton setImage:[UIImage imageNamed:@"choose_normal"] forState:UIControlStateNormal];
        NSLog(@"❌ Cell 选择状态更新: 未选中");
    }
}

#pragma mark - Editing Mode

// ⭐️ 核心方法：使用明确的标记判断编辑模式
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    NSLog(@"Cell setEditing: %@, isBatchEditingMode: %@",
          editing ? @"YES" : @"NO",
          self.isBatchEditingMode ? @"YES" : @"NO");
    
    // 清晰的判断逻辑：
    // 1. 批量编辑模式（isBatchEditingMode = YES）：隐藏按钮，显示选择按钮
    // 2. 左滑删除（editing = YES, isBatchEditingMode = NO）：显示按钮，隐藏选择按钮
    // 3. 正常模式（editing = NO）：显示按钮，隐藏选择按钮
    
    if (self.isBatchEditingMode && editing) {
        // 批量编辑模式：隐藏操作按钮，显示选择按钮
        NSLog(@"📱 批量编辑模式 - 隐藏按钮，显示选择按钮");
        self.playButton.hidden = YES;
        self.editButton.hidden = YES;
        [self.loadingIndicator stopAnimating];  // ✅ 停止加载动画
        self.loadingIndicator.hidden = YES;     // ✅ 隐藏加载指示器
        self.chooseButton.hidden = NO; // ✅ 显示选择按钮
        
    } else {
        // 正常模式或左滑删除：显示按钮，隐藏选择按钮
        NSLog(@"📱 正常模式 - 显示按钮，隐藏选择按钮");
        self.editButton.hidden = NO;
        self.chooseButton.hidden = YES; // ✅ 隐藏选择按钮
        
        // ✅ 根据加载状态决定显示播放按钮还是加载指示器
        if (self.isAudioLoading) {
            self.playButton.hidden = YES;
            self.loadingIndicator.hidden = NO;
            [self.loadingIndicator startAnimating];
        } else {
            self.playButton.hidden = NO;
            self.loadingIndicator.hidden = YES;
        }
    }
}


/// ✅ 显示/隐藏音频加载状态
- (void)showAudioLoading:(BOOL)loading {
    self.isAudioLoading = loading;
    
    if (loading) {
        // 显示加载状态
        self.playButton.hidden = YES;
        self.loadingIndicator.hidden = NO;
        [self.loadingIndicator startAnimating];
        
        NSLog(@"🔄 显示音频加载状态");
    } else {
        // 隐藏加载状态
        [self.loadingIndicator stopAnimating];
        self.loadingIndicator.hidden = YES;
        self.playButton.hidden = NO;
        
        NSLog(@"✅ 隐藏音频加载状态");
    }
}

// 重置方法
- (void)prepareForReuse {
    [super prepareForReuse];
    
    // 重置批量编辑标记
    self.isBatchEditingMode = NO;
    
    // ✅ 重置自定义选择状态
    self.isCustomSelected = NO;
    self.chooseButton.hidden = YES;
    [self updateSelectionState:NO];
    
    // ✅ 重置音频加载状态
    [self showAudioLoading:NO];
    
    // 重置按钮状态
    self.playButton.hidden = NO;
    self.editButton.hidden = NO;
    
    // 重置按钮为默认禁用状态
    self.playButton.enabled = NO;
    [self.playButton setImage:[UIImage imageNamed:@"create_display"] forState:UIControlStateNormal];
    self.editButton.enabled = NO;
    [self.editButton setImage:[UIImage imageNamed:@"create_disedit"] forState:UIControlStateNormal];
    
    NSLog(@"Cell prepareForReuse - 重置状态");
}

@end
