//
//  FindDeviceViewController.m
//  AIToys
//
//  Created by qdkj on 2025/6/27.
//

#import "FindDeviceViewController.h"
#import "FindDeviceAlertCell.h"
#import "FindDeviceNoBluetoothCell.h"
#import "DeviceFindingCell.h"
#import "DeviceUnfindCell.h"
#import "DeviceHavenFindCell.h"
#import "DeviceManuallyAddCell.h"
#import "GuideOpenBluetoothVC.h"
#import "GuideOpenWifiVC.h"
#import "SetupDeviceVC.h"
#import "DeviceAddVC.h"
#import "GlobalBluetoothManager.h"
#import "FindDollModel.h"
#import "AnalyticsManager.h"
#import "SelectWifiVC.h"

@interface FindDeviceViewController ()<UITableViewDelegate,UITableViewDataSource,RYFTableViewDelegate,ThingSmartBLEManagerDelegate,ThingSmartBLEWifiActivatorDelegate>
@property (nonatomic, strong)RYFTableView *tableView;
@property (nonatomic, strong)NSMutableArray *checkPermmitionArr;

@property (nonatomic, assign)NSInteger scanStatus;//0.扫描中 1.找到设备 2.超时未找到
@property (nonatomic, assign)BOOL bluetoothIsOpen;
@property (nonatomic, assign)BOOL wifiIsOpen;
@property (nonatomic, assign)BOOL isFirstAlertBluetooth;//是否是初次检测蓝牙
@property (nonatomic, strong)NSTimer *timer;//扫描定时器
@property (nonatomic, strong)NSMutableArray <ThingBLEAdvModel *> *deviceList;//扫描到的设备
@property (nonatomic, strong)NSMutableArray  *deviceInfoList;//设备名称信息

@property (nonatomic, strong)NSMutableArray <FindDollModel *> *recommendDeviceList;//推荐的设备
@property(nonatomic,assign)NSInteger selectIndex;
@end

@implementation FindDeviceViewController
-(NSMutableArray *)checkPermmitionArr{
    if(!_checkPermmitionArr){
        _checkPermmitionArr = [NSMutableArray array];
    }
    return _checkPermmitionArr;
}

-(NSMutableArray *)deviceList{
    if(!_deviceList){
        _deviceList = [NSMutableArray array];
    }
    return _deviceList;
}

-(NSMutableArray *)deviceInfoList{
    if(!_deviceInfoList){
        _deviceInfoList = [NSMutableArray array];
    }
    return _deviceInfoList;
}

-(NSMutableArray *)recommendDeviceList{
    if(!_recommendDeviceList){
        _recommendDeviceList = [NSMutableArray array];
    }
    return _recommendDeviceList;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //蓝牙监听
//    [GlobalBluetoothManager sharedManager];
    self.isFirstAlertBluetooth = YES;
    self.wifiIsOpen = [APIManager shared].netStatus == NetStatus_WiFi;
    self.bluetoothIsOpen = [GlobalBluetoothManager sharedManager].isOpen;
    if(!self.bluetoothIsOpen){
        //蓝牙未开启
        [self chenckBluetoothAlert];
    }else{
        // 开始扫描设备
        [self startScan];
    }
    [self setupUI];
    [self getData];
    // 设置代理
    [ThingSmartBLEManager sharedInstance].delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiHavenOpen) name:NetworkReachableWifi object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothStateChanged:) name:@"BluetoothStateChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(faildBack) name:@"faildBackChange" object:nil];
    
    [self setupPemissionData];
}

-(void)dealloc{
    //停止扫描
    [self endScan];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NetworkReachableWifi object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BluetoothStateChanged" object:nil];
}

//获取数据
- (void)getData{
//    WEAK_SELF
//    [[APIManager shared] GET:[APIPortConfiguration getDoolModelListUrl] parameter:nil success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
//        NSArray *dataArr = data;
//        weakSelf.recommendDeviceList = [NSMutableArray arrayWithArray:[FindDollModel mj_objectArrayWithKeyValuesArray:dataArr]];
//        [weakSelf.tableView reloadData];
//    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
//        
//    }];
}

//- (void)getToken {
//        ThingSmartActivator *ezActivator = [[ThingSmartActivator alloc] init];
//    [ezActivator getTokenWithHomeId:self.homeId success:^(NSString *token) {
//        NSLog(@"getToken success: %@", token);
//        // 设置代理
//        [ThingSmartBLEManager sharedInstance].delegate = self;
//    } failure:^(NSError *error) {
//        NSLog(@"getToken failure: %@", error.localizedDescription);
//    }];
//}
 
-(void)setupUI{
    self.title = LocalString(@"添加设备");
    self.tableView.loadState = RYFCanLoadNone;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

//权限数组更新
-(void)setupPemissionData{
    [self.checkPermmitionArr removeAllObjects];
    if(!self.bluetoothIsOpen ){
        [self.checkPermmitionArr addObject:@(1)];
    }
    if(!self.wifiIsOpen ){
        [self.checkPermmitionArr addObject:@(0)];
    }
    
    [self.tableView reloadData];
}

//开始扫描
-(void)startScan{
    self.scanStatus = 0;
    [self.deviceList removeAllObjects];
    [self.deviceInfoList removeAllObjects];
    // 开始扫描
//    [[ThingSmartBLEManager sharedInstance] startListening:YES];
    //使用以下方法 开始扫描
    [[ThingSmartBLEManager sharedInstance] startListeningWithType:ThingBLEScanTypeNoraml cacheStatu:YES];
    [self setUpTimmer];
    [self.tableView reloadData];
}

//停止扫描
-(void)endScan{
    // 结束扫描
    [[ThingSmartBLEManager sharedInstance] stopListening:YES];
    [self.timer invalidate];
}


//扫描倒计时
- (void)setUpTimmer{
    WEAK_SELF
    __block int timeValue = 90;
    self.timer = [NSTimer timerWithTimeInterval:1.0 block:^(NSTimer * _Nonnull timer) {
        
        if (timeValue > 0) {
            timeValue--;
        }else if (timeValue == 0){
            //超时未找到
            [timer invalidate];
            timeValue = 90;
            weakSelf.scanStatus = 2;
            [[ThingSmartBLEManager sharedInstance] stopListening:YES];
            [weakSelf.tableView reloadData];
        }
    } repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.scanStatus==0 ? 1 :0;
            break;
        case 1:
            return self.checkPermmitionArr.count;
            
            break;
        case 2:
            return 1;
            break;
            
        default:
            return 1;
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 2:
            return 400;
            break;
            
        default:
            return 70;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WEAK_SELF
    if(indexPath.section == 0){
        FindDeviceAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FindDeviceAlertCell" forIndexPath:indexPath];
        cell.clickBlock = ^{
            [weakSelf.tableView reloadData];
        };
        return cell;
    }else if(indexPath.section == 1){
        FindDeviceNoBluetoothCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FindDeviceNoBluetoothCell" forIndexPath:indexPath];
        cell.isBluetooth = [self.checkPermmitionArr[indexPath.row] intValue];
        return cell;
    }else if(indexPath.section == 2){
        if(self.scanStatus == 1){
            DeviceHavenFindCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceHavenFindCell" forIndexPath:indexPath];
            cell.deviceList = self.deviceList;
            cell.itemClickBlock = ^(NSInteger index) {
                weakSelf.selectIndex = index;
                [self loadWifiDataWithDeviceInfo:weakSelf.deviceList[index]];
                
            };
            return cell;
        }else if(self.scanStatus == 2){
            DeviceUnfindCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceUnfindCell" forIndexPath:indexPath];
            cell.tryBlock = ^{
                [weakSelf startScan];
            };
            return cell;
        }else{
            DeviceFindingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceFindingCell" forIndexPath:indexPath];
            return cell;
        }
    }else{
        WEAK_SELF
        DeviceManuallyAddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceManuallyAddCell" forIndexPath:indexPath];
        cell.dataArr = self.recommendDeviceList;
        cell.devicebtnClickClickBlock = ^{
            // 埋点上报：手动添加设备点击
            NSString *productId = @"";

            // 优先从扫描到的设备中获取productId
            if (weakSelf.deviceList.count > 0) {
                // 如果有扫描到的设备，使用第一个设备的productId
                ThingBLEAdvModel *firstDevice = weakSelf.deviceList.firstObject;
                productId = firstDevice.productId ?: @"";
            } else if (weakSelf.deviceInfoList.count > 0) {
                // 如果有设备信息，从设备信息中获取productId
                NSDictionary *deviceInfo = weakSelf.deviceInfoList.firstObject;
                NSDictionary *result = deviceInfo[@"result"];
                productId = result[@"productId"] ?: @"";
            }

            // 如果仍然没有获取到productId，使用默认值
            if ([productId isEqualToString:@""]) {
                productId = DEVICE_PRODUCT_ID;
            }

            [[AnalyticsManager sharedManager] reportAddDeviceManualClickWithPid:productId];

            SetupDeviceVC *VC = [SetupDeviceVC new];
            MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:VC];
            VC.clickBlock = ^{
                [weakSelf.tableView reloadData];
            };
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [weakSelf presentViewController:nav animated:NO completion:nil];
            
//            DeviceAddVC *VC = [DeviceAddVC new];
//            VC.homeId = weakSelf.homeId;
//            [weakSelf.navigationController pushViewController:VC animated:YES];
        };
        return cell;
    }
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WEAK_SELF
    if(indexPath.section == 1){
        if ([self.checkPermmitionArr[indexPath.row] intValue] == 1) {
            GuideOpenBluetoothVC *VC = [GuideOpenBluetoothVC new];
            VC.modalPresentationStyle = UIModalPresentationOverFullScreen;
            VC.clickBlock = ^{
                [weakSelf jumpToSetting];
            };
            [self presentViewController:VC animated:NO completion:nil];
        }else{
            GuideOpenWifiVC *VC = [GuideOpenWifiVC new];
            VC.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:VC animated:NO completion:nil];
        }
    }
    
}

#pragma mark -- ThingSmartBLEManagerDelegate
/**
 * 扫描到未激活的设备
 *
 * @param deviceInfo 未激活设备信息 Model
 */
- (void)didDiscoveryDeviceWithDeviceInfo:(ThingBLEAdvModel *)deviceInfo {
    // 成功扫描到未激活的设备
    // 若设备已激活，则不会走此回调，且会自动进行激活连接
    NSLog(@"发现设备：%@",deviceInfo.uuid);
    for (ThingBLEAdvModel *item in self.deviceList) {
        if([deviceInfo.uuid isEqualToString:item.uuid]){
            return;
        }
    }
    [self.deviceList addObject:deviceInfo];
    self.scanStatus = 1;
    WEAK_SELF
    [[ThingSmartBLEManager sharedInstance] queryDeviceInfoWithUUID:deviceInfo.uuid productId:deviceInfo.productId success:^(NSDictionary *dict) {
        // 查询设备信息成功
        /*
         data = {
           "result" : {
             "supportProductReplace" : false,
             "productId" : "1xlikniqwnensmov",
             "appExcluded" : false,
             "bindLevel" : 1,
             "supportPlugPlay" : false,
             "whetherHasAuth" : true,
             "support5G" : false,
             "icon" : "https:\/\/images.tuyacn.com\/smart\/icon\/non-session-user\/eezgvi7n708w.jpg",
             "name" : "Talenpal Toy"
           },
           "success" : true,
           "status" : "ok",
           "t" : 1751417641527
         }
         **/
        [weakSelf.deviceInfoList addObject:dict];
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
    
}


- (void)bluetoothStateChanged:(NSNotification *)notification {
    NSInteger state = [notification.object intValue];
    self.bluetoothIsOpen =  state;
//    if(!self.bluetoothIsOpen && self.isFirstAlertBluetooth){
//        //蓝牙未开启
//        [self chenckBluetoothAlert];
//    }
    [self setupPemissionData];
    if(self.bluetoothIsOpen){
        // 开始扫描
        [self startScan];
    }else{
        // 结束扫描
        [self endScan];
    }
    NSLog(@"蓝牙状态变更：%ld", state);
}

//已经打开wifi
- (void)wifiHavenOpen{
    self.wifiIsOpen = YES;
    [self setupPemissionData];
}
//失败返回
-(void)faildBack{
    [self startScan];
}
//检查蓝牙弹窗
- (void)chenckBluetoothAlert{
    WEAK_SELF
    GuideOpenBluetoothVC *VC = [GuideOpenBluetoothVC new];
    VC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    VC.clickBlock = ^{
        [weakSelf jumpToSetting];
    };
    [self presentViewController:VC animated:NO completion:^{
        if(!weakSelf.wifiIsOpen && weakSelf.isFirstAlertBluetooth){
            weakSelf.isFirstAlertBluetooth = NO;
            [weakSelf chenckWifiAlert];
        }
    }];
}

//检查Wifi弹窗
- (void)chenckWifiAlert{
    WEAK_SELF
    GuideOpenWifiVC *VC = [GuideOpenWifiVC new];
    VC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:VC animated:NO completion:nil];
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

//获取wifi列表
-(void)loadWifiDataWithDeviceInfo:(ThingBLEAdvModel *)deviceInfo{
    
    [SVProgressHUD showWithStatus:@"正在寻找可用WiFi...."];
    [ThingSmartBLEWifiActivator sharedInstance].bleWifiDelegate = self;
    [[ThingSmartBLEWifiActivator sharedInstance] connectAndQueryWifiListWithUUID:deviceInfo.uuid success:^{
      // 指令下发成功
        NSLog(@"指令下发成功");
    } failure:^(NSError *error) {
      // 指令下发失败
        NSLog(@"指令下发失败");
        [SVProgressHUD showErrorWithStatus:error.description];
//        self.status = AddStatusType_default;
        [self.tableView reloadData];
    }];
}


#pragma mark -- ThingSmartBLEWifiActivatorDelegate

- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator notConfigStateWithError:(NSError *)error {
  // 设备不在配网状态
    NSLog(@"！！！！设备不在配网状态");
    [SVProgressHUD showErrorWithStatus:error.description];
//    self.status = AddStatusType_fail;
//    [self.tableView reloadData];
}

- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator didScanWifiList:(NSArray *)wifiList uuid:(NSString *)uuid error:(nonnull NSError *)error{
    [SVProgressHUD dismiss];
//    self.status = AddStatusType_default;
//    [self.tableView reloadData];
    if (error) {
    // Wi-Fi 列表扫描失败
        NSLog(@"Wi-Fi 列表扫描失败");
    } else {
    // Wi-Fi 列表扫描成功
        NSLog(@"Wi-Fi 列表扫描成功");



        SelectWifiVC *VC = [SelectWifiVC new];
        VC.UUID = self.deviceList[self.selectIndex].uuid;
        VC.homeId = self.homeId;
        VC.wifiArr = wifiList;
        [self.navigationController pushViewController:VC animated:YES];
    }
}


- (RYFTableView *)tableView{
    if (!_tableView) {
        _tableView = [[RYFTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.tableViewDelegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableView.estimatedRowHeight = 55;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 15)];
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 0;
        _tableView.backgroundColor = UIColor.whiteColor;
        [_tableView registerNib:[UINib nibWithNibName:@"FindDeviceAlertCell" bundle:nil] forCellReuseIdentifier:@"FindDeviceAlertCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"FindDeviceNoBluetoothCell" bundle:nil] forCellReuseIdentifier:@"FindDeviceNoBluetoothCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"DeviceFindingCell" bundle:nil] forCellReuseIdentifier:@"DeviceFindingCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"DeviceUnfindCell" bundle:nil] forCellReuseIdentifier:@"DeviceUnfindCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"DeviceHavenFindCell" bundle:nil] forCellReuseIdentifier:@"DeviceHavenFindCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"DeviceManuallyAddCell" bundle:nil] forCellReuseIdentifier:@"DeviceManuallyAddCell"];
    }
    return _tableView;
}

@end
