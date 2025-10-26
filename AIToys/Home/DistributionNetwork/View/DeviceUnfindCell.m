//
//  DeviceUnfindCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import "DeviceUnfindCell.h"

@implementation DeviceUnfindCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.text = LocalString(@"未发现设备");
    self.subTitleLabel.text = LocalString(@"请选择「手动添加」按照指引复位设备，或者点击「重新扫描」重新搜索设备。");
    [self.tryBtn setTitle:LocalString(@"重新扫描") forState:0];
}

//尝试按钮
- (IBAction)tryBtnClick:(id)sender {
    if(self.tryBlock){
        self.tryBlock();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
