//
//  SelctAvatarCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/14.
//

#import "SelctAvatarCell.h"

@implementation SelctAvatarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headImgView.layer.masksToBounds = YES;
    self.headImgView.layer.cornerRadius = self.headImgView.height * 0.5;
}

-(void)setModel:(AvatarModel *)model{
    _model = model;
    self.selectImgView.hidden = !model.isSelect;
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:model.avatarUrl]];
}

@end
