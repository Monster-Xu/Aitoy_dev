//
//  ThirdPartySDKInfoViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/9/29.
//

#import "ThirdPartySDKInfoViewController.h"

@interface ThirdPartySDKInfoViewController ()

@end

@implementation ThirdPartySDKInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LocalString(@"第三方信息共享和SDK服务清单");
    self.tltleLAbel.text  = LocalString(@"涂鸦-智慧生活App-sdk   ios-6.7.0版本");
    // Do any additional setup after loading the view from its nib.
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
