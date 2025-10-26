//
//  FamailyMemeberAvatarCell.m
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import "FamailyMemeberAvatarCell.h"

@implementation FamailyMemeberAvatarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.text = LocalString(@"头像");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
