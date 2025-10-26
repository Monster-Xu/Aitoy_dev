//
//  CreateFamailyVC.m
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import "CreateFamailyVC.h"
#import "FamailySettingVC.h"
#import "FamailyManageVC.h"

@interface CreateFamailyVC ()<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (weak, nonatomic) IBOutlet UILabel *leftnameLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property(strong, nonatomic) ThingSmartHomeManager *homeManager;
//@property(strong, nonatomic) CLLocationManager *locationManager;
//@property(assign, nonatomic) double longitude;
//@property(assign, nonatomic) double latitude;
//@property(copy, nonatomic) NSString *provinceName;
//@property(copy, nonatomic) NSString *cityName;
//@property(copy, nonatomic) NSString *currentCity;//当前城市
@end

@implementation CreateFamailyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden =  YES;
    self.titleLab.text = LocalString(@"创建家庭");
    self.leftnameLabel.text = LocalString(@"家庭名称");
    self.textField.placeholder = LocalString(@"请输入名称");
    self.view.backgroundColor = tableBgColor;
    [self.cancelBtn setTitle:LocalString(@"取消") forState:0];
    [self.saveBtn setTitle:LocalString(@"保存") forState:0];
//    [self.locationManager requestWhenInUseAuthorization];
//    if ([CLLocationManager locationServicesEnabled]) {
//        self.locationManager.delegate = self;
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        [self.locationManager startUpdatingHeading];
//    } else {
//        [Alert showBasicAlertOnVC:self withTitle:@"Cannot Access Location" message:@"Please make sure if the location access is enabled for the app."];
//    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


//保存
- (IBAction)saveBtnClick:(id)sender {
    NSString *homeName = self.textField.text;
    if(homeName.length == 0){
        [SVProgressHUD showErrorWithStatus:LocalString(@"请输入名称")];
        return;
    }
    WEAK_SELF
    [self showHud];
    [self.homeManager addHomeWithName:homeName geoName:nil rooms:@[@"客厅"] latitude:0 longitude:0 success:^(long long result) {
        [weakSelf hiddenHud];
        [LGBaseAlertView showAlertWithTitle:LocalString(@"创建家庭成功") content:nil cancelBtnStr:LocalString(@"查看家庭") confirmBtnStr:LocalString(@"确定") confirmBlock:^(BOOL isValue, id obj) {
            if(isValue){
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }else{
                [weakSelf.homeManager getHomeListWithSuccess:^(NSArray<ThingSmartHomeModel *> *homes) {
                    [weakSelf hiddenHud];
                    ThingSmartHomeModel *homeModel;
                    for (ThingSmartHomeModel *obj in homes) {
                        if(obj.homeId == result){
                            homeModel = obj;
                            break;
                        }
                        
                    }
                    //跳转去一个特定的界面
                   NSArray *vcsArr =  weakSelf.navigationController.viewControllers;
                   NSMutableArray *vcsMutArr = [[NSMutableArray alloc]initWithArray:vcsArr];
                    for (UIViewController *controller in vcsArr) {
                        if ([controller isKindOfClass:[FamailyManageVC class]]){
                            //创建要跳转去的控制器
                            FamailySettingVC *VC = [FamailySettingVC new];
                            VC.homeModel = homeModel;
                            VC.isSignalHome = homes.count == 1;
                            //获取查找出来的控制器index
                            NSInteger index = [vcsMutArr indexOfObject:controller];
                            //把要跳转去的控制器插入数组
                            [vcsMutArr insertObject:VC atIndex:index + 1];
                            //再次给self.navigationController.viewControllers赋值
                            [weakSelf.navigationController setViewControllers:vcsMutArr];
                            //跳转去控制器
                            [weakSelf.navigationController popToViewController:VC animated:YES];
                        }
                    }
                } failure:^(NSError *error) {
                    [weakSelf hiddenHud];
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }];
            }
        }];
    } failure:^(NSError *error) {
        [weakSelf hiddenHud];
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

//取消
- (IBAction)cancelBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
//    CLLocation *location = manager.location;
//    if (!location) {
//        return;
//    }
//    
//    self.longitude = location.coordinate.longitude;
//    self.latitude = location.coordinate.latitude;
//    self.cityName = location.description;
//    
//    CLLocation *currentLocation = [locations lastObject];
//    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
//    self.latitude = currentLocation.coordinate.latitude;
//    self.longitude = currentLocation.coordinate.longitude;
//    //打印当前的经度与纬度
//    
//    //反地理编码
//    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        
//        if (placemarks.count > 0) {
//            CLPlacemark *placeMark = placemarks[0];
//            self.currentCity = placeMark.locality;
////            if (!self.currentCity) {
////                self.provinceName = placeMark.locality;
////                self.cityName = placeMark.administrativeArea;
////            }
////            
////            self.cityName = placeMark.locality;
////            self.provinceName = placeMark.administrativeArea;
////            [CoreArchive setStr:self.provinceName key:PROVINCENAME];
////            [CoreArchive setStr:self.cityName key:CITYNAME];
//        }
//    }];
//}


- (ThingSmartHomeManager *)homeManager {
    if (!_homeManager) {
        _homeManager = [[ThingSmartHomeManager alloc] init];
    }
    return _homeManager;
}

//- (CLLocationManager *)locationManager {
//    if (!_locationManager) {
//        _locationManager = [[CLLocationManager alloc] init];
//    }
//    return _locationManager;
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
