//
//  FindDeviceNoBluetoothCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import "FindDeviceNoBluetoothCell.h"

@implementation FindDeviceNoBluetoothCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setIsBluetooth:(BOOL)isBluetooth{
    _isBluetooth = isBluetooth;
    self.titleLabel.text = self.isBluetooth ? LocalString(@"打开蓝牙")  : LocalString(@"打开wifi");
    self.imgView.image = self.isBluetooth ? QD_IMG(@"icon_bluetooth_unable") : QD_IMG(@"icon_wifi_unable");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
