//
//  PrivateSettingViewController.m
//  AIToys
//
//  Created by qdkj on 2025/7/17.
//

#import "PrivateSettingViewController.h"
#import "PrivateSettingCell.h"
#import "AccessPermissionsSettingCell.h"
#import "GlobalBluetoothManager.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>
#import "AppSettingModel.h"
#import "AnalyticsManager.h"

@interface PrivateSettingViewController ()<UITableViewDelegate,UITableViewDataSource,RYFTableViewDelegate>
@property (nonatomic, strong)RYFTableView *tableView;
@property (nonatomic, strong) NSMutableArray <MineItemModel *>*itemArray;
@property (nonatomic, assign)BOOL enablePush;
@end

@implementation PrivateSettingViewController

-(NSMutableArray *)itemArray{
    if (!_itemArray) {
        _itemArray = [NSMutableArray array];
    }
    return _itemArray;
}

- (RYFTableView *)tableView{
    if (!_tableView) {
        _tableView = [[RYFTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.tableViewDelegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 64;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 12)];
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 12;
        _tableView.backgroundColor = tableBgColor;
        [_tableView registerNib:[UINib nibWithNibName:@"PrivateSettingCell" bundle:nil] forCellReuseIdentifier:@"PrivateSettingCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"AccessPermissionsSettingCell" bundle:nil] forCellReuseIdentifier:@"AccessPermissionsSettingCell"];
    }
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self checkPushenable];
    [self checkLocation];
}
- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self setupUI];
    //蓝牙监听
//    [GlobalBluetoothManager sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothStateChanged:) name:@"BluetoothStateChanged" object:nil];
}

-(void)setupUI{
    self.tableView.loadState = RYFCanLoadNone;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

//蓝牙状态变通知
- (void)bluetoothStateChanged:(NSNotification *)notification {
    NSInteger state = [notification.object intValue];
    NSLog(@"蓝牙状态变更：%ld", state);
    if(self.itemArray.count > 0){
        self.itemArray[3].isOn = [GlobalBluetoothManager sharedManager].isAuthorized;
        [self.tableView reloadData];
    }
}

-(void)loadData{
    NSArray *arr = @[
        @{@"title" : LocalString(@"功能体验升级计划"),@"value" :LocalString(@"允许我们收集与产品使用相关的数据，如果禁用权限，基本功能仍然可用，基于数据偏好提供的体验优化策略将会失效。")},
        @{@"title" : LocalString(@"个性化推送服务"),@"value" :LocalString(@"允许我们向您推荐您感兴趣的场景、商品、服务等内容，来提升您的智能产品的使用体验。若您对该类内容不感兴趣，可以选择关闭本项服务，我们将不再将您的信息使用于该推荐功能。")},
        @{@"title" : LocalString(@"访问通知权限"),@"value" :LocalString(@"用于接收设备告警、系统通知等消息。")},
        @{@"title" : LocalString(@"蓝牙访问权限"),@"value" :LocalString(@"在使用过程中，本应用需要访问蓝牙权限，用户发现附近的蓝牙设备。")},
        @{@"title" : LocalString(@"访问地理位置"),@"value" :LocalString(@"用于判断地区、设备添加、获取Wi-Fi列表、场景自动化等功能。")},
        ];
    self.itemArray = [NSMutableArray arrayWithArray:[MineItemModel mj_objectArrayWithKeyValuesArray:arr]];
    self.itemArray[0].isOn = YES;
    self.itemArray[1].isOn = YES;
    self.itemArray[2].isOn = self.enablePush;
    self.itemArray[3].isOn = [GlobalBluetoothManager sharedManager].isAuthorized;
    [self getDataWithKey:@"1"];
    [self getDataWithKey:@"2"];
//    WEAK_SELF
//    [[ThingSmartSDK sharedInstance] getPushStatusWithSuccess:^(BOOL result) {
//        // 当 result == YES 时，表示推送开关开启
//        NSLog(@"推送查询状态为：%@",result?@"开":@"关");
//        weakSelf.itemArray[1].isOn = result;
//        [weakSelf.tableView reloadData];
//    } failure:^(NSError *error) {
//        [weakSelf.tableView reloadData];
//    }];
}

- (void)getDataWithKey:(NSString *)key{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:key forKey:@"propKey"];
    WEAK_SELF
    [[APIManager shared] GET:[APIPortConfiguration getAppPropertyByKeyUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        if ([data isKindOfClass:NSDictionary.class]){
            AppSettingModel *model = [AppSettingModel mj_objectWithKeyValues:data];
            if([key isEqualToString:@"1"]){
                weakSelf.itemArray[0].isOn = [model.propValue isEqualToString:@"1"];
            }
            if([key isEqualToString:@"2"]){
                weakSelf.itemArray[1].isOn = [model.propValue isEqualToString:@"1"];
            }
            [weakSelf.tableView reloadData];
        }
        
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        
    }];
}


#pragma mark -- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.itemArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MineItemModel *model = self.itemArray[indexPath.section];
    WEAK_SELF
    if(indexPath.section < 2){
        PrivateSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrivateSettingCell"];
        cell.model = model;
        cell.switchChangeBlock = ^(BOOL on) {
            model.isOn = on;
            if(indexPath.section == 0){
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setValue:[PublicObj isEmptyObject:kMyUser.userId]? @"": kMyUser.userId forKey:@"memberUserId"];
                [param setValue:@"1" forKey:@"propKey"];
                [param setValue:on ? @"1": @"0" forKey:@"propValue"];
                [param setValue:@"功能体验升级计划" forKey:@"description"];
                [weakSelf modifySettingWithParam:param];
            }else{
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setValue:[PublicObj isEmptyObject:kMyUser.userId]? @"": kMyUser.userId forKey:@"memberUserId"];
                [param setValue:@"2" forKey:@"propKey"];
                [param setValue:on ? @"1": @"0" forKey:@"propValue"];
                [param setValue:@"个性化推送服务" forKey:@"description"];
                [self modifySettingWithParam:param];
            }
//            [[ThingSmartSDK sharedInstance] setPushStatusWithStatus:on  success:^{
//                // 设置成功
//                model.isOn = on;
//                [weakSelf.tableView reloadData];
//                NSLog(@"推送设置状态为：%@",on?@"开":@"关");
//            } failure:^(NSError *error) {
//                
//            }];
            
        };
        return cell;
    }else{
        AccessPermissionsSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccessPermissionsSettingCell"];
        cell.model = model;
        return cell;
    }
    
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    kPreventRepeatClickTime(0.5);
    if(indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4){
//        if(!self.itemArray[indexPath.section].isOn){
            [self jumpToSetting];
//        }
    }
    
}

//修改用户改善计划
- (void)modifySettingWithParam:(NSDictionary *)param{
    WEAK_SELF
    [[APIManager shared] POSTJSON:[APIPortConfiguration getAppPropertyCreateUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {

        // 如果是功能体验升级计划(propKey="1")，立即更新AnalyticsManager的缓存
        NSString *propKey = param[@"propKey"];
        if ([propKey isEqualToString:@"1"]) {
            NSString *propValue = param[@"propValue"];
            BOOL isEnabled = [propValue isEqualToString:@"1"];
            [[AnalyticsManager sharedManager] setAnalyticsEnabled:isEnabled];
            NSLog(@"[PrivateSettingViewController] 立即更新埋点缓存状态: %@", isEnabled ? @"启用" : @"禁用");
        }

        [weakSelf.tableView reloadData];

    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {

    }];
}

//跳转到设置界面
- (void)jumpToSetting{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            if(success){
                NSLog(@"跳转到设置成功");
            }else{
                NSLog(@"跳转到设置失败");
            }
        }];
    }
}


- (void)applicationWillEnterForeground:(NSNotification *)notification {
    // 应用即将进入前台时执行操作
    [self checkPushenable];
    [self checkLocation];
}

- (void)checkPushenable{
    WEAK_SELF
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            NSLog(@"通知已授权");
            weakSelf.enablePush = YES;
        } else if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
            NSLog(@"用户尚未决定是否授权通知");
            weakSelf.enablePush = NO;
        } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
            NSLog(@"通知被拒绝");
            weakSelf.enablePush = NO;
        } else if (settings.authorizationStatus == UNAuthorizationStatusProvisional) {
            NSLog(@"通知权限是临时的");
            weakSelf.enablePush = YES;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(weakSelf.itemArray.count > 0){
                weakSelf.itemArray[2].isOn = self.enablePush;
                [weakSelf.tableView reloadData];
            }
            
        });
    }];
    
}

- (void)checkLocation{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        // 用户已经授权，可以访问位置信息
        NSLog(@"用户已授权访问位置信息");
        if(self.itemArray.count > 0){
            self.itemArray[4].isOn = YES;
            [self.tableView reloadData];
        }
        
        
    } else {
        // 用户未授权，或者尚未询问过用户
        NSLog(@"用户未授权访问位置信息");
        if(self.itemArray.count > 0){
            self.itemArray[4].isOn = NO;
            [self.tableView reloadData];
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
