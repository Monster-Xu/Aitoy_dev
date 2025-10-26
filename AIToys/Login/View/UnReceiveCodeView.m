//
//  UnReceiveCodeView.m
//  AIToys
//
//  Created by qdkj on 2025/8/12.
//

#import "UnReceiveCodeView.h"

@interface UnReceiveCodeView()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation UnReceiveCodeView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle]loadNibNamed:@"UnReceiveCodeView" owner:nil options:nil]objectAtIndex:0];
        self.frame = frame;
        self.titleLabel.text = LocalString(@"收不到验证码?");
        self.subTitleLabel.text = LocalString(@"如果没有收到手机验证码，建议您进行以下操作:");
        self.contentLabel.text = LocalString(@"1.请您检查电子邮箱地址是否正确。\n2.请您检查电子邮件不在垃圾邮件中。\n3.如果你找不到电子邮件，它可能会被防火墙阻止。请使用兼容性更好的电子邮件。\n4.如果您仍然无法获得代码，请联系我们的客服并提供帐户名。");
        
    }
    return self;
}

//确定
- (IBAction)sureBtnClick:(id)sender {
    [self hide];
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
