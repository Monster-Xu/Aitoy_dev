//
//  ComponentLicenseCell.m
//  AIToys
//
//  Created by qdkj on 2025/7/18.
//

#import "ComponentLicenseCell.h"

@implementation ComponentLicenseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setRow:(NSInteger)row{
    _row = row;
    self.bgView.backgroundColor = row % 2 == 0 ? UIColorHex(0xEEEEEE) : tableBgColor;
}

-(void)setModel:(ComponentLicenseModel *)model{
    _model = model;
    
    // 下划线
    NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr1 = [[NSMutableAttributedString alloc]initWithString:model.name attributes:attribtDic];
    self.nameLabel.attributedText = attribtStr1;
    
    self.versionLabel.text = model.version;
    
    NSMutableAttributedString *attribtStr2 = [[NSMutableAttributedString alloc]initWithString:model.licence attributes:attribtDic];
    self.licenceLabel.attributedText = attribtStr2;
    self.statusLabel.text = model.modify;
}


- (IBAction)compentAddressBtn:(UIButton *)sender {
    if(self.clickItemBlock){
        self.clickItemBlock(sender.tag);
    }
}

- (IBAction)licenceBtnClick:(UIButton *)sender {
    if(self.clickItemBlock){
        self.clickItemBlock(sender.tag);
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
