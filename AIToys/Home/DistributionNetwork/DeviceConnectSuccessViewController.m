//
//  DeviceConnectSuccessViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/19.
//

#import "DeviceConnectSuccessViewController.h"
#import <ThingSmartMiniAppBizBundle/ThingSmartMiniAppBizBundle.h>
#import "HomeViewController.h"


@interface DeviceConnectSuccessViewController ()
@property (weak, nonatomic) IBOutlet UITextField *deviceNameTextView;
@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;

@end

@implementation DeviceConnectSuccessViewController
-(void)setWifiName:(NSString *)wifiName{
    _wifiName = wifiName;
}
-(void)setDeviceModel:(ThingSmartDeviceModel *)deviceModel{
    _deviceModel = deviceModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:[PublicObj isEmptyObject:kMyUser.userId]? @"": kMyUser.userId forKey:@"memberUserId"];
    [param setValue:@"connectedWifi" forKey:@"propKey"];
    [param setValue:self.wifiName forKey:@"propValue"];
    [param setValue:@"" forKey:@"description"];
    [self modifySettingWithParam:param];
    // 在初始化textField后，添加事件监听
    [self.deviceNameTextView addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.deviceNameTextView.text = self.deviceModel.name;
    
    
    // Do any additional setup after loading the view from its nib.
}
//上传wifi信息
- (void)modifySettingWithParam:(NSDictionary *)param{
    [[APIManager shared] POSTJSON:[APIPortConfiguration getAppPropertyCreateUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {

        NSLog(@"上传信息%@",result);

    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        NSLog(@"上传失败");
    }];
}
- (IBAction)startUseBtnClick:(id)sender {
    
    if (![self.deviceNameTextView.text isEqualToString:self.deviceModel.name]) {
        ThingSmartDevice *device = [ThingSmartDevice deviceWithDeviceId:self.deviceModel.devId];
        [device updateName:self.deviceNameTextView.text success:^{
                NSLog(@"updateName success");
            [SVProgressHUD showSuccessWithStatus:LocalString(@"修改成功，开始使用")];
            // 跳转小程序
            NSLog(@"deviceId:%@,token:%@",self.deviceModel.devId,kMyUser.accessToken);
            [[ThingMiniAppClient coreClient] openMiniAppByUrl:@"godzilla://ty7y8au1b7tamhvzij/pages/main/index" params:@{@"deviceId":self.deviceModel.devId,@"BearerId":(kMyUser.accessToken?:@""),@"langType":@"en",@"initialEntry":@"1"}];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:NO];
            });
           
            } failure:^(NSError *error) {
                [SVProgressHUD showSuccessWithStatus:LocalString(@"修改失败，请重试")];
            }];
    }else{
        NSLog(@"deviceId:%@,token:%@",self.deviceModel.devId,kMyUser.accessToken);
        [[ThingMiniAppClient coreClient] openMiniAppByUrl:@"godzilla://ty7y8au1b7tamhvzij/pages/main/index" params:@{@"deviceId":self.deviceModel.devId,@"BearerId":(kMyUser.accessToken?:@""),@"langType":@"en"}];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:NO];
        });
    }
   
    
}
// 实现监听方法
- (void)textFieldDidChange:(UITextField *)textField {
    NSLog(@"文本改变了：%@", textField.text);
    if (textField.text.length>0) {
        self.deviceLabel.hidden = NO;
    }else{
        self.deviceLabel.hidden = YES;
    }
    // 在这里处理文本改变的逻辑
}
- (IBAction)closeBtnClick:(id)sender {
     
    [self.navigationController popToRootViewControllerAnimated:YES];
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
