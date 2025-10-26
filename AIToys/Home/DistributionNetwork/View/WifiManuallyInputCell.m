//
//  WifiManuallyInputCell.m
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import "WifiManuallyInputCell.h"

@implementation WifiManuallyInputCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.text = LocalString(@"手动输入");
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
