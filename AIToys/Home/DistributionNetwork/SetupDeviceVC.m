//
//  SetupDeviceVC.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/29.
//

#import "SetupDeviceVC.h"
#import "DeviceConnectingVC.h"

@interface SetupDeviceVC ()

@end

@implementation SetupDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
}

//返回
- (IBAction)resetBtnClick:(id)sender {
    if (self.clickBlock) {
        self.clickBlock();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//连接
- (IBAction)connectBtnClick:(id)sender {
    if (self.clickBlock) {
        self.clickBlock();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
//    DeviceConnectingVC *VC = [DeviceConnectingVC new];
//    [self.navigationController pushViewController:VC animated:YES];
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
