//
//  FamailyNameCell.m
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import "FamailyNameCell.h"

@implementation FamailyNameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.text = LocalString(@"家庭名称");
}

-(void)setModel:(ThingSmartHomeModel *)model{
    _model = model;
    self.nameLabel.text = model.name;
    if(model.role == ThingHomeRoleType_Owner){
        self.rightImg.hidden = NO;
        self.rightImgW.constant = 24;
    }else{
        self.rightImg.hidden = YES;
        self.rightImgW.constant = 0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
