//
//  FamailyManageVC.m
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import "FamailyManageVC.h"
#import "FamailyManageCell.h"
#import "FamailySettingVC.h"
#import "CreateFamailyVC.h"
#import "JoinFamailyVC.h"
#import "FamailyOperationCell.h"

@interface FamailyManageVC ()<UITableViewDelegate,UITableViewDataSource,RYFTableViewDelegate,ThingSmartHomeManagerDelegate>
@property (weak, nonatomic) IBOutlet RYFTableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic,strong) UIButton *createBtn;
@property (nonatomic,strong) UIButton *joinBtn;
@property(strong, nonatomic) ThingSmartHomeManager *homeManager;
@property(strong, nonatomic) NSMutableArray<ThingSmartHomeModel *> *homeList;
@end

@implementation FamailyManageVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadDataRefreshOrPull:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    [self setupUI];
}

- (void)loadDataRefreshOrPull:(RYFRefreshType)type {
    [self showHud];
    [self.homeManager getHomeListWithSuccess:^(NSArray<ThingSmartHomeModel *> *homes) {
        [self hiddenHud];
        self.homeList = [homes mutableCopy];
        [self.tableView endLoading];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self hiddenHud];
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
    
}

-(void)setupUI{
    self.titleLabel.text = LocalString(@"家庭管理");
    self.tableView.tableViewDelegate = self;
    self.tableView.estimatedRowHeight = 55;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 15)];
    self.tableView.sectionHeaderHeight = 20;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.backgroundColor = tableBgColor;
    [self.tableView registerNib:[UINib nibWithNibName:@"FamailyManageCell" bundle:nil] forCellReuseIdentifier:@"FamailyManageCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FamailyOperationCell" bundle:nil] forCellReuseIdentifier:@"FamailyOperationCell"];
    self.tableView.loadState = RYFCanLoadRefresh;
}

//创建家庭
-(void)createFamily{
    CreateFamailyVC *VC = [CreateFamailyVC new];
    [self.navigationController pushViewController:VC animated:YES];
}

//加入家庭
-(void)joinFamily{
    JoinFamailyVC *VC = [JoinFamailyVC new];
    [self.navigationController pushViewController:VC animated:YES];
    
}
#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.homeList.count :1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        FamailyManageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FamailyManageCell" forIndexPath:indexPath];
        cell.rowInSection = self.homeList.count;
        cell.indexPath = indexPath;
        cell.model = self.homeList[indexPath.row];
        return cell;
    }else{
        FamailyOperationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FamailyOperationCell" forIndexPath:indexPath];
        cell.nameLabel.text = indexPath.section == 1? LocalString(@"创建一个家庭") :LocalString(@"加入一个家庭");
        return cell;
    }
    
}
- (IBAction)backBtnClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(self.homeList[indexPath.row].dealStatus == 1){
            WEAK_SELF
            [LGBaseAlertView showAlertWithTitle:LocalString(@"加入家庭邀请") content:[NSString stringWithFormat:@"%@%@%@",LocalString(@"您有一个加入"),self.homeList[indexPath.row].name,LocalString(@"家庭的邀请，是否同意加入？")] cancelBtnStr:LocalString(@"暂不加入") confirmBtnStr:LocalString(@"加入家庭") confirmBlock:^(BOOL isValue, id obj) {
                ThingSmartHome *home = [ThingSmartHome homeWithHomeId:weakSelf.homeList[indexPath.row].homeId];
                if (isValue){
                    [weakSelf showHud];
                    ///接受邀请
                    [home joinFamilyWithAccept:YES success:^(BOOL result) {
                        [weakSelf hiddenHud];
                        [SVProgressHUD showSuccessWithStatus:LocalString(@"已加入家庭")];
                        [weakSelf loadDataRefreshOrPull:1];
                    } failure:^(NSError *error) {
                        [weakSelf hiddenHud];
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }];
                }else{
                    [home joinFamilyWithAccept:NO success:^(BOOL result) {
                        [weakSelf loadDataRefreshOrPull:1];
                    } failure:^(NSError *error) {
                        
                    }];
                }
            }];
        }else{
            FamailySettingVC *VC = [FamailySettingVC new];
            VC.homeModel = self.homeList[indexPath.row];
            VC.isSignalHome = self.homeList.count == 1;
            [self.navigationController pushViewController:VC animated:YES];
        }
    }
    
    if(indexPath.section == 1){
        [self createFamily];
    }
    if(indexPath.section == 2){
        [self joinFamily];
    }
    
}

#pragma mark - ThingSmartHomeManagerDelegate

// 添加一个家庭
- (void)homeManager:(ThingSmartHomeManager *)manager didAddHome:(ThingSmartHomeModel *)home {

}

// 删除一个家庭
- (void)homeManager:(ThingSmartHomeManager *)manager didRemoveHome:(long long)homeId {

}

// MQTT 连接成功
- (void)serviceConnectedSuccess {
    // 去云端查询当前家庭的详情，然后去刷新 UI
}


- (NSMutableArray<ThingSmartHomeModel *> *)homeList {
    if (!_homeList) {
        _homeList = [[NSMutableArray alloc] init];
    }
    return _homeList;
}

- (ThingSmartHomeManager *)homeManager {
    if (!_homeManager) {
        _homeManager = [[ThingSmartHomeManager alloc] init];
        _homeManager.delegate = self;
    }
    return _homeManager;
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
