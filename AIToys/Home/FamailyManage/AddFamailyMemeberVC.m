//
//  AddFamailyMemeberVC.m
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import "AddFamailyMemeberVC.h"
#import "ATFontManager.h"

@interface AddFamailyMemeberVC ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountAlertLab;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UILabel *roleTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *roleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property(strong, nonatomic) ThingSmartHome *home;
@end

@implementation AddFamailyMemeberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LocalString(@"添加成员");
    self.nameLabel.text = LocalString(@"家庭成员名称");
    self.nameTextField.placeholder = LocalString(@"家庭成员名称");
    self.accountLabel.text = LocalString(@"账号");
    self.accountTextField.placeholder = LocalString(@"账号");
    self.roleTitleLabel.text = LocalString(@"家庭角色");
    self.roleNameLabel.text = LocalString(@"管理员");
    self.accountAlertLab.text = LocalString(@"关联账号接受邀请后，才能成为家庭成员并使用相关功能。");
    
    self.view.backgroundColor = tableBgColor;
    [self setRightBtn];
    [self loadData];
}

//设置右侧按钮
-(void)setRightBtn{
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 40, 44)];
    [rightButton setTitle:LocalString(@"保存") forState:UIControlStateNormal];
    [rightButton setTitleColor:mainColor forState:UIControlStateNormal];
    rightButton.titleLabel.font = [ATFontManager systemFontOfSize:15];
    rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [rightButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)loadData{
    //初始化成员操作类
    ThingSmartHomeModel *model = self.homeModel;
    self.home = [ThingSmartHome homeWithHomeId:model.homeId];
}

//确定
-(void)done{
    WEAK_SELF
    if(self.nameTextField.text.length == 0){
        [SVProgressHUD showErrorWithStatus:LocalString(@"请输入名称")];
        return;
    }
    if(self.accountTextField.text.length == 0){
        [SVProgressHUD showErrorWithStatus:LocalString(@"请输入帐号")];
        return;
    }
    ThingSmartHomeAddMemberRequestModel *requestModel = [[ThingSmartHomeAddMemberRequestModel alloc] init];
    requestModel.name = self.nameTextField.text;
    requestModel.account = self.accountTextField.text;
    requestModel.countryCode = Country_Code;
    requestModel.role = ThingHomeRoleType_Admin;
    requestModel.autoAccept = NO;
    [self showHud];
    [self.home addHomeMemberWithAddMemeberRequestModel:requestModel success:^(NSDictionary *dict) {
        [weakSelf hiddenHud];

        // 埋点上报：家庭空间添加成员
        NSString *permission = kAnalyticsPermission_Admin; // 默认添加的是管理员权限
        NSString *homeId = [NSString stringWithFormat:@"%lld", (long long)weakSelf.homeModel.homeId];

        // 尝试从返回的字典中获取新添加成员的ID
        NSString *familyMemberId = @"";
        if (dict && [dict isKindOfClass:[NSDictionary class]]) {
            // 可能的字段名：memberId, memberID, id, member_id 等
            id memberIdValue = dict[@"memberId"] ?: dict[@"memberID"] ?: dict[@"id"] ?: dict[@"member_id"];
            if (memberIdValue) {
                familyMemberId = [NSString stringWithFormat:@"%@", memberIdValue];
            }
        }

        // 获取家庭拥有者的uid（使用当前登录用户的uid，因为只有家庭所有者才能添加成员）
        NSString *homeOwnerId = [ThingSmartUser sharedInstance].uid ?: @"";

        [[AnalyticsManager sharedManager] reportFamilyAddMemberWithPermission:permission
                                                                        homeId:homeId
                                                               familyMemberId:familyMemberId
                                                                  homeOwnerId:homeOwnerId];

        [weakSelf.navigationController popViewControllerAnimated:YES];

    } failure:^(NSError *error) {
        [weakSelf hiddenHud];
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
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
