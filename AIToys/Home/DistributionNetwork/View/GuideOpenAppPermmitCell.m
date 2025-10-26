//
//  GuideOpenAppPermmitCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/29.
//

#import "GuideOpenAppPermmitCell.h"

@implementation GuideOpenAppPermmitCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.text = LocalString(@"允许本应用的“蓝牙”权限");
    [self.settingBtn setTitle:LocalString(@"去设置 >") forState:0];
}

//设置
- (IBAction)settingBtnClick:(id)sender {
    if(self.clickBlock){
        self.clickBlock();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
