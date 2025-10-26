//
//  JoinFamailyVC.m
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import "JoinFamailyVC.h"

@interface JoinFamailyVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;

@end

@implementation JoinFamailyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LocalString(@"加入一个家庭");
    self.titleLabel.text = LocalString(@"请家庭拥有者为您创建邀请");
    self.nameLabel.text = LocalString(@"（家庭设置 > 邀请成员 > 生成邀请）");
    self.textfield.placeholder = LocalString(@"输入邀请码");
    self.textfield.delegate = self;
    self.doneBtn.userInteractionEnabled = NO;;
}

//确认按钮
- (IBAction)doneBtnClick:(id)sender {
    WEAK_SELF
    ThingSmartHomeInvitation *smartHomeInvitation = [[ThingSmartHomeInvitation alloc] init];
    [self showHud];
    [smartHomeInvitation joinHomeWithInvitationCode:self.textfield.text success:^(BOOL result) {
        [weakSelf hiddenHud];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [weakSelf hiddenHud];
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

#pragma mark -- UITextFieldDelegate

- (IBAction)textFieldEditChange:(UITextField *)sender {
    if(sender.text.length > 0)
    {
        self.doneBtn.selected = YES;
        self.doneBtn.userInteractionEnabled = YES;
    }else{
        self.doneBtn.selected = NO;
        self.doneBtn.userInteractionEnabled = NO;
    }
}


-(void)textFieldDidChangeSelection:(UITextField *)textField{
    
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
