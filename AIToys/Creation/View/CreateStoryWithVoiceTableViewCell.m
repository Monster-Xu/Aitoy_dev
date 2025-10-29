//
//  CreateStoryWithVoiceTableViewCell.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import "CreateStoryWithVoiceTableViewCell.h"

@interface CreateStoryWithVoiceTableViewCell ()
@property (nonatomic, strong) VoiceModel *voiceModel;
@end

@implementation CreateStoryWithVoiceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Public Methods

/**
 配置音色数据
 */
- (void)configureWithVoiceModel:(VoiceModel *)voiceModel isSelected:(BOOL)isSelected {
    // 保存音色模型
    self.voiceModel = voiceModel;
    
    // 根据createTime判断是否是近7天内创建的
        if (voiceModel.createTime) {
            // 直接使用doubleValue，无论createTime是NSString还是NSNumber
            NSTimeInterval createTimeInterval = [voiceModel.createTime doubleValue];
            
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
            
            self.voiceNewImage.hidden = !isCreatedToday;
        } else {
            self.voiceNewImage.hidden = YES;
        }
    
    // 设置头像
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:voiceModel.avatarUrl]
                            placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    
    // ✅ XIB已设置好图片，只需要控制selected状态
    self.selectBtn.selected = isSelected;
    self.voiceNameLabel.text = voiceModel.voiceName;
    // 重置播放按钮为未播放状态
    self.playBtn.selected = NO;
}

#pragma mark - Private Methods

/**
 播放按钮点击事件
 */
- (IBAction)playBtnClick:(id)sender {
    // ✅ 切换播放状态
    self.playBtn.selected = !self.playBtn.selected;
    
    // ✅ 通过block回调通知ViewController
    if (self.onPlayButtonTapped) {
        self.onPlayButtonTapped(self.voiceModel, self.playBtn.selected);
    }
}

/**
 选择按钮点击事件
 */
- (IBAction)secletBtnClick:(id)sender {
    // ✅ 切换选择状态
    self.selectBtn.selected = !self.selectBtn.selected;
    
    // ✅ 通过block回调通知ViewController
    if (self.onSelectButtonTapped) {
        self.onSelectButtonTapped(self.voiceModel, self.selectBtn.selected);
    }
}


@end
