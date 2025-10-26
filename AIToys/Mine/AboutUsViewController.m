//
//  AboutUsViewController.m
//  AIToys
//
//  Created by qdkj on 2025/7/17.
//

#import "AboutUsViewController.h"
#import "SettingCell.h"

@interface AboutUsViewController ()<UITableViewDelegate,UITableViewDataSource,RYFTableViewDelegate>
@property (nonatomic, strong)RYFTableView *tableView;
@property (nonatomic, strong) NSMutableArray *itemArray;

@end

@implementation AboutUsViewController

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
    self.tableView.loadState = RYFCanLoadNone;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

-(void)loadData{
    NSArray *arr = @[
//        @{@"title" : LocalString(@"鼓励一下我们"),@"value" :@"", @"toVC" : @"EmaileViewController"},
        @{@"title" : LocalString(@"开源组件许可"),@"value" :@"", @"toVC" : @"ComponentLicensesViewController"},
        @{@"title" : LocalString(@"当前版本"),@"value" :APP_VERSION},
//        @{@"title" : LocalString(@"检查更新"),@"value" :@"",@"toVC" : @"ComponentLicensesViewController"},
//        @{@"title" : LocalString(@"更新日志"),@"value" :@"", @"toVC" : @""},
        ];
    self.itemArray = [NSMutableArray arrayWithArray:[MineItemModel mj_objectArrayWithKeyValuesArray:arr]];
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MineItemModel *model = self.itemArray[indexPath.row];
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    cell.indexPath = indexPath;
    cell.rowInSection = self.itemArray.count;
    cell.model = model;
    return cell;
    
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    kPreventRepeatClickTime(0.5);
    MineItemModel *model = self.itemArray[indexPath.row];
     NSString *title = model.title;
     NSString *str = model.toVC;
    if ([title isEqualToString:LocalString(@"鼓励一下我们")] || [title isEqualToString:LocalString(@"检查更新")]) {
        NSString *localizedLink = @"https://apps.apple.com/app/id1129144823";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:localizedLink] options:@{} completionHandler:nil];
    }else{
        UIViewController* vc = [NSString stringChangeToClass:str];
        if(![title isEqualToString:LocalString(@"修改登录密码")]){
            vc.title = title;
        }
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
