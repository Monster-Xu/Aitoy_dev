//
//  UserEmailCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/16.
//

#import "UserEmailCell.h"

@implementation UserEmailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(MineItemModel *)model{
    _model = model;
    self.titleLabel.text = model.title;
    self.subTitleLabel.text = model.value;
    self.statusLabel.text = LocalString(@"已绑定");
    self.rightImgView.hidden = [PublicObj isEmptyObject:model.toVC];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
