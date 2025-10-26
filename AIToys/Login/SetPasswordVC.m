//
//  SetPasswordVC.m
//  KunQiTong
//
//  Created by 乔不赖 on 2021/8/31.
//

#import "SetPasswordVC.h"
#import "AcountLoginViewController.h"
#import "LoginViewController.h"

@interface SetPasswordVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *pwdTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwdTitleH;

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UILabel *pwsAgainTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwdAgainTitelH;
@property (weak, nonatomic) IBOutlet UIButton *view1Btn;
@property (weak, nonatomic) IBOutlet UIButton *view2Btn;

@property (weak, nonatomic) IBOutlet UITextField *pwdAgainTextField;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UIButton *surBtn;
@property (weak, nonatomic) IBOutlet UILabel *subAlertLabel;

@end

@implementation SetPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)setUpUI{
    self.pwdTextField.delegate = self;
    self.pwdAgainTextField.delegate = self;
    self.titleLabel.text = NSLocalizedString(@"设置密码", @"");
    self.pwdTitleLabel.text = NSLocalizedString(@"输入密码", @"");
    self.pwsAgainTitleLabel.text = NSLocalizedString(@"再次输入密码", @"");
    self.pwdTextField.placeholder = NSLocalizedString(@"输入密码", @"");
    self.pwdAgainTextField.placeholder = NSLocalizedString(@"再次输入密码", @"");
    self.alertLabel.text = NSLocalizedString(@"密码支持6-20位，必须包含字母和数字", @"");
    self.subAlertLabel.text = NSLocalizedString(@"密码不一致", @"");
    [self.surBtn setTitle:NSLocalizedString(@"确定", @"") forState:0];
    [PublicObj makeButtonUnEnable:self.surBtn];
}

//查看明文密码
- (IBAction)viewPwd:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.pwdTextField.secureTextEntry = !self.pwdTextField.secureTextEntry;
}

- (IBAction)viewAgainPwd:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.pwdAgainTextField.secureTextEntry = !self.pwdAgainTextField.secureTextEntry;
    
}

//确认
- (IBAction)sureBtnClick:(id)sender {
    [self.pwdAgainTextField resignFirstResponder];
    [self.pwdTextField resignFirstResponder];
    NSString *password = self.pwdTextField.text;
    WS(weakSelf);
    [[ThingSmartUser sharedInstance] registerByEmail:Country_Code email:self.numStr password:password code:self.codeStr success:^{
        [SVProgressHUD showSuccessWithStatus:@"Registered Successfully"];

        kMyUser.email = self.numStr;
        kMyUser.passWord = self.pwdTextField.text;
        ThingSmartHomeManager *homeManager = [[ThingSmartHomeManager alloc] init];
        [homeManager addHomeWithName:@"My Home" geoName:nil rooms:@[@"客厅"] latitude:0 longitude:0 success:^(long long result) {
            //跳转去一个特定的界面
           NSArray *vcsArr =  self.navigationController.viewControllers;
           NSMutableArray *vcsMutArr = [[NSMutableArray alloc]initWithArray:vcsArr];
            for (UIViewController *controller in vcsArr) {
                if ([controller isKindOfClass:[LoginViewController class]]){
                    //创建要跳转去的控制器
                    AcountLoginViewController *bankListVc = [[AcountLoginViewController alloc]init];
                    //获取查找出来的控制器index
                    NSInteger index = [vcsMutArr indexOfObject:controller];
                    //把要跳转去的控制器插入数组
                    [vcsMutArr insertObject:bankListVc atIndex:index + 1];
                    //再次给self.navigationController.viewControllers赋值
                    [weakSelf.navigationController setViewControllers:vcsMutArr];
                    //跳转去控制器
                    [weakSelf.navigationController popToViewController:bankListVc animated:YES];
                }
            }
           
        } failure:^(NSError *error) {
            [weakSelf hiddenHud];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];

    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

#pragma mark -- UITextFieldDelegate

//密码输入框改变
- (IBAction)pwdTextFieldEditChanged:(UITextField *)sender {
    if(sender.text.length > 0){
        self.pwdTitleLabel.hidden = NO;
        self.pwdTitleH.constant = 15;
        self.view1Btn.hidden = NO;
        
    }else{
        self.pwdTitleLabel.hidden = YES;
        self.pwdTitleH.constant = 0;
        self.view1Btn.hidden = YES;
    }
}

//再次确认密码
- (IBAction)againPwdTextFielsEditChanged:(UITextField *)sender {
    if(sender.text.length > 0){
        self.pwsAgainTitleLabel.hidden = NO;
        self.pwdAgainTitelH.constant = 15;
        self.view2Btn.hidden = NO;
        
    }else{
        self.pwsAgainTitleLabel.hidden = YES;
        self.pwdAgainTitelH.constant = 0;
        self.view2Btn.hidden = YES;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if([textField isEqual:self.pwdTextField]){
        self.view1Btn.hidden = textField.text.length == 0;
    }else{
        self.view2Btn.hidden = textField.text.length == 0;
    }
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *password = self.pwdTextField.text;
    NSString *confimPassword = self.pwdAgainTextField.text;
//    if(password.length == 0){
        self.view1Btn.hidden = YES;
//    }
//    if(confimPassword.length == 0){
        self.view2Btn.hidden = YES;
//    }
    if (![password isEqualToString:confimPassword]) {
        //格式错误
        self.alertLabel.hidden = YES;
        self.subAlertLabel.hidden = NO;
        self.subAlertLabel.text = NSLocalizedString(@"密码不一致", @"");
        [PublicObj makeButtonUnEnable:self.surBtn];
    }else if(![password validateForRegex:[NSString passWordRegex]]){
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
