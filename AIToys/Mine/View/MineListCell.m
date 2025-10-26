//
//  MineListCell.m
//  DistributionStore
//
//  Created by 乔不赖 on 2020/7/15.
//  Copyright © 2020 OceanCodes. All rights reserved.
//

#import "MineListCell.h"

@implementation MineListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.redPointView.layer.cornerRadius = self.redPointView.width *0.5;
    _titleLabel.textColor = UIColorFromRGBA(000000, 0.7);
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
