//
//  UserPermmitCell.m
//  AIToys
//
//  Created by qdkj on 2025/7/9.
//

#import "UserPermmitCell.h"

@implementation UserPermmitCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setModel:(MineItemModel *)model{
    _model = model;
    self.titleLabel.text = model.title;
    self.subTitleLab.text = model.value;
    self.selImgView.highlighted = model.isOn;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
