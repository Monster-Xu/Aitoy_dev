//
//  EmaileViewController.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/16.
//

#import "EmaileViewController.h"
#import "ChangeEmailViewController.h"
#import "RegistViewController.h"

@interface EmaileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

@end

@implementation EmaileViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.emailLabel.text = [ThingSmartUser sharedInstance].email;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = LocalString(@"您的邮箱");
    self.emailLabel.text = [ThingSmartUser sharedInstance].email;
    [self.changeBtn setTitle:LocalString(@"更换邮箱") forState:0];
    self.alertLabel.text = LocalString(@"更换邮箱后，下次登录可使用新邮箱登录");
}

//更换邮箱
- (IBAction)emailBtnClick:(id)sender {
    RegistViewController *VC = [RegistViewController new];
    VC.type = EmailType_change;
    [self.navigationController pushViewController:VC animated:YES];
//    ChangeEmailViewController *VC = [ChangeEmailViewController new];
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
