//
//  DeviceFindingCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import "DeviceFindingCell.h"

@implementation DeviceFindingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: 1 * M_PI * 2.0 ];
    rotationAnimation.duration = 2;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INT_MAX;
    [self.imgView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
