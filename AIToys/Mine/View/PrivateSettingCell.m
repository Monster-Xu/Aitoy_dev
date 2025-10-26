//
//  PrivateSettingCell.m
//  AIToys
//
//  Created by qdkj on 2025/7/17.
//

#import "PrivateSettingCell.h"

@implementation PrivateSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setModel:(MineItemModel *)model{
    _model = model;
    self.titleLabel.text = model.title;
    CGSize labSize = QDSize(model.title,self.titleLabel.font,CGSizeMake(kScreenWidth-140, MAXFLOAT));
    self.titleLabH.constant = labSize.height > 20 ? 40 : 20;
    self.subTitleLabel.text = model.value;
    self.switchView.on = model.isOn;
}

- (IBAction)switchChanged:(UISwitch *)sender {
    if (self.switchChangeBlock) {
        self.switchChangeBlock(sender.on);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
