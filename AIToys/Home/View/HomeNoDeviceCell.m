//
//  HomeNoDeviceCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/21.
//

#import "HomeNoDeviceCell.h"

@implementation HomeNoDeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

-(void)setType:(CellType)type{
    if(type == CellTypeDevice){
        self.imgView.image = QD_IMG(@"device_empty");
        self.nameLabel.text = NSLocalizedString(@"还没有故事机，快添加一个吧！", @"");
        [self.addBtn setTitle:NSLocalizedString(@"添加故事机", @"") forState:0];
    }else{
        self.imgView.image = QD_IMG(@"toys_empty");
        self.nameLabel.text = NSLocalizedString(@"还没有公仔，快添加一个吧！", @"");
        [self.addBtn setTitle:NSLocalizedString(@"添加公仔", @"") forState:0];
    }
}

//添加故事机/公仔
- (IBAction)addBtnClick:(id)sender {
    if(self.addBtnClickBlock){
        self.addBtnClickBlock();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
