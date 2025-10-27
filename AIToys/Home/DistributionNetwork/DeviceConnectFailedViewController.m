//
//  DeviceConnectFailedViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/19.
//

#import "DeviceConnectFailedViewController.h"

@interface DeviceConnectFailedViewController ()

@end

@implementation DeviceConnectFailedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)closeBtnClick:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)backBtnClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)restartClick:(id)sender {
    
    
    
    // 返回到FindDeviceViewController
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:NSClassFromString(@"FindDeviceViewController")]) {
           [[NSNotificationCenter defaultCenter] postNotificationName:@"faildBackChange" object:nil];
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
    }
    
    // 如果导航栈中没有找到FindDeviceViewController，则pop到根视图
    NSLog(@"⚠️ 未在导航栈中找到FindDeviceViewController，返回根视图");
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
