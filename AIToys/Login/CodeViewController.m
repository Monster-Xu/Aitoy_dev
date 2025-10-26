//
//  CodeViewController.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/18.
//

#import "CodeViewController.h"
#import "HWTextCodeView.h"
#import "QSTextCodeView.h"
#import "SetPasswordVC.h"
#import "SetNewPasswordViewController.h"
#import "UILabel+RichText.h"
#import "AccountSecurityVC.h"
#import "UnReceiveCodeView.h"

@interface CodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *codeView;
@property (weak, nonatomic) IBOutlet UIButton *unReceiveBtn;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

@property (nonatomic, strong) QSTextCodeView *textView;
@property (nonatomic, copy) NSString *codeStr;
@end

@implementation CodeViewController

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = NSLocalizedString(@"输入验证码", @"");
    self.alertLabel.text = NSLocalizedString(@"验证码有误", @"");
    self.textView = [[QSTextCodeView alloc] initWithFrame:CGRectMake(0, 0, self.codeView.width, 45)];
    self.textView.fieldCount = 6;
    WS(weakSelf);
    self.textView.resultBlock = ^(NSString * _Nonnull str, NSDictionary * _Nonnull dic, BOOL isOK) {
        NSLog(@"输入框文字 = %@",str);
        weakSelf.alertLabel.hidden = YES;
        if([weakSelf.codeStr isEqualToString:str]){
            return;
        }
        weakSelf.codeStr = str;
        if(isOK){
            if (weakSelf.codeStr.length < 6) {
                [SVProgressHUD showErrorWithStatus:@"请输入6位验证码"];
                return;
            }
            NSInteger codeType = 1;
            if(self.type == EmailType_regist){
                codeType = 1;
            }else if (self.type == EmailType_forgetPwd || self.type == EmailType_modifyPwd){
                codeType = 3;
            }else if (self.type == EmailType_change){
                codeType = 7;
            }
//            if (self.type == EmailType_change){
//                
//            }else{
                [[ThingSmartUser sharedInstance] checkCodeWithUserName:weakSelf.numStr region:[[ThingSmartUser sharedInstance] getDefaultRegionWithCountryCode:Country_Code] countryCode:Country_Code code:weakSelf.codeStr type:codeType success:^(BOOL result) {
                    if (result) {
                        if(weakSelf.type == EmailType_forgetPwd || weakSelf.type == EmailType_modifyPwd){
                            SetNewPasswordViewController *VC = [SetNewPasswordViewController new];
                            VC.numStr = weakSelf.numStr;
                            VC.codeStr = weakSelf.codeStr;
                            VC.type = weakSelf.type;
                            [weakSelf.navigationController pushViewController:VC animated:YES];
                        }else if(weakSelf.type == EmailType_regist){
                            //设置密码
                            SetPasswordVC *VC = [SetPasswordVC new];
                            VC.numStr = weakSelf.numStr;
                            VC.codeStr = weakSelf.codeStr;
                            [weakSelf.navigationController pushViewController:VC animated:YES];
                        }else {
                            [[ThingSmartUser sharedInstance] changBindAccount:weakSelf.numStr countryCode:Country_Code code:weakSelf.codeStr success:^{
                                kMyUser.email = weakSelf.numStr;
                                [SVProgressHUD showSuccessWithStatus:LocalString(@"邮箱已修改")];
                                //跳转到指定的targetViewController
                                NSArray *vcsArr =  weakSelf.navigationController.viewControllers;
                                for (UIViewController *controller in vcsArr) {
                                    if ([controller isKindOfClass:[AccountSecurityVC class]]) {
                                        [weakSelf.navigationController popToViewController:controller animated:YES];
                                    }
                                }
                            } failure:^(NSError *error) {
                                weakSelf.alertLabel.text = error.description;
                                weakSelf.alertLabel.hidden = NO;
                                [SVProgressHUD showErrorWithStatus:error.description];
                            }];
                        }
                    } else {
                        weakSelf.alertLabel.text = LocalString(@"验证码有误");
                        weakSelf.alertLabel.hidden = NO;
//                        [SVProgressHUD showErrorWithStatus:LocalString(@"验证码有误")];
                    }
                } failure:^(NSError *error) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    
                }];
            }
//        }
        
    };
    [self.codeView addSubview:self.textView];
    [self.textView becomeFirstResponder];
    [self setCountDown];
    [self.unReceiveBtn setTitle:NSLocalizedString(@"收不到验证码?", @"") forState:0];
    NSString *str = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"验证码已发送到您的邮箱", @""),self.numStr];
    NSMutableAttributedString *attStr=[[NSMutableAttributedString alloc]initWithString:str];
    self.subTitleLabel.attributedText = attStr;
}

//验证码倒计时
- (void)setCountDown{
    WEAK_SELF
    __block int timeValue = 60;
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 block:^(NSTimer * _Nonnull timer) {
        
        if (timeValue > 0) {
            NSString *str = [NSString stringWithFormat:@"%@：%@，%@（%ds）",NSLocalizedString(@"验证码已发送到您的邮箱", @""),self.numStr,NSLocalizedString(@"重新发送", @""),timeValue--];
            NSMutableAttributedString *attStr=[[NSMutableAttributedString alloc]initWithString:str];
            weakSelf.subTitleLabel.attributedText = attStr;
            weakSelf.subTitleLabel.enabledClickEffect = NO;
        }else if (timeValue == 0){
            [timer invalidate];
            timeValue = 60;
            NSString *str = [NSString stringWithFormat:@"%@：%@，%@     ",NSLocalizedString(@"验证码已发送到您的邮箱", @""),self.numStr,NSLocalizedString(@"重新发送", @"")];
            //获取要调整颜色的文字位置,调整颜色
            NSMutableAttributedString *attStr=[[NSMutableAttributedString alloc]initWithString:str];
            NSRange range=[[attStr string]rangeOfString:NSLocalizedString(@"重新发送", @"")];
            [attStr addAttribute:NSForegroundColorAttributeName value:mainColor range:range];
            weakSelf.subTitleLabel.attributedText = attStr;
            // 确保label可以响应手势
            weakSelf.subTitleLabel.enabledClickEffect = YES;
            [weakSelf.subTitleLabel clickRichTextWithStrings:@[NSLocalizedString(@"重新发送", @"")] clickAction:^(NSString *string, NSRange range, NSInteger index) {
                weakSelf.subTitleLabel.enabledClickEffect = NO;
                [weakSelf sendCode];
            }];
        }
    } repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
}

//发送验证码
- (IBAction)sentBtnClick:(id)sender {
    [self sendCode];
}

-(void)sendCode{
    WS(weakSelf);
    NSInteger codeType = 1;
    if(self.type == EmailType_regist){
        codeType = 1;
    }else if (self.type == EmailType_forgetPwd || self.type == EmailType_modifyPwd){
        codeType = 3;
    }else if (self.type == EmailType_change){
        codeType = 7;
    }
    [[ThingSmartUser sharedInstance] sendVerifyCodeWithUserName:self.numStr region:[[ThingSmartUser sharedInstance] getDefaultRegionWithCountryCode:Country_Code] countryCode:Country_Code type: codeType success:^{
        [SVProgressHUD showSuccessWithStatus:@"Verification Code Sent Successfully"];
        [weakSelf setCountDown];
    } failure:^(NSError *error) {
        // 确保label可以响应手势
        weakSelf.subTitleLabel.enabledClickEffect = YES;
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

//未收到验证码
- (IBAction)unReceiveBtnClick:(id)sender {
    [self.view endEditing:YES];
    UnReceiveCodeView *view = [[UnReceiveCodeView alloc] initWithFrame:[UIScreen mainScreen].bounds];
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
