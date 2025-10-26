//
//  AccessPermissionsSettingCell.m
//  AIToys
//
//  Created by qdkj on 2025/7/17.
//

#import "AccessPermissionsSettingCell.h"

@implementation AccessPermissionsSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(MineItemModel *)model{
    _model = model;
    self.titleLabel.text = model.title;
    self.subTitleLabel.text = model.value;
    self.statusLabel.text = model.isOn ? LocalString(@"已开启"): LocalString(@"去设置");
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
