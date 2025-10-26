//
//  ConnectWifiVC.m
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import "ConnectWifiVC.h"
#import "DeviceAddCell.h"
#import "DeviceConnectingVC.h"

@interface ConnectWifiVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *settingAlertLab;

//@property (nonatomic, strong) NSString *token;
//@property (nonatomic, assign) BOOL ispwdError;//是否是wifi密码错误
//@property (nonatomic, assign)AddStatusType status;
@end

@implementation ConnectWifiVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.ssid){
        self.nameTextField.text = self.ssid;
    }
    self.fd_prefersNavigationBarHidden = YES;
    [PublicObj makeButtonUnEnable:self.nextBtn];
    self.titleLabel.text = LocalString(@"请选择2.4Ghz的Wi-Fi，并输入密码");
    self.subTitleLabel.text = LocalString(@"如果你的Wi-Fi是5G的，请选择一个2.4G的Wi-Fi");
    self.settingAlertLab.text = LocalString(@"常见路由器设置方法");
    self.nameTextField.placeholder = LocalString(@"Wi-Fi名称");
    self.pwdTextField.placeholder = LocalString(@"Wi-Fi密码");
//    [self getToken];
//    [ThingSmartBLEWifiActivator sharedInstance].bleWifiDelegate = self;
}

//-(void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    [self hiddenHud];
//}

//- (void)getToken {
//    WEAK_SELF
//    ThingSmartActivator *ezActivator = [[ThingSmartActivator alloc] init];
//    [ezActivator getTokenWithHomeId:self.homeId success:^(NSString *token) {
//        NSLog(@"getToken success: %@", token);
//        weakSelf.token = token;
//    } failure:^(NSError *error) {
//        NSLog(@"getToken failure: %@", error.localizedDescription);
//    }];
//}

//常见路由器设置
- (IBAction)settingBtnclick:(id)sender {
    
}

- (IBAction)closeBtnClick:(id)sender {
//    //在配网结束后调用
//    [[ThingSmartBLEWifiActivator sharedInstance] stopDiscover];
    [self.navigationController popViewControllerAnimated:YES];
}

//查看明文密码
- (IBAction)viewPwd:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.pwdTextField.secureTextEntry = !self.pwdTextField.secureTextEntry;
}

//下一步
- (IBAction)nextBtnClick:(id)sender {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"uuid"] = self.UUID;
    dict[@"ssid"] = self.nameTextField.text;
    dict[@"pwd"] = self.pwdTextField.text;
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceConnectStart" object:dict];
//    [self dismissViewControllerAnimated:YES completion:nil];
        DeviceConnectingVC *VC = [DeviceConnectingVC new];
        VC.connectDeviceInfo = dict;
        [self.navigationController pushViewController:VC animated:YES];
    
    
//    if(self.ispwdError){
//        //恢复配网
//        ThingBLEWifiConfigModel *configModel = [ThingBLEWifiConfigModel new];
//        configModel.uuid = self.UUID;
//        configModel.ssid = self.nameTextField.text;
//        configModel.password = self.pwdTextField.text;
//        [[ThingSmartBLEWifiActivator sharedInstance] resumeConfigBLEWifiDeviceWithActionType:ThingBLEWifiConfigResumeActionTypeSetWifi configModel:configModel];
//    }else{
//        [[ThingSmartBLEWifiActivator sharedInstance] pairDeviceWithUUID:self.UUID token:self.token ssid:self.nameTextField.text pwd:self.pwdTextField.text timeout:120];
//    }
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(self.nameTextField.text.length > 0 && self.pwdTextField.text.length > 0) {
        [PublicObj makeButtonEnable:self.nextBtn];
    }else{
        [PublicObj makeButtonUnEnable:self.nextBtn];
    }
}

//#pragma mark -- ThingSmartBLEWifiActivatorDelegate
//- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator didReceiveBLEWifiConfigDevice:(nullable ThingSmartDeviceModel *)deviceModel error:(nullable NSError *)error{
//    [self hiddenHud];
//    if(!error){
//        //配网成功
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceConnectStatusChanged" object:@(AddStatusType_success)];
//        //在配网结束后调用
//        [[ThingSmartBLEWifiActivator sharedInstance] stopDiscover];
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }else{
//        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
//        if(error.code == 3 || error.code == 4){
//            //Wi-Fi 密码错误
//            [SVProgressHUD showErrorWithStatus:@"wifi密码错误，请重新输入"];
//            self.ispwdError = YES;
//        }else{
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceConnectStatusChanged" object:@(AddStatusType_fail)];
//        }
//        NSLog(@"配网失败");
//    }
//    
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
