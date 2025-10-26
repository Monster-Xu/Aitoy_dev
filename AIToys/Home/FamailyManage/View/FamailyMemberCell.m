//
//  FamailyMemberCell.m
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import "FamailyMemberCell.h"

@implementation FamailyMemberCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setIsExpire:(BOOL)isExpire{
    _isExpire = isExpire;
    self.roleLabel.textColor = isExpire? UIColorHex(F04C4C):UIColorFromRGBA(000000, 0.5);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
