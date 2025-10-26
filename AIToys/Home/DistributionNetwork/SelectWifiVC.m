//
//  SelectWifiVC.m
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import "SelectWifiVC.h"
#import "SelectWifCell.h"
#import "WifiManuallyInputCell.h"
#import "ConnectWifiVC.h"

@interface SelectWifiVC ()<UITableViewDataSource,UITableViewDelegate,ThingSmartBLEWifiActivatorDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SelectWifiVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.titleLabel.text = LocalString(@"请选择以下可用Wi-Fi连接");
    self.nameLabel.text = LocalString(@"Wi-Fi列表");
    self.tableView.sectionHeaderHeight = 10;
    self.tableView.sectionFooterHeight = 42;
    self.tableView.backgroundColor = UIColor.clearColor;
    [self.tableView registerNib:[UINib nibWithNibName:@"SelectWifCell" bundle:nil] forCellReuseIdentifier:@"SelectWifCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"WifiManuallyInputCell" bundle:nil] forCellReuseIdentifier:@"WifiManuallyInputCell"];
//    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hiddenHud];
}

-(void)loadData{
    [self showHud];
    [ThingSmartBLEWifiActivator sharedInstance].bleWifiDelegate = self;
    [[ThingSmartBLEWifiActivator sharedInstance] connectAndQueryWifiListWithUUID:self.UUID success:^{
      // 指令下发成功
        NSLog(@"指令下发成功");
    } failure:^(NSError *error) {
      // 指令下发失败
        NSLog(@"指令下发失败");
    }];
}

#pragma mark -- ThingSmartBLEWifiActivatorDelegate

- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator didReceiveBLEWifiConfigDevice:(nullable ThingSmartDeviceModel *)deviceModel error:(nullable NSError *)error{
    
}

- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator notConfigStateWithError:(NSError *)error {
  // 设备不在配网状态
    NSLog(@"！！！！设备不在配网状态");
}

- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator didScanWifiList:(NSArray *)wifiList uuid:(NSString *)uuid error:(nonnull NSError *)error{
    [SVProgressHUD dismiss];
    if (error) {
    // Wi-Fi 列表扫描失败
        NSLog(@"Wi-Fi 列表扫描失败");
    } else {
    // Wi-Fi 列表扫描成功
        NSLog(@"Wi-Fi 列表扫描成功");
        self.wifiArr = wifiList;
        [self.tableView reloadData];
    }
}

//刷新WiFi列表
- (IBAction)refreshBtnClick:(id)sender {
    [self loadData];
}

//关闭
- (IBAction)closeBtnClick:(id)sender {
    [SVProgressHUD dismiss];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.wifiArr.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WEAK_SELF
    if(indexPath.section == 0){
        SelectWifCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectWifCell" forIndexPath:indexPath];
        NSDictionary *dic = self.wifiArr[indexPath.row];
        cell.dic = dic;
        return cell;
    }else{
        WifiManuallyInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiManuallyInputCell" forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark UITableViewDelegate
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, 10)];
        headView.backgroundColor = [UIColor clearColor];
        UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(32, 0, tableView.width - 64, 10)];
        containerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
        [PublicObj makeCornerToView:containerView withFrame:containerView.bounds withRadius:10 position:1];
        [headView addSubview:containerView];
        return headView;
    }
    return nil;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]init];
    footerView.backgroundColor = [UIColor clearColor];
    footerView.frame = CGRectMake(0, 0, tableView.width, 42);
    if(section == 0){
        UIView *containerView = [[UIView alloc]init];
        containerView.frame = CGRectMake(32, 0, tableView.width - 64, 10);
        containerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
        [footerView addSubview:containerView];
        [PublicObj makeCornerToView:containerView withFrame:containerView.bounds withRadius:10 position:2];
    }
    return footerView;
        
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ConnectWifiVC *VC = [ConnectWifiVC new];
    VC.UUID = self.UUID;
    VC.homeId = self.homeId;
    if(indexPath.section == 0){
        NSDictionary *dic = self.wifiArr[indexPath.row];
        VC.ssid = dic[@"ssid"];
    }
    [self.navigationController pushViewController:VC animated:YES];
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
