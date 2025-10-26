//
//  SwitchConfigViewController.m
//  AIToys
//
//  Created by qdkj on 2025/8/20.
//

#import "SwitchConfigViewController.h"
#import <ThingSmartMiniAppBizBundle/ThingSmartMiniAppBizBundle.h>
#import <AudioToolbox/AudioToolbox.h>
#import "WCQRCodeScanningVC.h"
#import "SGQRCodeScanManager.h"

@interface SwitchConfigViewController ()
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *testConfigBtn;
@property (weak, nonatomic) IBOutlet UIButton *productConfigBtn;
@end

@implementation SwitchConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.productConfigBtn im
    ///当前环境 1、测试  2、生产
    NSInteger type = [[NSUserDefaults standardUserDefaults] integerForKey:KCURRENT_API_TYPE];
    if (type == 2){
        self.productConfigBtn.selected = YES;
        self.testConfigBtn.selected = NO;
    }else{
        self.testConfigBtn.selected = YES;
        self.productConfigBtn.selected = NO;
    }
    [self.testConfigBtn layoutWithStyle:HKBtnImagePosition_Left space:15];
    
    [self.productConfigBtn layoutWithStyle:HKBtnImagePosition_Left space:15];
}

//扫码
- (IBAction)scanBtnClick:(id)sender {
    //打开扫描二维码页面
    WCQRCodeScanningVC *WBVC = [[WCQRCodeScanningVC alloc] init];
    WBVC.scanResultBlock = ^(NSString *result) {
        // 通过二维码打开小程序
        [[ThingMiniAppClient coreClient] openMiniAppByQrcode:result params:@{@"BearerId":(kMyUser.accessToken?:@""),@"langType":@"en"}];
    };
    [self QRCodeScanVC:WBVC];
}

- (void)QRCodeScanVC:(UIViewController *)scanVC {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.navigationController pushViewController:scanVC animated:YES];
                        });
                        NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                    } else {
                        NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                    }
                }];
                break;
            }
            case AVAuthorizationStatusAuthorized: {
                [self.navigationController pushViewController:scanVC animated:YES];
                break;
            }
            case AVAuthorizationStatusDenied: {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {

                }];

                [alertC addAction:alertA];
                [self presentViewController:alertC animated:YES completion:nil];
                break;
            }
            case AVAuthorizationStatusRestricted: {
                NSLog(@"因为系统原因, 无法访问相册");
                break;
            }

            default:
                break;
        }
        return;
    }

    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {

    }];

    [alertC addAction:alertA];
    [self presentViewController:alertC animated:YES completion:nil];
}


//切换环境
- (IBAction)configureBtnClick:(UIButton *)sender {
    WEAK_SELF
    [LGBaseAlertView showAlertWithTitle:[NSString stringWithFormat:@"确定切换到%@环境吗？",sender.titleLabel.text]  content:@"切换环境后后退出登录" cancelBtnStr:LocalString(@"取消") confirmBtnStr:LocalString(@"确定") confirmBlock:^(BOOL isValue, id obj) {
        if (isValue){
            if(sender.tag == 100){
                //测试环境
                [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:KCURRENT_API_TYPE];
                [[NSUserDefaults standardUserDefaults] synchronize];
                weakSelf.productConfigBtn.selected = NO;
                weakSelf.testConfigBtn.selected = YES;
            }else{
                //线上环境
                [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:KCURRENT_API_TYPE];
                [[NSUserDefaults standardUserDefaults] synchronize];
                weakSelf.productConfigBtn.selected = YES;
                weakSelf.testConfigBtn.selected = NO;
            }
            [UserInfo clearMyUser];
            [CoreArchive removeStrForKey:KCURRENT_HOME_ID];
            [UserInfo showLogin];
           
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
