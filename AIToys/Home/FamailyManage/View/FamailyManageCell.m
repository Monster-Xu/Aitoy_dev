//
//  FamailyManageCell.m
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import "FamailyManageCell.h"

@implementation FamailyManageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.statusLabel.text = LocalString(@"待加入");
}

- (void)setRowInSection:(NSInteger)rowInSection{
    _rowInSection = rowInSection;
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
}

-(void)layoutSubviews{

    [super layoutSubviews];
    CGFloat cornerRaduis = 16.0;
    if(self.indexPath.row==0 && self.rowInSection==1) {//单组单行
        [PublicObj makeCornerToView:self.bgView withFrame:CGRectMake(0, 0, kScreenWidth-30, self.bgView.height) withRadius:cornerRaduis position:5];
        
    }else if(self.indexPath.row==0) {// 第一行
        [PublicObj makeCornerToView:self.bgView withFrame:CGRectMake(0, 0, kScreenWidth-30, self.bgView.height) withRadius:cornerRaduis position:1];
    }else if(self.indexPath.row == self.rowInSection-1) {// 最后一行

        [PublicObj makeCornerToView:self.bgView withFrame:CGRectMake(0, 0, kScreenWidth-30, self.bgView.height) withRadius:cornerRaduis position:2];

    }else{// 中间行
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, kScreenWidth-30, self.bgView.height)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.bgView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.bgView.layer.mask = maskLayer;
//        self.bgView.layer.cornerRadius = 0;
    }
}

-(void)setModel:(ThingSmartHomeModel *)model{
    _model = model;
    self.titleLabel.text = model.name;
    if(model.dealStatus == 1){
        self.statusLabel.hidden = NO;
    }else{
        self.statusLabel.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
