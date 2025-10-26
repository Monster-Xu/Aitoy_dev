//
//  SelectWifCell.m
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import "SelectWifCell.h"

@implementation SelectWifCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    self.titleLabel.text = dic[@"ssid"];
    self.isPwdImgView.hidden = [dic[@"sec"] intValue] == 0;
    NSInteger rssi = [dic[@"rssi"] intValue];
    if(rssi > -50){
        //信号极强
        self.wifiImgView.image = QD_IMG(@"ic_wifi4");
    }else if (rssi > -65){
        //信号强
        self.wifiImgView.image = QD_IMG(@"ic_wifi3");
    }
    else if (rssi > -75){
        //信号中
        self.wifiImgView.image = QD_IMG(@"ic_wifi2");
    }
    else if (rssi > -85){
        //信号弱
        self.wifiImgView.image = QD_IMG(@"ic_wifi1");
    }else{
        //信号极弱
        self.wifiImgView.image = QD_IMG(@"ic_wifi0");
    }
}

@end
