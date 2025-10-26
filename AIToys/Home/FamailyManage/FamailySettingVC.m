//
//  FamailySettingVC.m
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import "FamailySettingVC.h"
#import "FamailyNameCell.h"
#import "FamailyMemberCell.h"
#import "AddFamailyMemeberVC.h"
#import "FamailyMemeberVC.h"
#import "ATFontManager.h"

@interface FamailySettingVC ()<UITableViewDelegate,UITableViewDataSource,RYFTableViewDelegate,ThingSmartHomeDelegate>
@property (nonatomic, strong)RYFTableView *tableView;
@property (nonatomic,strong) UIButton *deleteBtn;
@property(strong, nonatomic) ThingSmartHome *home;
@property(strong, nonatomic) ThingSmartHomeInvitation *smartHomeInvitation;
@property(strong, nonatomic) NSMutableArray<ThingSmartHomeMemberModel *> *dataArr;
@property(strong, nonatomic) NSMutableArray<ThingSmartHomeInvitationRecordModel *> *inviteArr;
@property(assign, nonatomic) BOOL isMember;//是否是家庭成员
@property(strong, nonatomic) ThingSmartHomeManager *homeManager;
@property(assign, nonatomic) long long currentMemberId;//当前成员ID
@end

@implementation FamailySettingVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadDataRefreshOrPull:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self setupUI];
}

-(void)loadData{
    //初始化成员操作类
    ThingSmartHomeModel *model = self.homeModel;
    self.home = [ThingSmartHome homeWithHomeId:model.homeId];
    self.home.delegate = self;
    //初始化邀请成员操作类
    self.smartHomeInvitation = [[ThingSmartHomeInvitation alloc] init];
    self.isMember = self.homeModel.role == ThingHomeRoleType_Member;
    self.homeManager = [[ThingSmartHomeManager alloc] init];
    [self.home getHomeDataWithSuccess:^(ThingSmartHomeModel *homeModel) {
    } failure:^(NSError *error) {
        
    }];
    
//    [self loadDataRefreshOrPull:0];
}


- (void)loadDataRefreshOrPull:(RYFRefreshType)type {
    [self showHud];
    WEAK_SELF
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf.home getHomeMemberListWithSuccess:^(NSArray<ThingSmartHomeMemberModel *> *memberList) {
            weakSelf.dataArr = [memberList mutableCopy];
            for (ThingSmartHomeMemberModel *obj in weakSelf.dataArr) {
                if([obj.userName isEqualToString: [ThingSmartUser sharedInstance].email]){
                    weakSelf.currentMemberId = obj.memberId;
                    break;
                }
            }
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf.smartHomeInvitation fetchInvitationRecordListWithHomeID:weakSelf.homeModel.homeId success:^(NSArray<ThingSmartHomeInvitationRecordModel *> * _Nonnull invitationRecordList) {
            [weakSelf.inviteArr removeAllObjects];
            for (ThingSmartHomeInvitationRecordModel *item in invitationRecordList) {
                if(item.dealStatus != ThingHomeStatusAccept){
                    [weakSelf.inviteArr addObject:item];
                }
            }
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [weakSelf hiddenHud];
        [weakSelf.tableView endLoading];
        [weakSelf.tableView reloadData];
    });
    
}

-(void)setupUI{
    self.title = LocalString(@"家庭设置");
    self.tableView.loadState = RYFCanLoadRefresh;
    self.tableView.tableFooterView = [self setupfooterView];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

- (UIView *)setupfooterView {
    CGFloat btnViewH = self.isMember ? 64 : 64*2;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 15 + btnViewH)];
    
    UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, kScreenWidth,  btnViewH)];
    btnView.backgroundColor = UIColor.whiteColor;
    [footer addSubview:btnView];
    CGFloat deleteBtnTop = 0;
    if(!self.isMember){
        UIButton *inviteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        inviteBtn.titleLabel.font = [ATFontManager systemFontOfSize:16];
        [inviteBtn setTitle:LocalString(@"邀请成员") forState:0];
        [inviteBtn setTitleColor:mainColor forState:0];
        [inviteBtn addTarget:self action:@selector(inviteMember:) forControlEvents:UIControlEventTouchUpInside];
        [btnView addSubview:inviteBtn];
        [inviteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(btnView);
            make.height.mas_equalTo(64);
        }];
        deleteBtnTop = 64;
    }
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteBtn.titleLabel.font = [ATFontManager systemFontOfSize:16];
    self.deleteBtn.frame = CGRectMake(0, deleteBtnTop, kScreenWidth, 64);
    [self.deleteBtn setTitle: self.isMember ? LocalString(@"离开家庭") : LocalString(@"删除家庭") forState:0];
    [self.deleteBtn setTitleColor:UIColorHex(F04C4C) forState:0];
    [self.deleteBtn addTarget:self action:@selector(deleteFamaily) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:self.deleteBtn];
    return footer;
}

//修改家庭名称
- (void)showAlertWithTextField {
    WEAK_SELF
    [LGBaseAlertView showAlertInfo:@{@"title":LocalString(@"家庭名称"),@"value":self.homeModel.name?:@"",@"placeholder":LocalString(@"名称")} withType:ALERT_VIEW_TYPE_EditName confirmBlock:^(BOOL is_value, id obj) {
        NSString *str = (NSString *)obj;
        if (is_value && str.length > 0) {
            [weakSelf.home updateHomeInfoWithName:str geoName:self.homeModel.geoName latitude:self.homeModel.latitude longitude:self.homeModel.longitude success:^{
                weakSelf.homeModel.name = str;
                [weakSelf.tableView reloadData];
            } failure:^(NSError *error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }];
        } else {
            if(is_value){
                [SVProgressHUD showErrorWithStatus:LocalString(@"请输入名称")];
            }
        }
    }];
}

//删除/离开家庭
-(void)deleteFamaily{
    WEAK_SELF
    if(!self.isMember){
        if(self.home.deviceList.count > 0){
            [LGBaseAlertView showAlertWithTitle:LocalString(@"无法删除") content:LocalString(@"您家庭下有故事机，请解绑后再删除家庭") cancelBtnStr:nil confirmBtnStr:LocalString(@"确定") confirmBlock:^(BOOL isValue, id obj) {
                if (isValue){
                   
                }
            }];
            return;
        }
        if (self.isSignalHome){
            [LGBaseAlertView showAlertWithTitle:LocalString(@"无法删除") content:LocalString(@"请至少保留一个家庭") cancelBtnStr:nil confirmBtnStr:LocalString(@"确定") confirmBlock:^(BOOL isValue, id obj) {
                if (isValue){
                   
                }
            }];
            return;
        }
    }
    [LGBaseAlertView showAlertWithTitle:self.isMember?LocalString(@"离开家庭"): LocalString(@"删除家庭") content:self.isMember ? LocalString(@"确定要离开家庭吗？"): LocalString(@"删除家庭不可恢复，您的家庭成员将会被清退，是否继续？") cancelBtnStr:LocalString(@"取消") confirmBtnStr:self.isMember? LocalString(@"离开"): LocalString(@"删除") confirmBlock:^(BOOL isValue, id obj) {
        if (isValue){
            [weakSelf showHud];
            ThingSmartHomeMember *homeMember = [[ThingSmartHomeMember alloc] init];
            [homeMember removeHomeMemberWithMemberId:weakSelf.currentMemberId success:^{
                [weakSelf hiddenHud];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } failure:^(NSError *error) {
                [weakSelf hiddenHud];
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }];
        }
    }];
   
    
}

//添加成员
-(void)addMember{
    kPreventRepeatClickTime(0.5)
    AddFamailyMemeberVC *VC = [AddFamailyMemeberVC new];
    VC.homeModel = self.homeModel;
    [self.navigationController pushViewController:VC animated:YES];
    
}

//邀请成员
-(void)inviteMember:(UIButton *)btn{
    WEAK_SELF
    ThingSmartHomeInvitationCreateRequestModel *requestModel = [[ThingSmartHomeInvitationCreateRequestModel alloc] init];
    requestModel.homeID = self.homeModel.homeId;
    requestModel.needMsgContent = YES;
    btn.userInteractionEnabled = NO;
    [self.smartHomeInvitation createInvitationWithCreateRequestModel:requestModel success:^(ThingSmartHomeInvitationResultModel * _Nonnull invitationResultModel) {
        btn.userInteractionEnabled = YES;
        [LGBaseAlertView showAlertWithTitle:LocalString(@"邀请成员") content:invitationResultModel.invitationMsgContent cancelBtnStr:nil confirmBtnStr:LocalString(@"复制") confirmBlock:^(BOOL isValue, id obj) {
            if (isValue){
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = invitationResultModel.invitationMsgContent;
                [SVProgressHUD showSuccessWithStatus:LocalString(@"已复制到剪切板")];
                [weakSelf loadDataRefreshOrPull:1];
            }
        }];
    } failure:^(NSError *error) {
        btn.userInteractionEnabled = YES;
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}
#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return self.dataArr.count;
    }else if (section == 2){
        return self.inviteArr.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        FamailyNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FamailyNameCell" forIndexPath:indexPath];
        cell.model = self.homeModel;
        return cell;
    }else if(indexPath.section == 1){
        FamailyMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FamailyMemberCell" forIndexPath:indexPath];
        cell.isExpire = NO;
        cell.nameLabel.text = self.dataArr[indexPath.row].name;
        NSString *phoneStr = @"";
        switch (self.dataArr[indexPath.row].dealStatus) {
            case ThingHomeStatusPending:
                phoneStr = LocalString(@"待加入");
                break;
            case ThingHomeStatusReject:
                phoneStr = LocalString(@"已拒绝");
                break;
                
            default:
                phoneStr = self.dataArr[indexPath.row].userName;
                break;
        }
        cell.phoneLabel.text = phoneStr;
        cell.roleLabel.text = [self getMemeberRoleName:self.dataArr[indexPath.row].role];
        return cell;
    }else{
        FamailyMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FamailyMemberCell" forIndexPath:indexPath];
        cell.nameLabel.text = self.inviteArr[indexPath.row].name;
        cell.isExpire = YES;
        cell.phoneLabel.text = self.inviteArr[indexPath.row].dealStatus == ThingHomeStatusPending ?LocalString(@"待加入") : LocalString(@"已超时");
        if(self.inviteArr[indexPath.row].dealStatus == ThingHomeStatusPending){
            NSInteger time = self.inviteArr[indexPath.row].validTime;
            NSInteger day = time / 24;
            NSInteger hours = 0;
            NSInteger minutes = 0;
            if(day == 0){
                hours = time % 24;
                cell.roleLabel.text = [NSString stringWithFormat:@"%li%@",hours,LocalString(@"小时后过期")];
            }else{
                cell.roleLabel.text = [NSString stringWithFormat:@"%li%@",(long)day,LocalString(@"天后过期")];
            }
        }else{
            cell.roleLabel.text = @"";
        }
        
        return cell;
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 1){
        UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 38)];
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, kScreenWidth-30, 14)];
        nameLabel.textColor = UIColorFromRGBA(000000, 0.5);
        nameLabel.font = [ATFontManager systemFontOfSize:13];
        nameLabel.text = LocalString(@"家庭成员");
        [headView addSubview:nameLabel];
        return headView;
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if(section == 2 && !self.isMember){
        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
        footerView.backgroundColor = UIColor.whiteColor;
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.textColor = mainColor;
        nameLabel.font = [ATFontManager systemFontOfSize:16];
        nameLabel.text = LocalString(@"添加成员");
        [footerView addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(footerView).offset(15);
            make.top.bottom.equalTo(footerView);
        }];
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn addTarget:self action:@selector(addMember) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:addBtn];
        [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(footerView);
        }];
    return footerView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==1 ? 38 : 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(section == 2 && !self.isMember){
        return 64;;
    }
    return 0;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(!self.isMember){
            [self showAlertWithTextField];
        }
    }else{
        FamailyMemeberVC *VC = [FamailyMemeberVC new];
        VC.homeModel = self.homeModel;
        if(indexPath.section == 1){
            VC.memberModel = self.dataArr[indexPath.row];
        }else{
            VC.inviteModel = self.inviteArr[indexPath.row];
        }
        VC.smartHomeInvitation = self.smartHomeInvitation;
        [self.navigationController pushViewController:VC animated:YES];
    }
    
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}

- (NSMutableArray *)inviteArr {
    if (!_inviteArr) {
        _inviteArr = [[NSMutableArray alloc] init];
    }
    return _inviteArr;
}

- (RYFTableView *)tableView{
    if (!_tableView) {
        _tableView = [[RYFTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.tableViewDelegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 64;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 15)];
        _tableView.backgroundColor = tableBgColor;
        [_tableView registerNib:[UINib nibWithNibName:@"FamailyNameCell" bundle:nil] forCellReuseIdentifier:@"FamailyNameCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"FamailyMemberCell" bundle:nil] forCellReuseIdentifier:@"FamailyMemberCell"];
    }
    return _tableView;
}

#pragma mark - ThingSmartHomeDelegate
// 家庭的信息更新，例如家庭 name 变化
- (void)homeDidUpdateInfo:(ThingSmartHome *)home {
//    [self loadDataRefreshOrPull:0];
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
