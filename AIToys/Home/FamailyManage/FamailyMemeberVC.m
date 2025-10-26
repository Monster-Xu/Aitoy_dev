//
//  FamailyMemeberVC.m
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import "FamailyMemeberVC.h"
#import "FamailyMemeberCell.h"
#import "FamailyMemeberAvatarCell.h"
#import "FamailyNameCell.h"
#import "ATFontManager.h"

@interface FamailyMemeberVC ()<UITableViewDelegate,UITableViewDataSource,RYFTableViewDelegate>
@property (nonatomic, strong)RYFTableView *tableView;
@property (nonatomic,strong) NSArray *dataArr;
@property(assign, nonatomic) BOOL isOwner;//是否是家庭所有者
@end

@implementation FamailyMemeberVC

- (RYFTableView *)tableView{
    if (!_tableView) {
        _tableView = [[RYFTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.tableViewDelegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 64;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 15)];
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 15;
        _tableView.backgroundColor = tableBgColor;
        [_tableView registerNib:[UINib nibWithNibName:@"FamailyNameCell" bundle:nil] forCellReuseIdentifier:@"FamailyNameCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"FamailyMemeberCell" bundle:nil] forCellReuseIdentifier:@"FamailyMemeberCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"FamailyMemeberAvatarCell" bundle:nil] forCellReuseIdentifier:@"FamailyMemeberAvatarCell"];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isOwner = self.homeModel.role == ThingHomeRoleType_Owner || ThingHomeRoleType_Admin;
    [self setupUI];
}


- (void)loadDataRefreshOrPull:(RYFRefreshType)type {
    if (type == 0) {
//        request.Page = @"1";
    }else{
        
//        request.Page = _tableView.getCurrentPage.stringValue;
    }
    [self.tableView endLoading];
    [self.tableView reloadData];
}

-(void)setupUI{
    self.title = LocalString(@"家庭成员");
    self.tableView.loadState = RYFCanLoadRefresh;
    if(self.isOwner){
        if(self.inviteModel){
            self.tableView.tableFooterView = [self setupfooterView];
        }
        if(self.memberModel){
            if((self.homeModel.role == ThingHomeRoleType_Admin && self.memberModel.role == ThingHomeRoleType_Member) || (self.homeModel.role == ThingHomeRoleType_Owner && self.memberModel.role != ThingHomeRoleType_Owner)){
                //房间所有者可以删除除了自己的成员，管理员只能删除普通成员及以下
                self.tableView.tableFooterView = [self setupRemoveFooterView];
            }
        }
    }
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

- (UIView *)setupfooterView {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 2*64)];
    
    UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 2*64)];
    btnView.backgroundColor = UIColor.whiteColor;
    [footer addSubview:btnView];
    UIButton *inviteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    inviteBtn.titleLabel.font = [ATFontManager systemFontOfSize:16];
    [inviteBtn setTitle:LocalString(@"重新邀请") forState:0];
    [inviteBtn setTitleColor:UIColorHex(F04C4C) forState:0];
    [inviteBtn addTarget:self action:@selector(inviteAgain) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:inviteBtn];
    [inviteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(btnView);
        make.height.mas_equalTo(64);
    }];
    
    UIButton *revokeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    revokeBtn.titleLabel.font = [ATFontManager systemFontOfSize:16];
    [revokeBtn setTitle:LocalString(@"撤销") forState:0];
    [revokeBtn setTitleColor:UIColorHex(F04C4C) forState:0];
    [revokeBtn addTarget:self action:@selector(revoke) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:revokeBtn];
    [revokeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(inviteBtn.mas_bottom).offset(0);
        make.bottom.left.right.equalTo(btnView);
        make.height.mas_equalTo(64);
    }];
    
    return footer;
}

- (UIView *)setupRemoveFooterView {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    
    UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    btnView.backgroundColor = UIColor.whiteColor;
    [footer addSubview:btnView];
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.titleLabel.font = [ATFontManager systemFontOfSize:16];
    [deleteBtn setTitle:LocalString(@"移除成员") forState:0];
    [deleteBtn setTitleColor:UIColorHex(F04C4C) forState:0];
    [deleteBtn addTarget:self action:@selector(memeberRemove) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:deleteBtn];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(btnView);
    }];
    
    return footer;
}

-(void)memeberRemove{
    WEAK_SELF
    [LGBaseAlertView showAlertWithTitle:LocalString(@"移除成员") content:LocalString(@"确定要移除该成员吗？") cancelBtnStr:LocalString(@"取消") confirmBtnStr:LocalString(@"删除") confirmBlock:^(BOOL isValue, id obj) {
        if (isValue){
            [weakSelf showHud];
            ThingSmartHomeMember *homeMember = [[ThingSmartHomeMember alloc] init];
            [homeMember removeHomeMemberWithMemberId:self.memberModel.memberId success:^{
                [weakSelf hiddenHud];

                // 埋点上报：家庭空间移除成员
                NSString *homeId = [NSString stringWithFormat:@"%lld", (long long)weakSelf.homeModel.homeId];
                NSString *familyMemberId = [NSString stringWithFormat:@"%lld", (long long)weakSelf.memberModel.memberId];
                NSString *homeOwnerId = [ThingSmartUser sharedInstance].uid ?: @"";
                [[AnalyticsManager sharedManager] reportFamilyRemoveMemberWithHomeId:homeId
                                                                    familyMemberId:familyMemberId
                                                                       homeOwnerId:homeOwnerId];

                [weakSelf.navigationController popViewControllerAnimated:YES];
            } failure:^(NSError *error) {
                [weakSelf hiddenHud];
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }];
        }
    }];
   
}

//修改成员名称
- (void)showAlertWithTextField {
    WEAK_SELF
    NSString *name = self.memberModel ? self.memberModel.name : self.inviteModel.name;
    [LGBaseAlertView showAlertInfo:@{@"title":LocalString(@"名称"),@"value":name?:@"",@"placeholder":LocalString(@"名称")} withType:ALERT_VIEW_TYPE_EditName confirmBlock:^(BOOL is_value, id obj) {
        NSString *str = (NSString *)obj;
        if (is_value && str.length > 0) {
            if(self.memberModel){
    //            if(self.memberModel.role == ThingHomeRoleType_Owner){
    //                [[ThingSmartUser sharedInstance] updateNickname:inputText success:^{
    //                    weakSelf.memberModel.name = inputText;
    //                    [weakSelf.tableView reloadData];
    //                } failure:^(NSError *error) {
    //                    [SVProgressHUD showErrorWithStatus:error.description];
    //                    NSLog(@"updateNickname failure: %@", error);
    //                }];
    //            }
                ThingSmartHomeMember *homeMember = [[ThingSmartHomeMember alloc] init];
            
                ThingSmartHomeMemberRequestModel *requestModel = [[ThingSmartHomeMemberRequestModel alloc] init];
                requestModel.memberId = self.memberModel.memberId;
                requestModel.name = str;
                requestModel.role = self.memberModel.role;
                [homeMember updateHomeMemberInfoWithMemberRequestModel:requestModel success:^{
                    [self hiddenHud];

                    // 埋点上报：家庭空间修改成员权限（如果权限有变化）
                    NSString *permission = @"";
                    switch (requestModel.role) {
                        case ThingHomeRoleType_Owner:
                            permission = kAnalyticsPermission_Owner;
                            break;
                        case ThingHomeRoleType_Admin:
                            permission = kAnalyticsPermission_Admin;
                            break;
                        case ThingHomeRoleType_Member:
                            permission = kAnalyticsPermission_Normal;
                            break;
                        default:
                            permission = kAnalyticsPermission_Normal;
                            break;
                    }
                    [[AnalyticsManager sharedManager] reportFamilyModifyMemberPermissionWithPermission:permission];

                    weakSelf.memberModel.name = str;
                    [weakSelf.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationNone];
                    } failure:^(NSError *error) {
                        [self hiddenHud];
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }];
            }else{
                ThingSmartHomeInvitationInfoRequestModel *requestModel = [[ThingSmartHomeInvitationInfoRequestModel alloc] init];
                requestModel.invitationID = self.inviteModel.invitationID;
                requestModel.name = str;
                requestModel.role = self.inviteModel.role;
                [self showHud];
                [weakSelf.smartHomeInvitation updateInvitationInfoWithInvitationInfoRequestModel:requestModel success:^(BOOL result) {
                    [weakSelf hiddenHud];
                    weakSelf.inviteModel.name = str;
                    [weakSelf.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationNone];
                } failure:^(NSError *error) {
                    [weakSelf hiddenHud];
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }];
            }
        } else {
            if(is_value){
                [SVProgressHUD showErrorWithStatus:LocalString(@"请输入名称")];
            }
        }
    }];
}

//重新邀请
-(void)inviteAgain{
    WEAK_SELF
    [self.smartHomeInvitation cancelInvitationWithInvitationID:self.inviteModel.invitationID success:^(BOOL result) {
        if(result){
            [weakSelf createInvitCode];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

//生成邀请码
- (void)createInvitCode{
    WEAK_SELF
    ThingSmartHomeInvitationCreateRequestModel *requestModel = [[ThingSmartHomeInvitationCreateRequestModel alloc] init];
    requestModel.homeID = self.homeModel.homeId;
    requestModel.needMsgContent = YES;
    [self.smartHomeInvitation createInvitationWithCreateRequestModel:requestModel success:^(ThingSmartHomeInvitationResultModel * _Nonnull invitationResultModel) {
        [LGBaseAlertView showAlertWithTitle:LocalString(@"邀请成员") content:invitationResultModel.invitationMsgContent cancelBtnStr:nil confirmBtnStr:LocalString(@"复制") confirmBlock:^(BOOL isValue, id obj) {
            if (isValue){
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = invitationResultModel.invitationMsgContent;
                [SVProgressHUD showSuccessWithStatus:LocalString(@"已复制到剪切板")];
            }
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

//撤销
-(void)revoke{
    WEAK_SELF
    [LGBaseAlertView showAlertWithTitle:LocalString(@"撤销") content:LocalString(@"确定要撤销该邀请吗？") cancelBtnStr:LocalString(@"取消") confirmBtnStr:LocalString(@"撤销") confirmBlock:^(BOOL isValue, id obj) {
        if (isValue){
            [weakSelf.smartHomeInvitation cancelInvitationWithInvitationID:self.inviteModel.invitationID success:^(BOOL result) {
                if(result){
                    [SVProgressHUD showSuccessWithStatus:LocalString(@"撤销成功")];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            } failure:^(NSError *error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }];
        }
    }];
    
}
#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.memberModel ? 2 : 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            FamailyNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FamailyNameCell" forIndexPath:indexPath];
            cell.titleLabel.text = LocalString(@"名称");
            cell.nameLabel.text = self.memberModel? self.memberModel.name: self.inviteModel.name;
            cell.rightImg.hidden = !self.isOwner;
            ThingHomeRoleType role = self.memberModel? self.memberModel.role: self.inviteModel.role;
            if(self.isOwner && role != ThingHomeRoleType_Owner){
                cell.rightImgW.constant = 24;
            }else{
                cell.rightImgW.constant = 0;
            }
            return cell;
        }else{
            FamailyMemeberAvatarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FamailyMemeberAvatarCell" forIndexPath:indexPath];
            return cell;
        }
    }else{
        FamailyMemeberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FamailyMemeberCell" forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                cell.titleLabel.text = LocalString(@"关联账号");
                cell.nameLabel.text = self.memberModel? self.memberModel.userName: self.inviteModel.dealStatus == ThingHomeStatusPending ?LocalString(@"待加入") : LocalString(@"已拒绝");
                break;
            case 1:
                cell.titleLabel.text = LocalString(@"家庭角色");
                cell.nameLabel.text = [self getMemeberRoleName:self.memberModel? self.memberModel.role: self.inviteModel.role];
                break;
    
            default:
                break;
        }
        return cell;
    }
    
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ThingHomeRoleType role = self.memberModel? self.memberModel.role: self.inviteModel.role;
    if(indexPath.section == 0 && self.isOwner && indexPath.row == 0 && role != ThingHomeRoleType_Owner){
        [self showAlertWithTextField];
    }
    
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
