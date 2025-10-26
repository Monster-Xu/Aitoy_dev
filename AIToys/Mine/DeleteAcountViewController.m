//
//  DeleteAcountViewController.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/17.
//

#import "DeleteAcountViewController.h"
#import "DateUtil.h"

@interface DeleteAcountViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLab1;
@property (weak, nonatomic) IBOutlet UILabel *titleLab2;
@property (weak, nonatomic) IBOutlet UILabel *titleLab3;
@property (weak, nonatomic) IBOutlet UILabel *titleLab4;
@property (weak, nonatomic) IBOutlet UILabel *titleLab5;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;

@end

@implementation DeleteAcountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLab1.text = LocalString(@"尊敬的用户");
    self.titleLab2.text = LocalString(@"如果您确定提交\"注销账号\"申请，账号注销于");
    self.titleLab3.text = LocalString(@"鉴于此，我们将删除您账户中的个人数据");
    self.titleLab4.text = LocalString(@"如撤销\"注销账号\"申请，请在上述时间前登录应用程序即可撤销");
    self.titleLab5.text = LocalString(@"感谢您的使用");
    [PublicObj makeButtonUnEnable:self.continueBtn];
    [self.continueBtn setTitle:[NSString stringWithFormat:LocalString(@"继续（%d）"), 5] forState:0];
    [self setCountDown];
    
    NSDate *currentDate = [NSDate date];
    int days = 8;    // n天后的天数
    NSDate *appointDate;    // 指定日期声明
    NSTimeInterval oneDay = 24 * 60 * 60;  // 一天一共有多少秒
    appointDate = [currentDate initWithTimeIntervalSinceNow: oneDay * days];
    self.timeLab.text = [NSString stringWithFormat:@"%@ 00:00:00",[DateUtil stringFromDate:appointDate Formater:@"yyyy-MM-dd"]];
}

//倒计时
- (void)setCountDown{
    __block int timeValue = 5;
    WEAK_SELF
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 block:^(NSTimer * _Nonnull timer) {
        
        if (timeValue > 0) {
            NSString *str = [NSString stringWithFormat:LocalString(@"继续（%d）"), timeValue--];
            [self.continueBtn setTitle:str forState:0];
        }else if (timeValue == 0){
            [timer invalidate];
            timeValue = 60;
            [PublicObj makeButtonEnable:weakSelf.continueBtn];
            [self.continueBtn setTitle:LocalString(@"继续") forState:0];
        }
    } repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
}

//继续
- (IBAction)continueBtnClick:(id)sender {
    WEAK_SELF
    [LGBaseAlertView showAlertWithTitle:LocalString(@"确定要注销账号吗?") content:LocalString(@"注销后，此账户下的所有用户数据也将被永久删除") cancelBtnStr:LocalString(@"取消") confirmBtnStr:LocalString(@"确定") confirmBlock:^(BOOL isValue, id obj) {
        if (isValue){
            [[ThingSmartUser sharedInstance] cancelAccount:^{
                NSLog(@"cancel account success");
                [UserInfo clearMyUser];
                [CoreArchive removeStrForKey:KCURRENT_HOME_ID];
                [CoreArchive setBool:YES key:KACCOUNT_ISCANCEL];
                [UserInfo showLogin];
            } failure:^(NSError *error) {
                NSLog(@"cancel account failure: %@", error);
            }];
        }
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
