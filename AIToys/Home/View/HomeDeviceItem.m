//
//  HomeDeviceItem.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/21.
//

#import "HomeDeviceItem.h"

@implementation HomeDeviceItem

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setIndex:(NSInteger)index{
    _index = index;
    NSArray *bgColorArr = @[UIColorHex(e4f2fe),UIColorHex(faf6e4),UIColorHex(f8e9dd),UIColorHex(ede7fc),UIColorHex(daeeec),UIColorHex(fce7f8),UIColorHex(f9dede),UIColorHex(daf2f9),UIColorHex(dce2f7),UIColorHex(e6f8e9)];
    self.bgView.backgroundColor = bgColorArr[index % 10];
    self.rankLabel.text = [NSString stringWithFormat:@"%li",index + 1];
}

-(void)setIsEdit:(BOOL)isEdit{
    _isEdit = isEdit;
    [self starAnimation:isEdit];
    if(isEdit){
        self.rankView.hidden = YES;
        self.chooseImgView.hidden = NO;
        self.nameLabelTrail.constant = 40;
    }else{
        self.rankView.hidden = NO;
        self.chooseImgView.hidden = YES;
        self.nameLabelTrail.constant = 12;
    }
}

-(void)setIsSel:(BOOL)isSel{
    _isSel = isSel;
    if(isSel){
        self.chooseImgView.highlighted = YES;
    }else{
        self.chooseImgView.highlighted = NO;
    }
}

-(void)setModel:(ThingSmartDeviceModel *)model{
    _model = model;
    self.nameLabel.text = model.name;
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.iconUrl]];
    self.onlineImgview.image = model.isOnline ? [UIImage imageNamed:@"icon_online"] : [UIImage imageNamed:@"icon_offline"];
    self.onlineLabel.text = model.isOnline ? LocalString(@"在线"):LocalString(@"离线");
    self.batteryView.hidden = !model.isOnline;
    if(![PublicObj isEmptyObject:model.dps]){
        NSString *charging = model.dps[@"4"];
        NSInteger batterryValue =  [model.dps[@"128"] intValue];
        if(![PublicObj isEmptyObject:charging]){
            //需求更改，不显示电量文字
            self.batteryLabel.hidden = YES;
            if([charging isEqualToString:@"charging"]){
                self.batteryImgView.image = QD_IMG(@"charging");
                self.batteryLabel.text = LocalString(@"充电中");
            }else if ([charging isEqualToString:@"charge_done"]){
                self.batteryImgView.image = QD_IMG(@"charg_done");
                self.batteryLabel.text = LocalString(@"已充满");
            }else if ([charging isEqualToString:@"none"]){
                self.batteryLabel.hidden = YES;
                //batterryValue
                if(batterryValue == 0){
                    self.batteryImgView.image = QD_IMG(@"icon_battery_empty");
                }else if (batterryValue == 1){
                    self.batteryImgView.image = QD_IMG(@"icon_battery_red");
                }else if (batterryValue == 2){
                    self.batteryImgView.image = QD_IMG(@"icon_battery_yellow_1");
                }else if (batterryValue == 3){
                    self.batteryImgView.image = QD_IMG(@"icon_battery_yellow_2");
                }else if (batterryValue == 4){
                    self.batteryImgView.image = QD_IMG(@"icon_battery_yellow_3");
                }else {
                    self.batteryImgView.image = QD_IMG(@"icon_battery_green");
                }
            }
        }
    }
    
}

-(void)starAnimation:(BOOL)animaiton
{
    if (animaiton) {
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //抖动的话添加一个旋转角度给他就好
        basicAnimation.fromValue = @(-M_PI_4/30);
        basicAnimation.toValue = @(M_PI_4/30);
        basicAnimation.duration = 0.15;
        basicAnimation.repeatCount = MAXFLOAT;
        basicAnimation.autoreverses = YES;
        [self.layer addAnimation:basicAnimation forKey:[NSString stringWithFormat:@"%li",(long)index + 1]];

    }else{
        [self.layer removeAllAnimations];
    }
    
}

@end
