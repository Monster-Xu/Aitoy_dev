//
//  DeviceHavenFindItem.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import "DeviceHavenFindItem.h"

@implementation DeviceHavenFindItem

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)addDeviceBtnClick:(id)sender {
    if (self.clickItemBlock) {
        self.clickItemBlock();
    }
    
}



@end
