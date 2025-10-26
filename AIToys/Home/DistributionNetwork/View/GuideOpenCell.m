//
//  GuideOpenCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/29.
//

#import "GuideOpenCell.h"

@implementation GuideOpenCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setIsBluetooth:(BOOL)isBluetooth{
    _isBluetooth = isBluetooth;
    self.nameLabel.text = self.isBluetooth ? LocalString(@"打开系统蓝牙") : LocalString(@"打开Wi-Fi开关并连接");
    self.imgView.image = self.isBluetooth ? QD_IMG(@"guide_open_bluetooth_02") : QD_IMG(@"guide_wifi_01");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
