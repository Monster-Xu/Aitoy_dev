//
//  WiFiListTableViewCell.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/19.
//

#import "WiFiListTableViewCell.h"

@implementation WiFiListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setDateDic:(NSDictionary *)dateDic{
    _dateDic = dateDic;
}
- (IBAction)deletBtnClick:(id)sender {
    if (self.clickItemBlock) {
        self.clickItemBlock();
    }
}

@end
