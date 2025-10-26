//
//  GuideOpenTopCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/29.
//

#import "GuideOpenTopCell.h"

@implementation GuideOpenTopCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setIsBluetooth:(BOOL)isBluetooth{
    _isBluetooth = isBluetooth;
    self.titleLabel.text = self.isBluetooth ? LocalString(@"建议开启蓝牙")  : LocalString(@"建议开启并配置Wi-Fi");
    self.subTitleLab.text = self.isBluetooth ? LocalString(@"部分Wi-Fi设备蓝牙开启后更容易添加") : LocalString(@"Wi-Fi设备需要开启");
    self.imgView.image = self.isBluetooth ? QD_IMG(@"guide_open_bluetooth") : QD_IMG(@"guide_open_wifi");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
