//
//  AcountLoginViewController.m
//  AIToys
//
//  Created by qdkj on 2025/6/20.
//

#import "AcountLoginViewController.h"
#import "RegistViewController.h"
#import "MyTabBarController.h"
#import "UserPermmitVC.h"
#import "ATFontManager.h"
#import "NegotiateViewController.h"

@interface AcountLoginViewController ()<UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountNameLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountLabH;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UILabel *pwdNameLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwdLabH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBtnRight;

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIImageView *agreeImg;
@property (weak, nonatomic) IBOutlet UITextView *agreeTextView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgetBtn;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;

@end

@implementation AcountLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    if (kMyUser.email) {
        self.accountTextField.text = kMyUser.email;
        self.accountNameLab.hidden = NO;
        self.accountLabH.constant = 15;
    }
//    if (kMyUser.passWord) {
//        self.pwdTextField.text = kMyUser.passWord;
//        self.pwdNameLab.hidden = NO;
//        self.pwdLabH.constant = 15;
//    }
    if(self.accountTextField.text.length > 0 && self.pwdTextField.text.length > 0){
        [PublicObj makeButtonEnable:self.loginBtn];
    }else{
        [PublicObj makeButtonUnEnable:self.loginBtn];
    }
}

-(void)setUpUI{
    self.accountTextField.delegate = self;
    self.pwdTextField.delegate = self;
    self.agreeTextView.delegate =  self;
    self.titleLabel.text = NSLocalizedString(@"登录", @"");
    self.accountNameLab.text = NSLocalizedString(@"账号", @"");
    self.accountTextField.placeholder = NSLocalizedString(@"账号", @"");
    self.pwdNameLab.text = NSLocalizedString(@"密码", @"");
    self.pwdTextField.placeholder = NSLocalizedString(@"密码", @"");
    [self.loginBtn setTitle:NSLocalizedString(@"登录", @"") forState:0];
    [self.forgetBtn setTitle:NSLocalizedString(@"忘记密码", @"") forState:0];
    
    // 获取本地化的协议文本
    NSString *fullText = NSLocalizedString(@"同意隐私政策、用户协议、儿童协议、创作协议", @"");
    NSString *privacyText = NSLocalizedString(@"隐私政策", @"");
    NSString *userAgreementText = NSLocalizedString(@"用户协议", @"");
    NSString *childAgreementText = NSLocalizedString(@"儿童协议", @"");
    NSString *creativeAgreementText = NSLocalizedString(@"创作协议", @"");
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:fullText];
    [attrStr addAttribute:NSForegroundColorAttributeName
                       value:UIColorFromRGBA(000000, 0.5)
                       range:NSMakeRange(0, fullText.length)];
    
    // 设置隐私政策文本样式
    NSRange privacyRange = [fullText rangeOfString:privacyText];
    if (privacyRange.location != NSNotFound) {
        [attrStr addAttribute:NSForegroundColorAttributeName value:mainColor range:privacyRange];
        [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:privacyRange];
        [attrStr addAttribute:NSLinkAttributeName value:@"privacyPolicy://" range:privacyRange];
    }
    
    // 设置用户协议文本样式
    NSRange userAgreementRange = [fullText rangeOfString:userAgreementText];
    if (userAgreementRange.location != NSNotFound) {
        [attrStr addAttribute:NSForegroundColorAttributeName value:mainColor range:userAgreementRange];
        [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:userAgreementRange];
        [attrStr addAttribute:NSLinkAttributeName value:@"userProtocol://" range:userAgreementRange];
    }
    
    // 设置儿童协议文本样式
    NSRange childAgreementRange = [fullText rangeOfString:childAgreementText];
    if (childAgreementRange.location != NSNotFound) {
        [attrStr addAttribute:NSForegroundColorAttributeName value:mainColor range:childAgreementRange];
        [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:childAgreementRange];
        [attrStr addAttribute:NSLinkAttributeName value:@"ChildAgreement://" range:childAgreementRange];
    }
    
    // 设置创作协议文本样式
    NSRange creativeAgreementRange = [fullText rangeOfString:creativeAgreementText];
    if (creativeAgreementRange.location != NSNotFound) {
        [attrStr addAttribute:NSForegroundColorAttributeName value:mainColor range:creativeAgreementRange];
        [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:creativeAgreementRange];
        [attrStr addAttribute:NSLinkAttributeName value:@"creativeAgreement://" range:creativeAgreementRange];
    }
    
    self.agreeTextView.attributedText = attrStr;
    self.agreeTextView.editable = NO;
    self.agreeTextView.selectable = YES;
    [self setRightBtn];
    self.pwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

//设置右侧按钮
-(void)setRightBtn{
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 40, 44)];
    [rightButton setTitle:LocalString(@"注册") forState:UIControlStateNormal];
    [rightButton setTitleColor:mainColor forState:UIControlStateNormal];
    rightButton.titleLabel.font = [ATFontManager systemFontOfSize:15];
    rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [rightButton addTarget:self action:@selector(regist) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)regist{
    RegistViewController *VC = [RegistViewController new];
    VC.type = EmailType_regist;
    [self.navigationController pushViewController:VC animated:YES];
}

//查看明文密码
- (IBAction)viewPwd:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.pwdTextField.secureTextEntry = !self.pwdTextField.secureTextEntry;
}

//同意协议
- (IBAction)agreeBtnClick:(UIButton *)sender {
    self.agreeImg.highlighted = !self.agreeImg.highlighted;
}

//登录
- (IBAction)loginBtnClick:(UIButton *)sender {
    if(!self.agreeImg.highlighted){
        [MBProgressHUD showTipMessageInView:LocalString(@"请勾选协议") ];
        return;
    }
    if(![self.accountTextField.text validateForRegex:[NSString emailRegex]]) {
        //格式错误
        [MBProgressHUD showErrorMessage:LocalString(@"请输入正确的邮箱地址")];
        return;
    }
    [self showHud];
    WEAK_SELF
    [[ThingSmartUser sharedInstance] loginByEmail:Country_Code email:self.accountTextField.text password:self.pwdTextField.text success:^{
        //登录平台账号
        [weakSelf loginSaas];
    } failure:^(NSError *error) {
        [weakSelf hiddenHud];
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
    
    
}

- (void)loginSaas{
    WEAK_SELF
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    NSString *uid = [ThingSmartUser sharedInstance].uid;
    [param setObject: uid forKey:@"username"];
    [param setObject: [[uid md5String] lowercaseString] forKey:@"password"];
    [param setObject: @(1) forKey:@"autoRegister"];
    [[APIManager shared] POSTJSON:[APIPortConfiguration getLoginUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        [weakSelf hiddenHud];
//        [SVProgressHUD showSuccessWithStatus:@"Login Successfully"];

        // 埋点上报：登录成功
        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
        NSString *loginTime = [NSString stringWithFormat:@"%.0f", timestamp * 1000]; // 毫秒时间戳
        [[AnalyticsManager sharedManager] reportAccountLoginSuccessWithId:uid ?: @""
                                                                loginTime:loginTime
                                                                   region:Country_Code];

        kMyUser.email = weakSelf.accountTextField.text;
        kMyUser.passWord = weakSelf.pwdTextField.text;
        [UserInfo saveMyUser];
        //第一次启动app
        if (![[NSUserDefaults standardUserDefaults] boolForKey:KEY_ISFIRSTLAUNCH]) {
            //权限页
            UserPermmitVC *VC = [[UserPermmitVC alloc] init];
            [self.navigationController pushViewController:VC animated:YES];
        } else {
            //进入首页
            MyTabBarController *tabbar = [MyTabBarController new];
            [UIApplication sharedApplication].keyWindow.rootViewController = tabbar;
        }
        
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        [weakSelf hiddenHud];
    }];
}

//忘记密码
- (IBAction)forgetBtnClick:(UIButton *)sender {
    RegistViewController *VC = [RegistViewController new];
    VC.type = EmailType_forgetPwd;
    VC.numStr = self.accountTextField.text;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark -- UITextFieldDelegate

//账号输入改变
- (IBAction)accountTextFieldChanged:(UITextField *)sender {
    if(sender.text.length > 0){
        self.accountNameLab.hidden = NO;
        self.accountLabH.constant = 15;
        
    }else{
        self.accountNameLab.hidden = YES;
        self.accountLabH.constant = 0;
    }
}

//密码输入改变
- (IBAction)pwdTextFieldChanged:(UITextField *)sender {
    if(sender.text.length > 0){
        self.pwdNameLab.hidden = NO;
        self.pwdLabH.constant = 15;
        self.viewBtn.hidden = NO;
        
    }else{
        self.pwdNameLab.hidden = YES;
        self.pwdLabH.constant = 0;
        self.viewBtn.hidden = YES;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if([textField isEqual:self.pwdTextField]){
        self.viewBtn.hidden = textField.text.length == 0;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.viewBtn.hidden = YES;
    if(self.accountTextField.text.length > 0 && self.pwdTextField.text.length > 0) {
        [PublicObj makeButtonEnable:self.loginBtn];
    }else{
        [PublicObj makeButtonUnEnable:self.loginBtn];
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    if ([URL.scheme isEqualToString:@"privacyPolicy"]) {
        //隐私政策
        NSLog(@"点击了隐私政策");
        [self pushToNegotiateVCWithTitle:NSLocalizedString(@"隐私政策", @"") type:0];
        return NO;
        
    } else if ([URL.scheme isEqualToString:@"userProtocol"]) {
        //用户协议
        NSLog(@"点击了用户协议");
        [self pushToNegotiateVCWithTitle:NSLocalizedString(@"用户协议", @"") type:1];
        return NO;
        
    } else if ([URL.scheme isEqualToString:@"ChildAgreement"]) {
        //儿童协议
        NSLog(@"点击了儿童协议");
        [self pushToNegotiateVCWithTitle:NSLocalizedString(@"儿童协议", @"") type:2];
        return NO;
        
    } else if ([URL.scheme isEqualToString:@"creativeAgreement"]) {
        //创作协议
        NSLog(@"点击了创作协议");
        [self pushToNegotiateVCWithTitle:NSLocalizedString(@"创作协议", @"") type:3];
        return NO;
    }
    
    return YES;
}
-(void)pushToNegotiateVCWithTitle:(NSString *)title type:(NSInteger)type{
    NegotiateViewController * neVC = [[NegotiateViewController alloc]init];
    neVC.title = title;
    neVC.type  = type;
    [self.navigationController pushViewController:neVC animated:YES];
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
