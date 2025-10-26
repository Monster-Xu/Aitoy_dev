//
//  PrivacyPolicyManagementVC.m
//  AIToys
//
//  Created by qdkj on 2025/7/17.
//

#import "PrivacyPolicyManagementVC.h"
#import "SettingCell.h"
#import "RevokePrivacyPolicyVC.h"
#import "MyWebViewController.h"
#import "ATFontManager.h"
#import "NegotiateViewController.h"
#import "ThirdPartySDKInfoViewController.h"
@interface PrivacyPolicyManagementVC ()<UITableViewDelegate,UITableViewDataSource,RYFTableViewDelegate>
@property (nonatomic, strong)RYFTableView *tableView;
@property (nonatomic, strong) NSMutableArray *itemArray;

@end

@implementation PrivacyPolicyManagementVC

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
    self.tableView.tableFooterView = [self setupfooterView];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

-(void)loadData{
    NSArray *arr = @[
        @{@"title" : LocalString(@"隐私政策"),@"value" :@"", @"toVC" : @"MyWebViewController"},
        @{@"title" : LocalString(@"用户协议"),@"value" :@"", @"toVC" : @"MyWebViewController"},
        @{@"title" : LocalString(@"儿童协议"),@"value" :@"", @"toVC" : @"MyWebViewController"},
        @{@"title" : LocalString(@"第三方信息共享和SDK服务清单"),@"value" :@"", @"toVC" : @"MyWebViewController"},
        ];
    self.itemArray = [NSMutableArray arrayWithArray:[MineItemModel mj_objectArrayWithKeyValuesArray:arr]];
}

- (UIView *)setupfooterView {
    CGFloat btnViewH =  64;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, btnViewH)];
    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    exitBtn.titleLabel.font = [ATFontManager systemFontOfSize:15 weight:600];
    exitBtn.backgroundColor = UIColor.whiteColor;
    exitBtn.layer.cornerRadius = 16;
    exitBtn.layer.masksToBounds = YES;
    [exitBtn setTitle:LocalString(@"撤销同意") forState:0];
    [exitBtn setTitleColor:UIColorFromRGBA(0x000000, 0.9) forState:0];
    [exitBtn addTarget:self action:@selector(revoke:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:exitBtn];
    [exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(footer);
        make.left.equalTo(footer).offset(15);
        make.right.equalTo(footer).offset(-15);
    }];
    return footer;
}

//撤回同意
-(void)revoke:(UIButton *)btn{
    RevokePrivacyPolicyVC *VC = [RevokePrivacyPolicyVC new];
    VC.title = btn.titleLabel.text;
    [self.navigationController pushViewController:VC animated:YES];
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
    MineItemModel *model = self.itemArray[indexPath.section];
//     NSString *title = model.title;
//     NSString *str = model.toVC;
    
//    MyWebViewController* VC  = [[ MyWebViewController alloc] init];
//    VC.title = title;
//    VC.mainUrl = @"https://www.baidu.com";
//    [self.navigationController pushViewController:VC animated:YES];
    
    if (indexPath.row==0) {
        //隐私政策
        NSLog(@"点击了隐私政策");
        [self pushToNegotiateVCWithTitle:NSLocalizedString(@"隐私政策", @"") type:0];
        
        
    } else if (indexPath.row==1) {
        //用户协议
        NSLog(@"点击了用户协议");
        [self pushToNegotiateVCWithTitle:NSLocalizedString(@"用户协议", @"") type:1];
        
        
    } else if (indexPath.row==2) {
        //儿童协议
        NSLog(@"点击了儿童协议");
        [self pushToNegotiateVCWithTitle:NSLocalizedString(@"儿童协议", @"") type:2];
        
        
    } else if (indexPath.row==3) {
        //三方SDK
        NSLog(@"三方SDK收集");
        ThirdPartySDKInfoViewController * vc  = [[ThirdPartySDKInfoViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
}
-(void)pushToNegotiateVCWithTitle:(NSString *)title type:(NSInteger)type{
    NegotiateViewController * neVC = [[NegotiateViewController alloc]init];
    neVC.title = title;
    neVC.type  = type;
    [self.navigationController pushViewController:neVC animated:YES];
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
