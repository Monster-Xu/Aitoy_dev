//
//  ChangeEmailViewController.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/16.
//

#import "ChangeEmailViewController.h"
#import "RegistViewController.h"

@interface ChangeEmailViewController ()
<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;

@property (weak, nonatomic) IBOutlet UILabel *pwdTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwdTitleH;

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UIButton *surBtn;
@end

@implementation ChangeEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

-(void)setUpUI{
    self.pwdTextField.delegate = self;
    self.titleLabel.text = NSLocalizedString(@"更换邮箱", @"");
    self.pwdTitleLabel.text = NSLocalizedString(@"密码", @"");
    self.pwdTextField.placeholder = LocalString(@"密码", @"");
    self.alertLabel.text = [NSString stringWithFormat:@"%@%@%@",LocalString(@"The current Email  is"),[ThingSmartUser sharedInstance].email,LocalString(@"please enter your password to continue")];
    
    [self.surBtn setTitle:NSLocalizedString(@"确定", @"") forState:0];
    [PublicObj makeButtonUnEnable:self.surBtn];
}

//查看明文密码
- (IBAction)viewPwd:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.pwdTextField.secureTextEntry = !self.pwdTextField.secureTextEntry;
}

//下一步
- (IBAction)sureBtnClick:(id)sender {
    [self.pwdTextField resignFirstResponder];
    NSString *password = self.pwdTextField.text;
    WS(weakSelf);
//    [[ThingSmartUser sharedInstance] resetPasswordByEmail:Country_Code email:self.numStr newPassword:password code:self.codeStr success:^{
//        [SVProgressHUD showSuccessWithStatus:@"Password Reset Successfully"];
//        kMyUser.passWord = password;
//        //跳转到指定的targetViewController
//        NSArray *vcsArr =  weakSelf.navigationController.viewControllers;
//        for (UIViewController *controller in vcsArr) {
//            if ([controller isKindOfClass:[AcountLoginViewController class]]) {
//                [weakSelf.navigationController popToViewController:controller animated:YES];
//            }
//        }
//
//    } failure:^(NSError *error) {
//        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
//    }];
    if(![kMyUser.passWord isEqualToString:password]){
        [SVProgressHUD showErrorWithStatus:LocalString(@"密码错误")];
        return;
    }
    RegistViewController *VC = [RegistViewController new];
    VC.type = EmailType_change;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark -- UITextFieldDelegate

- (IBAction)textFieldEditChanged:(UITextField *)sender {
    if(sender.text.length > 0){
        self.pwdTitleLabel.hidden = NO;
        self.pwdTitleH.constant = 15;
        self.viewBtn.hidden = NO;
        [PublicObj makeButtonEnable:self.surBtn];
    }else{
        self.pwdTitleLabel.hidden = YES;
        self.pwdTitleH.constant = 0;
        self.viewBtn.hidden = YES;
        [PublicObj makeButtonUnEnable:self.surBtn];
    }
}


//-(void)textFieldDidEndEditing:(UITextField *)textField{
//    NSString *password = self.pwdTextField.text;
//    if(password.length == 0){
//        self.viewBtn.hidden = YES;
//    }
//    if([PublicObj isEmptyObject:password]){
//        
//        [PublicObj makeButtonUnEnable:self.surBtn];
//        
//    }else{
//        [PublicObj makeButtonEnable:self.surBtn];
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
