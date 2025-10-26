//
//  SettingViewController.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/13.
//

#import "SettingViewController.h"
#import "SettingCell.h"
#import "ATFontManager.h"
#import "LogManager.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource,RYFTableViewDelegate>
@property (nonatomic, strong)RYFTableView *tableView;
@property (nonatomic, strong) NSMutableArray *itemArray;
@end

@implementation SettingViewController

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
        [_tableView registerNib:[UINib nibWithNibName:@"SettingCell" bundle:nil] forCellReuseIdentifier:@"SettingCell"];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self setupUI];
}

-(void)setupUI{
    self.title = LocalString(@"设置");
    self.tableView.loadState = RYFCanLoadNone;
    self.tableView.tableFooterView = [self setupfooterView];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

-(void)loadData{
    [self.itemArray removeAllObjects];
    NSArray *arr1 = @[
        @{@"title" : LocalString(@"个人信息"),@"value" :@"", @"toVC" : @"PersonalInformationVC"},
        @{@"title" : LocalString(@"账号与安全"),@"value" :@"", @"toVC" : @"AccountSecurityVC"},
        ];
    [self.itemArray addObject:[MineItemModel mj_objectArrayWithKeyValuesArray:arr1]];
    
//    NSArray *arr2 = @[
//        @{@"title" : LocalString(@"APP消息通知"),@"value" :@"", @"toVC" : @""}
//        ];
//    [self.itemArray addObject:[MineItemModel mj_objectArrayWithKeyValuesArray:arr2]];
    
    NSArray *arr3 = @[
        @{@"title" : LocalString(@"关于"),@"value" :@"", @"toVC" : @"AboutUsViewController"},
        @{@"title" : LocalString(@"隐私设置"),@"value" :@"", @"toVC" : @"PrivateSettingViewController"},
        @{@"title" : LocalString(@"隐私政策管理"),@"value" :@"", @"toVC" : @"PrivacyPolicyManagementVC"}
        ];
    [self.itemArray addObject:[MineItemModel mj_objectArrayWithKeyValuesArray:arr3]];
    
    
    
    NSArray *arr4 = @[
        @{@"title" : LocalString(@"WiFi列表"),@"value" :@"", @"toVC" : @"WiFiListViewController"},
        @{@"title" : LocalString(@"导出日志"),@"value" :@"", @"toVC" : @""}
        ];
    [self.itemArray addObject:[MineItemModel mj_objectArrayWithKeyValuesArray:arr4]];
    
    
    
    NSArray *arr5 = @[
        @{@"title" : LocalString(@"清理缓存"),@"value" :[NSString stringWithFormat:@"%.2fM",[PublicObj readCacheSize]], @"toVC" : @""}
        ];
    [self.itemArray addObject:[MineItemModel mj_objectArrayWithKeyValuesArray:arr5]];
}

- (UIView *)setupfooterView {
    CGFloat btnViewH =  64;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, btnViewH)];
    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    exitBtn.titleLabel.font = [ATFontManager systemFontOfSize:16 weight:600];
    exitBtn.backgroundColor = UIColor.whiteColor;
    exitBtn.layer.cornerRadius = 16;
    exitBtn.layer.masksToBounds = YES;
    [exitBtn setTitle:LocalString(@"退出登录") forState:0];
    [exitBtn setTitleColor:UIColorHex(0xFF4444) forState:0];
    [exitBtn addTarget:self action:@selector(exitLogin) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:exitBtn];
    [exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(footer);
        make.left.equalTo(footer).offset(15);
        make.right.equalTo(footer).offset(-15);
    }];
    return footer;
}

//退出登录
-(void)exitLogin{
//    WEAK_SELF
    [LGBaseAlertView showAlertWithTitle:LocalString(@"确定要退出吗?") content:nil cancelBtnStr:LocalString(@"取消") confirmBtnStr:LocalString(@"确定") confirmBlock:^(BOOL isValue, id obj) {
        if (isValue){
            [SVProgressHUD showWithStatus:LocalString(@"正在安全退出，请稍后…")];
            [[ThingSmartUser sharedInstance] loginOut:^{
                [SVProgressHUD dismiss];
                [UserInfo clearMyUser];
                [CoreArchive removeStrForKey:KCURRENT_HOME_ID];
                [UserInfo showLogin];
            } failure:^(NSError *error) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus:@"Failed to Logout."];
            }];
        }
    }];
}

#pragma mark -- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.itemArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.itemArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    NSArray *arr = self.itemArray[indexPath.section];
    MineItemModel *model = arr[indexPath.row];
    cell.indexPath = indexPath;
    cell.rowInSection = arr.count;
    cell.model = model;
    return cell;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    kPreventRepeatClickTime(0.5);
    NSArray *arr = self.itemArray[indexPath.section];
    MineItemModel *model = arr[indexPath.row];
    NSString *title = model.title;
    NSString *str = model.toVC;
    if ([title isEqualToString:LocalString(@"清理缓存")]) {
        WEAK_SELF
        [LGBaseAlertView showAlertWithTitle:LocalString(@"确定清除缓存?") content:nil cancelBtnStr:LocalString(@"取消") confirmBtnStr:LocalString(@"确定") confirmBlock:^(BOOL isValue, id obj) {
            if (isValue){
                [SVProgressHUD showWithStatus:LocalString(@"清理中...")];
                
                // 异步执行缓存清理操作，避免阻塞主线程
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [PublicObj clearFile];
                    
                    // 清理完成后回到主线程更新UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showSuccessWithStatus:LocalString(@"缓存清理成功")];
                        model.value = @"0.00M";
                        // 优化：只刷新当前行，而不是整个表格
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    });
                });
            }
        }];
    }
    else if ([title isEqualToString:@"导出日志"]){
        WEAK_SELF
        [SVProgressHUD showWithStatus:LocalString(@"导出中...")];
        
        [[LogManager sharedManager] exportLogsWithCompletion:^(NSURL * _Nullable fileURL, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                
                if (error) {
                    [SVProgressHUD showErrorWithStatus:LocalString(@"导出失败")];
                    return;
                }
                
                // 显示导出成功提示，告知用户文件位置
                NSString *fileName = fileURL.lastPathComponent;
                NSString *message = [NSString stringWithFormat:LocalString(@"日志已成功导出！\n\n文件名：%@\n\n可以在「文件」App 的「我的 iPhone/ExportedLogs」文件夹中查看和分享"), fileName];
                
                [LGBaseAlertView showAlertWithTitle:LocalString(@"导出成功") content:message cancelBtnStr:nil confirmBtnStr:LocalString(@"我知道了") confirmBlock:^(BOOL isValue, id obj) {
                    // 可选：导出成功后直接打开系统分享界面
                    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
                    
                    // 为iPad设置弹出位置
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                        activityVC.popoverPresentationController.sourceView = weakSelf.view;
                        activityVC.popoverPresentationController.sourceRect = CGRectMake(weakSelf.view.bounds.size.width/2, weakSelf.view.bounds.size.height/2, 1, 1);
                    }
                    
                    [weakSelf presentViewController:activityVC animated:YES completion:nil];
                }];
            });
        }];
    }
    else{
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
