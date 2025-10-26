//
//  ExitView.m
//  www
//
//  Created by 乔不赖 on 2020/7/18.
//  Copyright © 2020 zhongchi. All rights reserved.
//

#import "ExitView.h"

@interface ExitView()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UIButton *exitBtn;

@end
@implementation ExitView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle]loadNibNamed:@"ExitView" owner:nil options:nil]objectAtIndex:0];
        self.frame = frame;
        self.titleLabel.text = LocalString(@"还有设备待添加，是否退出?");
        [self.exitBtn setTitle:LocalString(@"仍然退出") forState:0];
        [self.continueBtn setTitle:LocalString(@"继续添加") forState:0];
    }
    return self;
    
}

//继续添加
- (IBAction)sureBtnClick:(id)sender {
    [self hide];
}

//退出
- (IBAction)cancelBtnclick:(id)sender {
    [self hide];
    if (self.sureBlock) {
        self.sureBlock();
    }
}

-(void)show
{
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
}

- (void)hide
{
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
