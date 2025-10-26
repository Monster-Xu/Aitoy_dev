//
//  SettingCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/13.
//

#import "SettingCell.h"

@implementation SettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)layoutSubviews{

    [super layoutSubviews];
    
    CGFloat cornerRaduis = 16.0;
    if(self.indexPath.row==0 && self.rowInSection==1) {//单组单行
        self.bgView.layer.cornerRadius = cornerRaduis;
        
    }else if(self.indexPath.row==0) {// 第一行
        [PublicObj makeCornerToView:self.bgView withFrame:CGRectMake(0, 0, kScreenWidth-30, self.bgView.height) withRadius:cornerRaduis position:1];
    }else if(self.indexPath.row == self.rowInSection-1) {// 最后一行

        [PublicObj makeCornerToView:self.bgView withFrame:CGRectMake(0, 0, kScreenWidth-30, self.bgView.height) withRadius:cornerRaduis position:2];

    }else{// 中间行
        
    }

}

-(void)setModel:(MineItemModel *)model{
    _model = model;
    self.titleLabel.text = model.title;
    self.subTitleLabel.text = model.value;
    self.rightImgView.hidden = [PublicObj isEmptyObject:model.toVC];
    self.rightImgW.constant = [PublicObj isEmptyObject:model.toVC] ? 0 : 24;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
