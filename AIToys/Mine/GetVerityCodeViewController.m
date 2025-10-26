//
//  GetVerityCodeViewController.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/16.
//

#import "GetVerityCodeViewController.h"
#import "CodeViewController.h"

@interface GetVerityCodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UIButton *surBtn;
@end

@implementation GetVerityCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = LocalString(@"账号验证");
    self.alertLabel.text = [NSString stringWithFormat:@"%@%@",LocalString(@"点击获取验证码，验证码将会发送到你的邮箱："),[ThingSmartUser sharedInstance].email];
    [self.surBtn setTitle:NSLocalizedString(@"获取验证码", @"") forState:0];
}

//获取验证码
- (IBAction)sureBtnClick:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    WS(weakSelf);
    [[ThingSmartUser sharedInstance] sendVerifyCodeWithUserName:[ThingSmartUser sharedInstance].email region:[[ThingSmartUser sharedInstance] getDefaultRegionWithCountryCode:Country_Code] countryCode:Country_Code type:3 success:^{
        sender.userInteractionEnabled = YES;
        [SVProgressHUD showSuccessWithStatus:@"Verification Code Sent Successfully"];
        CodeViewController *VC = [CodeViewController new];
        VC.numStr = [ThingSmartUser sharedInstance].email;
        VC.type = EmailType_modifyPwd;
        [weakSelf.navigationController pushViewController:VC animated:YES];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
