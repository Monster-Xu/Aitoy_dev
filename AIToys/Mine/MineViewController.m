//
//  MineViewController.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/18.
//

#import "MineViewController.h"
#import "LoginViewController.h"
#import "FamailyManageVC.h"
#import "MineListCell.h"
#import <ThingSmartBizCore/ThingSmartBizCore.h>
#import <ThingModuleServices/ThingHelpCenterProtocol.h>
#import <ThingModuleServices/ThingSmartHomeDataProtocol.h>
#import <ThingModuleServices/ThingMessageCenterProtocol.h>
#import "PersonalInformationVC.h"
#import "AvatarModel.h"

@interface MineViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, copy) NSString *unreadCount;
@property (nonatomic, assign) long long homeId;
@end

@implementation MineViewController

-(NSMutableArray *)itemArray{
    if (!_itemArray) {
        _itemArray = [NSMutableArray array];
    }
    return _itemArray;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateUserInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    NSArray *arr = @[
        @{@"icon" : @"mine_homeManage", @"title" : LocalString(@"家庭管理"), @"toVC" : @"FamailyManageVC"},
        @{@"icon" : @"mine_msg", @"title" : LocalString(@"消息中心"), @"toVC" : @"MessageCenterVC"},
        @{@"icon" : @"mine_setting", @"title" : LocalString(@"设置"), @"toVC" : @"SettingViewController"},
        ];
//    @{@"icon" : @"mine_help", @"title" : LocalString(@"帮助中心"), @"toVC" : @"FamailyManageVC"},
    [self.itemArray addObjectsFromArray:arr];
    [self setupUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchHome:) name:@"SwitchHome" object:nil];
}

//获取用户信息
- (void)updateUserInfo {
    WEAK_SELF
    [[ThingSmartUser sharedInstance] updateUserInfo:^{
           NSLog(@"update userInfo success");
        weakSelf.nameLabel.text = [PublicObj isEmptyObject:[ThingSmartUser sharedInstance].nickname] ? @"Talenpal" : [ThingSmartUser sharedInstance].nickname;
        weakSelf.emailLabel.text = [ThingSmartUser sharedInstance].email;
       } failure:^(NSError *error) {
           NSLog(@"update userInfo failure: %@", error);
       }];
    //用户头像 sass接口
    [[APIManager shared] GET:[APIPortConfiguration getAppAvatarUrl] parameter:nil success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        AvatarModel *model = [AvatarModel mj_objectWithKeyValues:data];
        [weakSelf.headImgView sd_setImageWithURL:[NSURL URLWithString:model.avatarUrl] placeholderImage:QD_IMG(@"lanch_logo")];
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        
    }];
}


#pragma mark -- UI
- (void)setupUI {
    self.view.backgroundColor = tableBgColor;
    _tableView.tableHeaderView = self.headerView;
    _tableView.tableFooterView = [UIView new];
    _tableView.sectionHeaderHeight = 15;
    _tableView.sectionFooterHeight = 0;
    _tableView.estimatedRowHeight = 72;
    [_tableView registerNib:[UINib nibWithNibName:@"MineListCell" bundle:nil] forCellReuseIdentifier:@"MineListCell"];
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
}

-(void)switchHome:(NSNotification *)noti{
    self.homeId = [noti.object longLongValue];
    [self initCurrentHome];
}

//点击头像进入个人信息页面
- (IBAction)userInfoBtnClick:(id)sender {
    PersonalInformationVC *VC = [PersonalInformationVC new];
    VC.title = LocalString(@"个人信息");
    [self.navigationController pushViewController:VC animated:YES];
}


- (void)initCurrentHome {
    // 注册要实现的协议
    [[ThingSmartBizCore sharedInstance] registerService:@protocol(ThingSmartHomeDataProtocol) withInstance:self];
}

// 实现对应的协议方法
- (ThingSmartHome *)getCurrentHome {
    ThingSmartHome *home = [ThingSmartHome homeWithHomeId:self.homeId];
    return home;
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MineListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MineListCell"];
    NSDictionary *dic = self.itemArray[indexPath.row];
    cell.titleLabel.text = dic[@"title"];
    cell.iconView.image = [UIImage imageNamed:dic[@"icon"]];
    cell.indexPath = indexPath;
    cell.rowInSection = self.itemArray.count;
    if ([dic[@"title"] isEqualToString:LocalString(@"消息中心")]) {
        if ([self.unreadCount integerValue] > 0) {
            cell.redPointView.hidden = NO;
            cell.numLabel.text = [NSString stringWithFormat:@"%@",self.unreadCount];
        }else{
            cell.redPointView.hidden = YES;
        }
        
    }else{
        cell.redPointView.hidden = YES;
    }
    return cell;
}

#pragma mark -- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    kPreventRepeatClickTime(0.5);
     NSDictionary *dic = self.itemArray[indexPath.row];
     NSString *title = dic[@"title"];
     NSString *str = dic[@"toVC"];
    if (![ThingSmartUser sharedInstance].isLogin) {
        [UserInfo showLogin];
        return;
    }
    if([title isEqualToString:LocalString(@"消息中心")]){
        id<ThingMessageCenterProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingMessageCenterProtocol)];
            [impl gotoMessageCenterViewControllerWithAnimated:YES];
    }else if ([title isEqualToString:LocalString(@"帮助中心")]){
        id<ThingHelpCenterProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingHelpCenterProtocol)];

        [impl gotoHelpCenter];
    }else{
        UIViewController* vc = [NSString stringChangeToClass:str];
        vc.title = title;
        if (vc) {
            [self.navigationController pushViewController:vc animated:YES];
        }
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
