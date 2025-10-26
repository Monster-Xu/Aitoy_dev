//
//  SetNewPasswordViewController.m
//  AIToys
//
//  Created by qdkj on 2025/6/20.
//

#import "SetNewPasswordViewController.h"
#import "AcountLoginViewController.h"

@interface SetNewPasswordViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;

@property (weak, nonatomic) IBOutlet UILabel *pwdTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwdTitleH;

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UIButton *surBtn;
@property (weak, nonatomic) IBOutlet UILabel *subAlertLabel;
@end

@implementation SetNewPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)setUpUI{
    self.pwdTextField.delegate = self;
    self.titleLabel.text = NSLocalizedString(@"新密码", @"");
    self.pwdTitleLabel.text = NSLocalizedString(@"密码", @"");
    self.pwdTextField.placeholder = NSLocalizedString(@"输入密码", @"");
    self.alertLabel.text = NSLocalizedString(@"密码支持6-20位，必须包含字母和数字", @"");
    self.subAlertLabel.text = NSLocalizedString(@"密码支持6-20位，必须包含字母和数字", @"");
    [self.surBtn setTitle:NSLocalizedString(@"确定", @"") forState:0];
    [PublicObj makeButtonUnEnable:self.surBtn];
}

//查看明文密码
- (IBAction)viewPwd:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.pwdTextField.secureTextEntry = !self.pwdTextField.secureTextEntry;
}

//确认
- (IBAction)sureBtnClick:(id)sender {
    [self.pwdTextField resignFirstResponder];
    NSString *password = self.pwdTextField.text;
    WS(weakSelf);
    [[ThingSmartUser sharedInstance] resetPasswordByEmail:Country_Code email:self.numStr newPassword:password code:self.codeStr success:^{
        [SVProgressHUD showSuccessWithStatus:@"Password Reset Successfully"];
        kMyUser.email = self.numStr;
        kMyUser.passWord = password;
        if(weakSelf.type == EmailType_forgetPwd){
            //跳转到指定的targetViewController
            NSArray *vcsArr =  weakSelf.navigationController.viewControllers;
            for (UIViewController *controller in vcsArr) {
                if ([controller isKindOfClass:[AcountLoginViewController class]]) {
                    [weakSelf.navigationController popToViewController:controller animated:YES];
                }
            }
        }else{
            [[ThingSmartUser sharedInstance] loginOut:^{
                [UserInfo showLogin];
            } failure:^(NSError *error) {
                NSLog(@"logOut failure: %@", error);
            }];
        }
        

    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
    
}

#pragma mark -- UITextFieldDelegate

- (IBAction)textFieldEditChanged:(UITextField *)sender {
    if(sender.text.length > 0){
        self.pwdTitleLabel.hidden = NO;
        self.pwdTitleH.constant = 15;
        self.viewBtn.hidden = NO;
        
    }else{
        self.pwdTitleLabel.hidden = YES;
        self.pwdTitleH.constant = 0;
        self.viewBtn.hidden = YES;
    }
    NSString *password = self.pwdTextField.text;
    if(![password validateForRegex:[NSString passWordRegex]]){
        self.alertLabel.hidden = YES;
        self.subAlertLabel.text = self.alertLabel.text;
        self.subAlertLabel.hidden = NO;
        [PublicObj makeButtonUnEnable:self.surBtn];
        
    }else{
        self.alertLabel.hidden = NO;
        self.subAlertLabel.hidden = YES;
        [PublicObj makeButtonEnable:self.surBtn];
    }
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.viewBtn.hidden = textField.text.length == 0;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *password = self.pwdTextField.text;
    self.viewBtn.hidden = YES;
    
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
