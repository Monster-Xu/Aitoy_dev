//
//  HomeExploreToysCell.m
//  AIToys
//
//  Created by qdkj on 2025/6/26.
//

#import "HomeExploreToysCell.h"

@implementation HomeExploreToysCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.playBtn setTitle:LocalString(@"试听一下") forState:0];
    [self.playBtn layoutWithStyle:HKBtnImagePosition_Left space:8];
    self.storyLab.text = LocalString(@"故事");
    self.durationLab.text = LocalString(@"时长");
}

//试玩一下
- (IBAction)playBtnClick:(id)sender {
    if(self.playBlock){
        self.playBlock();
    }
}

-(void)setModel:(FindDollModel *)model{
    _model = model;
    self.nameLabel.text = model.name;
    self.introduceLabel.text = model.desc;
    [self.bgImgView sd_setImageWithURL:[NSURL URLWithString:model.backgroundImg] placeholderImage:[UIImage imageNamed:@"home_explore_toys_bg.png"]];
    self.storyNumLabel.text = [NSString stringWithFormat:@"%ld",(long)model.totalStoryNum];
    NSInteger hrs = model.totalStoryDuration / 3600;
    NSInteger mins = model.totalStoryDuration % 3600 /60;
    NSInteger s = model.totalStoryDuration % 60;
    NSString *timeStr = @"";
    if(hrs > 0){
        self.hoursLabel.text = [NSString stringWithFormat:@"%ld ",(long)hrs];
        self.minutesLabel.text = [NSString stringWithFormat:@"%ld ",(long)mins];
        self.sLabel.text = [NSString stringWithFormat:@"%ld ",(long)s];
        self.minutesLabel.hidden = self.minNameLabel.hidden = NO;
        self.horsNameLabel.text = @"h";
        self.minNameLabel.text = @"min";
        self.sNamelabel.text = @"s";
        self.sLabel.hidden = self.sNamelabel.hidden = s == 0;
    }else{
        self.sLabel.hidden = self.sNamelabel.hidden = YES;
        if(mins > 0){
            self.hoursLabel.text = [NSString stringWithFormat:@"%ld ",(long)mins];
            self.horsNameLabel.text = @"min";
            self.minutesLabel.text = [NSString stringWithFormat:@"%ld ",(long)s];
            self.minNameLabel.text = @"s";
            self.sLabel.hidden = self.sNamelabel.hidden = YES;
            self.minutesLabel.hidden = self.minNameLabel.hidden = s == 0;
            
        }else{
            self.hoursLabel.text = [NSString stringWithFormat:@"%ld ",(long)s];
            self.horsNameLabel.text = @"s";
            self.minutesLabel.hidden = self.minNameLabel.hidden = YES;
        }
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
