//
//  RegistViewController.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/18.
//

#import "RegistViewController.h"
#import "CodeViewController.h"
#import "AcountLoginViewController.h"
#import "LoginViewController.h"
#import "SelectBirthdayView.h"

@interface RegistViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *acountTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountTitleH;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UILabel *dateTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *dateTextfield;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateTitleH;
@property (weak, nonatomic) IBOutlet UIButton *sendCodeBtn;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertTop;
@property (nonatomic, assign) BOOL isEnableYear;
@property (nonatomic, strong)NSDate *selectDate;

@end

@implementation RegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

-(void)setUpUI{
    self.textField.delegate = self;
    if(self.type == EmailType_regist){
        self.titleLabel.text = NSLocalizedString(@"注册", @"");
        self.dateView.hidden = NO;
        self.btnTop.constant = 130;
        self.alertTop.constant = 87;
    }else {
        self.dateView.hidden = YES;
        self.btnTop.constant = 70;
        self.alertTop.constant = 8;
        if (self.type == EmailType_regist){
            self.titleLabel.text =  NSLocalizedString(@"忘记密码", @"");
        }else{
            self.titleLabel.text =  NSLocalizedString(@"更换邮箱", @"");
        }
    }
    self.acountTitleLabel.text = NSLocalizedString(@"账号", @"");
    self.textField.placeholder = NSLocalizedString(@"账号", @"");
    self.dateTitleLabel.text = NSLocalizedString(@"出生日期", @"");
    self.dateTextfield.placeholder = NSLocalizedString(@"出生日期", @"");
    self.alertLabel.text = NSLocalizedString(@"请输入正确的邮箱地址", @"");
    [self.sendCodeBtn setTitle:NSLocalizedString(@"获取验证码", @"") forState:0];
    [PublicObj makeButtonUnEnable:self.sendCodeBtn];
    if(self.numStr.length>0){
        self.textField.text = self.numStr;
        self.acountTitleLabel.hidden = NO;
        self.accountTitleH.constant = 15;
        [self checkEmail];
    }
}

- (IBAction)sendCodeBtnClcik:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    NSInteger codeType = 1;
    if(self.type == EmailType_regist){
        codeType = 1;
    }else if (self.type == EmailType_forgetPwd || self.type == EmailType_modifyPwd){
        codeType = 3;
    }else if (self.type == EmailType_change){
        codeType = 7;
    }
    WS(weakSelf);
    [[ThingSmartUser sharedInstance] sendVerifyCodeWithUserName:self.textField.text region:[[ThingSmartUser sharedInstance] getDefaultRegionWithCountryCode:Country_Code] countryCode:Country_Code type:codeType success:^{
        [SVProgressHUD showSuccessWithStatus:@"Verification Code Sent Successfully"];
        sender.userInteractionEnabled = YES;
        CodeViewController *VC = [CodeViewController new];
        VC.numStr = weakSelf.textField.text;
        VC.type = weakSelf.type;
        [weakSelf.navigationController pushViewController:VC animated:YES];
    } failure:^(NSError *error) {
        sender.userInteractionEnabled = YES;
        if(error.code == 1506){
            if(weakSelf.type == EmailType_regist){
                WEAK_SELF
                [LGBaseAlertView showAlertWithTitle:@"" content:LocalString(@"账号已存在，是否立即登录?") cancelBtnStr:LocalString(@"取消") confirmBtnStr:LocalString(@"确定") confirmBlock:^(BOOL isValue, id obj) {
                    if (isValue){
                        kMyUser.email = weakSelf.textField.text;
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
                    }
                }];
            }else{
                [SVProgressHUD showErrorWithStatus:@"该邮箱已被占用，请重新输入"];
            }
            
        }else{
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

#pragma mark -- UITextFieldDelegate

- (IBAction)textFieldEditChanged:(UITextField *)sender {
    if(sender.text.length > 0){
        self.acountTitleLabel.hidden = NO;
        self.accountTitleH.constant = 15;
        [self checkEmail];
    }else{
        self.acountTitleLabel.hidden = YES;
        self.accountTitleH.constant = 0;
    }
}

- (IBAction)dateTextfieldEditChange:(UITextField *)sender {
    if(sender.text.length > 0){
        self.dateTitleLabel.hidden = NO;
        self.dateTitleH.constant = 15;
    }else{
        self.dateTitleLabel.hidden = YES;
        self.dateTitleH.constant = 0;
    }
}


- (void)checkEmail{
    if(![self.textField.text validateForRegex:[NSString emailRegex]]) {
        //格式错误
        self.alertLabel.text = NSLocalizedString(@"请输入正确的邮箱地址", @"");
        self.alertLabel.hidden = NO;
        [PublicObj makeButtonUnEnable:self.sendCodeBtn];
    }else {
        if(self.type == EmailType_regist){
            if(!self.isEnableYear){
                self.alertLabel.hidden = NO;
                self.alertLabel.text = NSLocalizedString(@"抱歉，您还未到允许注册的年龄", @"");
                [PublicObj makeButtonUnEnable:self.sendCodeBtn];
            }else{
                self.alertLabel.hidden = YES;
                [PublicObj makeButtonEnable:self.sendCodeBtn];
            }
        }else{
            self.alertLabel.hidden = YES;
            [PublicObj makeButtonEnable:self.sendCodeBtn];
        }
        
    }
}

//选择出生日期
- (IBAction)selectDateBtnClick:(id)sender {
    [self.view endEditing:YES];
    SelectBirthdayView *view = [[SelectBirthdayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = -18;
    NSDate *miniDate = [calendar dateByAddingComponents:components toDate:currentDate options:0];
    view.defalutDate = self.selectDate ? :[NSDate date];
    WEAK_SELF
    view.confirmBlock = ^(NSString * _Nonnull str, NSDate * _Nonnull selectDate) {
        weakSelf.dateTextfield.text =  str;
        weakSelf.selectDate = selectDate;
        NSComparisonResult result = [miniDate compare:selectDate];
        if(result == NSOrderedDescending){
            //大于18岁
            weakSelf.isEnableYear = YES;
        }else{
            weakSelf.isEnableYear = NO;
        }
        [weakSelf checkEmail];
    };
    [view show];
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
