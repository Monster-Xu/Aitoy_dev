//
//  UserPermmitVC.m
//  AIToys
//
//  Created by qdkj on 2025/7/9.
//

#import "UserPermmitVC.h"
#import "UserPermmitCell.h"
#import "MyTabBarController.h"
#import "AppSettingModel.h"
#import "AnalyticsManager.h"

@interface UserPermmitVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *enterBtn;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, strong) NSMutableArray <MineItemModel *>*selcArr;
@property (nonatomic, strong) AppSettingModel  *model;
@end

@implementation UserPermmitVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hj_NavIsHidden = YES;
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.backgroundColor = tableBgColor;
    [self.tableView registerNib:[UINib nibWithNibName:@"UserPermmitCell" bundle:nil] forCellReuseIdentifier:@"UserPermmitCell"];
    NSArray *arr = @[
        @{@"title" : LocalString(@"功能体验升级计划"),@"value" :LocalString(@"允许我们收集与产品使用相关的数据，如果禁用权限，基本功能仍然可用，基于数据偏好提供的体验优化策略将会失效。")},
        @{@"title" : LocalString(@"个性化推送服务"),@"value" :LocalString(@"允许我们向您推荐您感兴趣的场景、商品、服务等内容，来提升您的智能产品的使用体验。若您对该类内容不感兴趣，可以选择关闭本项服务，我们将不再将您的信息使用于该推荐功能。")}
    ];
    self.selcArr = [NSMutableArray arrayWithArray:[MineItemModel mj_objectArrayWithKeyValuesArray:arr]];
    self.selcArr[0].isOn = YES;
    self.selcArr[1].isOn = YES;
    // 加载权限数据
    [self loadPermissionData];
    [self.enterBtn setTitle:LocalString(@"进入APP") forState:0];
//    [CoreArchive setBool:YES key:KISAgreeImprovement];
//    [CoreArchive setBool:YES key:KISAgreeRecommendations];
}

- (void)loadPermissionData {
    WEAK_SELF

    // 加载功能体验升级计划权限
    [[AnalyticsManager sharedManager] loadUserPermissionsWithCompletion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                // 从缓存读取状态
                BOOL isEnabled = [[AnalyticsManager sharedManager] isAnalyticsEnabled];
                weakSelf.selcArr[0].isOn = isEnabled;
            }
            // 无论成功失败都要加载个性化推送服务权限
            [weakSelf loadDataWithKey:@"2"];
        });
    }];
}

- (void)loadDataWithKey:(NSString *)key{
    // 只处理个性化推送服务(key="2")，功能体验升级计划由AnalyticsManager处理
    if (![key isEqualToString:@"2"]) {
        return;
    }

    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:key forKey:@"propKey"];
    WEAK_SELF
    [[APIManager shared] GET:[APIPortConfiguration getAppPropertyByKeyUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        if ([data isKindOfClass:NSDictionary.class]){
            weakSelf.model = [AppSettingModel mj_objectWithKeyValues:data];
            weakSelf.selcArr[1].isOn = [weakSelf.model.propValue isEqualToString:@"1"];
            [weakSelf.tableView reloadData];
        }

    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {

    }];
}

//进入APP
- (IBAction)enterBtnClick:(id)sender {
    MyTabBarController *tabbar = [MyTabBarController new];
    [UIApplication sharedApplication].keyWindow.rootViewController = tabbar;
    
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selcArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserPermmitCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserPermmitCell" forIndexPath:indexPath];
    cell.model = self.selcArr[indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selcArr[indexPath.row].isOn = !self.selcArr[indexPath.row].isOn;
    if(indexPath.row == 0){
        // 功能体验升级计划 - 控制埋点开关
        BOOL isEnabled = self.selcArr[indexPath.row].isOn;

        // 使用新的API同步埋点开关状态（包含缓存和服务器更新）
        [[AnalyticsManager sharedManager] setAnalyticsEnabled:isEnabled completion:^(BOOL success) {
            if (success) {
                NSLog(@"[UserPermmitVC] 埋点开关设置成功: %@", isEnabled ? @"启用" : @"禁用");
            } else {
                NSLog(@"[UserPermmitVC] 埋点开关设置失败");
                // 如果设置失败，恢复UI状态
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.selcArr[indexPath.row].isOn = !isEnabled;
                    [self.tableView reloadData];
                });
            }
        }];
        
    }else{
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
//        [param setValue:@"8802" forKey:@"id"];
        [param setValue:[PublicObj isEmptyObject:kMyUser.userId]? @"": kMyUser.userId forKey:@"memberUserId"];
        [param setValue:@"2" forKey:@"propKey"];
        [param setValue:self.selcArr[indexPath.row].isOn ? @"1": @"0" forKey:@"propValue"];
        [param setValue:@"个性化推送服务" forKey:@"description"];
        [self modifySettingWithParam:param];
    }
    [self.tableView reloadData];
    
}

- (void)modifySettingWithParam:(NSDictionary *)param{
    WEAK_SELF
    [[APIManager shared] POSTJSON:[APIPortConfiguration getAppPropertyCreateUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        
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
