//
//  ComponentLicensesViewController.m
//  AIToys
//
//  Created by qdkj on 2025/7/18.
//

#import "ComponentLicensesViewController.h"
#import "ComponentLicenseCell.h"

@interface ComponentLicensesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, strong) NSMutableArray <ComponentLicenseModel *>*dataArr;
@end

@implementation ComponentLicensesViewController

-(NSMutableArray *)dataArr{
    if(!_dataArr){
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = tableBgColor;
    
    NSArray *arr = @[
        @{@"name" : @"DACircularProgress", @"compentUrl" : @"https://github.com/danielamitay/DACircularProgress", @"version" : @"2.3.1",@"licence":@"MIT License",@"licenceUrl":@"https://opensource.org/license/MIT",@"modify":@"No"},
        @{@"name" : @"IQKeyboardManager", @"compentUrl" : @"https://github.com/hackiftekhar/IQKeyboardManager", @"version" : @"8.0.1",@"licence":@"MIT License",@"licenceUrl":@"https://opensource.org/license/MIT",@"modify":@"No"},
        @{@"name" : @"Masonry", @"compentUrl" : @"https://github.com/SnapKit/Masonry", @"version" : @"1.1.0",@"licence":@"MIT License",@"licenceUrl":@"https://opensource.org/license/MIT",@"modify":@"No"},
        @{@"name" : @"SDWebImage", @"compentUrl" : @"https://github.com/SDWebImage/SDWebImage", @"version" : @"5.1.1",@"licence":@"MIT License",@"licenceUrl":@"https://opensource.org/license/MIT",@"modify":@"No"},
        @{@"name" : @"AFNetworking", @"compentUrl" : @"https://github.com/AFNetworking/AFNetworking", @"version" : @"4.0.1",@"licence":@"MIT License",@"licenceUrl":@"https://opensource.org/license/MIT",@"modify":@"No"},
        @{@"name" : @"MJRefresh", @"compentUrl" : @"https://github.com/CoderMJLee/MJRefresh", @"version" : @"3.2.3",@"licence":@"MIT License",@"licenceUrl":@"https://opensource.org/license/MIT",@"modify":@"No"},
        @{@"name" : @"SDCycleScrollView", @"compentUrl" : @"https://github.com/gsdios/SDCycleScrollView", @"version" : @"1.82",@"licence":@"MIT License",@"licenceUrl":@"https://opensource.org/license/MIT",@"modify":@"No"},
        @{@"name" : @"SVProgressHUD", @"compentUrl" : @"https://github.com/SVProgressHUD/SVProgressHUD", @"version" : @"2.2.5",@"licence":@"MIT License",@"licenceUrl":@"https://opensource.org/license/MIT",@"modify":@"No"},
        @{@"name" : @"YYCategories", @"compentUrl" : @"https://github.com/ibireme/YYCategories", @"version" : @"1.0.4",@"licence":@"MIT License",@"licenceUrl":@"https://opensource.org/license/MIT",@"modify":@"No"},
        @{@"name" : @"MJExtension", @"compentUrl" : @"https://github.com/CoderMJLee/MJExtension", @"version" : @"3.4.2",@"licence":@"MIT License",@"licenceUrl":@"https://opensource.org/license/MIT",@"modify":@"No"},
        
        ];
    self.dataArr = [NSMutableArray arrayWithArray:[ComponentLicenseModel mj_objectArrayWithKeyValuesArray:arr]];
    
    _tableView.tableHeaderView = self.headerView;
    _tableView.tableFooterView = [UIView new];
    _tableView.sectionHeaderHeight = 15;
    _tableView.sectionFooterHeight = 0;
    _tableView.estimatedRowHeight = 45;
    [_tableView registerNib:[UINib nibWithNibName:@"ComponentLicenseCell" bundle:nil] forCellReuseIdentifier:@"ComponentLicenseCell"];
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WEAK_SELF
    ComponentLicenseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ComponentLicenseCell"];
    cell.row = indexPath.row;
    cell.model = self.dataArr[indexPath.row];
    cell.clickItemBlock = ^(NSInteger tag) {
        MyWebViewController *VC = [[MyWebViewController alloc] init];
        if(tag == 100){
            VC.mainUrl = weakSelf.dataArr[indexPath.row].compentUrl;
        }else{
            VC.mainUrl = weakSelf.dataArr[indexPath.row].licenceUrl;
        }
        [weakSelf.navigationController pushViewController:VC animated:YES];
    };
    return cell;
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
