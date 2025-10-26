//
//  FindDeviceAlertCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import "FindDeviceAlertCell.h"
#import "UILabel+ClickIndex.h"

@implementation FindDeviceAlertCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSString *str = [NSString stringWithFormat:@"%@：%@",LocalString(@"正在搜索附近的设备，请确保设备处于"),LocalString(@"配网状态")];
    //获取要调整颜色的文字位置,调整颜色
    NSMutableAttributedString *attStr=[[NSMutableAttributedString alloc]initWithString:str];
    NSRange range=[[attStr string]rangeOfString:LocalString(@"配网状态")];
    [attStr addAttribute:NSForegroundColorAttributeName value:mainColor range:range];
    self.titleLabel.attributedText = attStr;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLabelTap:)];
    [self.titleLabel addGestureRecognizer:tapGesture];
}

- (void)handleLabelTap:(UITapGestureRecognizer *)gesture {
    WS(weakSelf);
    UILabel *label = (UILabel *)gesture.view;
    NSString *text = label.text;
    NSRange targetRange = [text rangeOfString:LocalString(@"配网状态")];
    
    CGPoint tapLocation = [gesture locationInView:label];
    CGRect textRect = [label textRectForBounds:label.bounds
                        limitedToNumberOfLines:label.numberOfLines];
    
    if (CGRectContainsPoint(textRect, tapLocation)) {
        NSUInteger index = [label characterIndexAtPoint:tapLocation];
        if (NSLocationInRange(index, targetRange)) {
            if(weakSelf.clickBlock){
                weakSelf.clickBlock();
            }
            
        }
    }
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
