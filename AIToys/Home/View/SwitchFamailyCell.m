//
//  SwitchFamailyCell.m
//  AIToys
//
//  Created by qdkj on 2025/6/26.
//

#import "SwitchFamailyCell.h"

@implementation SwitchFamailyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.statusLabel.text = LocalString(@"待加入");
    // Initialization code
}
- (void)setIsSel:(BOOL)isSel{
    _isSel = isSel;
    self.chooseImgView.highlighted = isSel;
    self.chooseImgView.hidden = !isSel;
    self.homeImgView.highlighted = isSel;
    self.nameLabel.highlighted = isSel;
}

-(void)setModel:(ThingSmartHomeModel *)model{
    _model = model;
    self.nameLabel.text = model.name;
    if(model.dealStatus == 1){
        self.statusLabel.hidden = NO;
        self.nameTrailing.constant = [LocalString(@"待加入") isEqualToString:@"待加入"] ? 78 : 133;
    }else{
        self.statusLabel.hidden = YES;
        self.nameTrailing.constant = 20;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
