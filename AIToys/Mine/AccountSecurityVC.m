//
//  AccountSecurityVC.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/16.
//

#import "AccountSecurityVC.h"
#import "SettingCell.h"
#import "UserEmailCell.h"

@interface AccountSecurityVC ()<UITableViewDelegate,UITableViewDataSource,RYFTableViewDelegate>
@property (nonatomic, strong)RYFTableView *tableView;
@property (nonatomic, strong) NSMutableArray *itemArray;

@end

@implementation AccountSecurityVC

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
        [_tableView registerNib:[UINib nibWithNibName:@"UserEmailCell" bundle:nil] forCellReuseIdentifier:@"UserEmailCell"];
    }
    return _tableView;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateUserInfo];
}

//获取用户信息
- (void)updateUserInfo {
    WEAK_SELF
    [[ThingSmartUser sharedInstance] updateUserInfo:^{
           NSLog(@"update userInfo success");
        [weakSelf loadData];
       } failure:^(NSError *error) {
           NSLog(@"update userInfo failure: %@", error);
       }];
   }

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
//    [self loadData];
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
        @{@"title" : LocalString(@"账号"),@"value" :[ThingSmartUser sharedInstance].email, @"toVC" : @"EmaileViewController"},
        @{@"title" : LocalString(@"修改登录密码"),@"value" :@"", @"toVC" : @"GetVerityCodeViewController"},
        @{@"title" : LocalString(@"用户Code"),@"value" :[ThingSmartUser sharedInstance].userAlias},
        @{@"title" : LocalString(@"注销账号"),@"value" :@"", @"toVC" : @"DeleteAcountViewController"},
        ];
    self.itemArray = [NSMutableArray arrayWithArray:[MineItemModel mj_objectArrayWithKeyValuesArray:arr]];
    [self.tableView reloadData];
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
    if(indexPath.section == 0){
        UserEmailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserEmailCell"];
        cell.model = model;
        return cell;
    }else{
        SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
        cell.indexPath = indexPath;
        cell.rowInSection = 1;
        cell.model = model;
        return cell;
    }
    
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    kPreventRepeatClickTime(0.5);
    MineItemModel *model = self.itemArray[indexPath.section];
     NSString *title = model.title;
     NSString *str = model.toVC;
    if ([title isEqualToString:LocalString(@"清理缓存")]) {
//        [SVProgressHUD showWithStatus:@"缓存清理中"];
//        WEAK_SELF
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [PublicObj clearFile];
//            [weakSelf.tableView reloadData];
//        });
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
