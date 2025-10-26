//
//  RevokePrivacyPolicyVC.m
//  AIToys
//
//  Created by qdkj on 2025/7/17.
//

#import "RevokePrivacyPolicyVC.h"
#import "DeleteAcountViewController.h"

@interface RevokePrivacyPolicyVC ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *operationLabel;

@end

@implementation RevokePrivacyPolicyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = LocalString(@"你即将撤回相关协议的同意操作");
    self.contentLabel.text = LocalString(@"撤回后你将：\n1.注销当前账号，并退出APP，\n2.该账号下的相关个人信息都将清除。");
    self.operationLabel.text = LocalString(@"确认撤回");
}

//确认撤回
- (IBAction)revokeBtnClick:(id)sender {
    DeleteAcountViewController *VC = [DeleteAcountViewController new];
    [self.navigationController pushViewController:VC animated:YES];
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
