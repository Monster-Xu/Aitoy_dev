//
//  MineAvatarCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/14.
//

#import "MineAvatarCell.h"

@implementation MineAvatarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [PublicObj makeCornerToView:self.bgView withFrame:CGRectMake(0, 0, kScreenWidth-30, self.bgView.height) withRadius:16 position:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
