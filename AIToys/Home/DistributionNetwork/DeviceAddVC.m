//
//  DeviceAddVC.m
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import "DeviceAddVC.h"
#import "ExitView.h"
#import "SelectWifiVC.h"
#import "ATFontManager.h"

@interface DeviceAddVC ()<UITableViewDataSource,UITableViewDelegate,ThingSmartHomeDelegate,ThingSmartBLEWifiActivatorDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)CGFloat progress;
@property(strong, nonatomic) ThingSmartHome *home;
@property(copy, nonatomic) NSString *deviceId;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, assign) BOOL ispwdError;//是否是wifi密码错误
@end

@implementation DeviceAddVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.titleLab.text = LocalString(@"添加设备");
    [self.doneBtn setTitle:LocalString(@"完成") forState:0];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 15)];
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.backgroundColor = UIColor.clearColor;
    [self.tableView registerNib:[UINib nibWithNibName:@"DeviceAddCell" bundle:nil] forCellReuseIdentifier:@"DeviceAddCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceConnectStart:) name:@"DeviceConnectStart" object:nil];
    [PublicObj makeButtonUnEnable:self.doneBtn];
    [self initHome];
    [self getToken];
}

//获取wifi列表
-(void)loadWifiData{
    [ThingSmartBLEWifiActivator sharedInstance].bleWifiDelegate = self;
    [[ThingSmartBLEWifiActivator sharedInstance] connectAndQueryWifiListWithUUID:self.deviceInfo.uuid success:^{
      // 指令下发成功
        NSLog(@"指令下发成功");
    } failure:^(NSError *error) {
      // 指令下发失败
        NSLog(@"指令下发失败");
        [SVProgressHUD showErrorWithStatus:error.description];
        self.status = AddStatusType_default;
        [self.tableView reloadData];
    }];
}

//初始化家庭
- (void)initHome {
    self.home = [ThingSmartHome homeWithHomeId:self.homeId];
    self.home.delegate = self;
}

//获取配网token
- (void)getToken {
    WEAK_SELF
    ThingSmartActivator *ezActivator = [[ThingSmartActivator alloc] init];
    [ezActivator getTokenWithHomeId:self.homeId success:^(NSString *token) {
        NSLog(@"getToken success: %@", token);
        weakSelf.token = token;
    } failure:^(NSError *error) {
        NSLog(@"getToken failure: %@", error.localizedDescription);
    }];
}

//开始配网
- (void)deviceConnectStart:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    NSString *uuid = dic[@"uuid"];
    NSString *ssid = dic[@"ssid"];
    NSString *pwd = dic[@"pwd"];
    [[ThingSmartBLEWifiActivator sharedInstance] pairDeviceWithUUID:uuid token:self.token ssid:ssid pwd:pwd timeout:120];
    [self setupTimer];
}

-(void)setupTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    self.status = AddStatusType_progress;
}

//更新进度条
- (void)updateProgress {
    if (self.progress < 0.9) {
        self.progress += 0.05;
    } else {
        self.progress = 0.9;
        [self.timer invalidate];
    }
    [self.tableView reloadData];
}


//完成
- (IBAction)doneBtnClick:(id)sender {
    [self exit:1];
}

//关闭
- (IBAction)closeBtnClick:(id)sender {
    [self exit:0];
}

//退出配网 1.完成配网
-(void)exit:(NSInteger)type{
    WEAK_SELF
    if(self.status == AddStatusType_success){
        //在配网结束后调用
        [[ThingSmartBLEWifiActivator sharedInstance] stopDiscover];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        ExitView *view = [[ExitView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        view.sureBlock = ^{
            //在配网结束后调用
            [[ThingSmartBLEWifiActivator sharedInstance] stopDiscover];
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
//            if(type == 1){
//                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
//            }else{
//                [weakSelf.navigationController popViewControllerAnimated:YES];
//            }
        };
        [view show];
    }
    
}


#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WEAK_SELF
    if(indexPath.section == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
           if (!cell) {
               cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
               UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, kScreenWidth-30, 24)];
               label.textAlignment = NSTextAlignmentLeft;
               label.font = [ATFontManager systemFontOfSize:14];
               label.textColor = UIColorFromRGBA(000000, 0.7);
               label.tag = 100;
               [cell.contentView addSubview:label];
           }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
//        titleLabel.text = [NSString stringWithFormat:@"%d %@",self.status == AddStatusType_fail || self.status == AddStatusType_success ? 0 : 1, LocalString(@"个设备正在添加")];
        titleLabel.text = [NSString stringWithFormat:LocalString(@"%d个设备正在添加"), self.status == AddStatusType_fail || self.status == AddStatusType_success ? 0 : 1];
        cell.backgroundColor = UIColor.clearColor;
        return cell;
    }else{
        DeviceAddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceAddCell" forIndexPath:indexPath];
        cell.type = self.status;
        cell.progress = self.progress;
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self.deviceDic[@"icon"]] placeholderImage:[UIImage imageNamed:@"icon_find_device.png"]];
        cell.nameLabel.text = self.deviceDic[@"name"];
        cell.addBlock = ^{
            // 埋点上报：添加设备点击
            NSString *productId = weakSelf.deviceInfo.productId ?: @"";
            [[AnalyticsManager sharedManager] reportAddDeviceClickWithPid:productId];

            weakSelf.status = AddStatusType_findWifi;
            [weakSelf.tableView reloadData];
            [weakSelf loadWifiData];
        };
        cell.editBlock = ^{
            [weakSelf showAlertWithTextField];
        };
        return cell;
    }
}

//修改设备名称
- (void)showAlertWithTextField {
    WEAK_SELF
    [LGBaseAlertView showAlertInfo:@{@"title":LocalString(@"设备名称"),@"value":self.deviceDic[@"name"]?:@"",@"placeholder":LocalString(@"名称")} withType:ALERT_VIEW_TYPE_EditName confirmBlock:^(BOOL is_value, id obj) {
        NSString *str = (NSString *)obj;
        if (is_value && str.length > 0) {
            ThingSmartDevice *device = [ThingSmartDevice deviceWithDeviceId:self.deviceId];
            [device updateName:str success:^{
                    NSLog(@"updateName success");
                [SVProgressHUD showSuccessWithStatus:LocalString(@"修改成功")];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:weakSelf.deviceDic];
                [dic setObject:str forKey:@"name"];
                weakSelf.deviceDic = dic;
                [weakSelf.tableView reloadData];
                } failure:^(NSError *error) {
                    NSLog(@"updateName failure: %@", error);
                }];
        } else {
            if(is_value){
                [SVProgressHUD showErrorWithStatus:LocalString(@"请输入名称")];
            }
        }
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 ? 24 : 136;
}


#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}
#pragma mark - ThingSmartHomeDelegate
// 添加设备
- (void)home:(ThingSmartHome *)home didAddDeivice:(ThingSmartDeviceModel *)device {
    self.deviceId = device.devId;
}

#pragma mark -- ThingSmartBLEWifiActivatorDelegate

- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator notConfigStateWithError:(NSError *)error {
  // 设备不在配网状态
    NSLog(@"！！！！设备不在配网状态");
//    [SVProgressHUD showErrorWithStatus:error.description];
    self.status = AddStatusType_fail;
    [self.tableView reloadData];
}

- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator didScanWifiList:(NSArray *)wifiList uuid:(NSString *)uuid error:(nonnull NSError *)error{
    [SVProgressHUD dismiss];
    self.status = AddStatusType_default;
    [self.tableView reloadData];
    if (error) {
    // Wi-Fi 列表扫描失败
        NSLog(@"Wi-Fi 列表扫描失败");
    } else {
    // Wi-Fi 列表扫描成功
        NSLog(@"Wi-Fi 列表扫描成功");



        SelectWifiVC *VC = [SelectWifiVC new];
        VC.UUID = self.deviceInfo.uuid;
        VC.homeId = self.homeId;
        VC.wifiArr = wifiList;
        MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:VC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:NO completion:nil];
    }
}


- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator didReceiveBLEWifiConfigDevice:(nullable ThingSmartDeviceModel *)deviceModel error:(nullable NSError *)error{
    if(!error){
        //配网成功
        // 埋点上报：添加设备成功
        [[AnalyticsManager sharedManager] reportAddDeviceSuccessWithDeviceId:deviceModel.devId ?: @""
                                                                         pid:self.deviceInfo.productId ?: @""];

        self.status = AddStatusType_success;
        [PublicObj makeButtonEnable:self.doneBtn];
        [self.tableView reloadData];
        //在配网结束后调用
        [[ThingSmartBLEWifiActivator sharedInstance] stopDiscover];

    }else{
        //error.code 1.设备接收的数据包格式错误 2.设备找不到路由器
        // 埋点上报：添加设备失败
        [[AnalyticsManager sharedManager] reportAddDeviceFailedWithErrorCode:error.code];

        if(error.code == 3){
            //Wi-Fi 密码错误
            [SVProgressHUD showErrorWithStatus:LocalString(@"您输入的WiFi密码错误，请您核对后再试一次。")];
            self.ispwdError = YES;
        }else if(error.code == 4 || error.code == 2){
            //设备连不上路由器
            [SVProgressHUD showErrorWithStatus:@"网络信号连接不佳，请将设备和手机尽量靠近路由器。"];
        }else{
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }

        self.status = AddStatusType_fail;
        NSLog(@"配网失败");
    }
    [self.tableView reloadData];
    
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
