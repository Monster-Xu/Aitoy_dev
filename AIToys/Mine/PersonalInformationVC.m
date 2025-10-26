//
//  PersonalInformationVC.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/14.
//

#import "PersonalInformationVC.h"
#import "SettingCell.h"
#import "MineAvatarCell.h"
#import "SelectAvatarVC.h"
#import "AvatarModel.h"
@interface PersonalInformationVC ()<UITableViewDataSource,UITableViewDelegate,RYFTableViewDelegate>
@property (nonatomic, strong)RYFTableView *tableView;
@property (nonatomic, strong) NSMutableArray <MineItemModel *>*itemArray;
@end

@implementation PersonalInformationVC

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
        [_tableView registerNib:[UINib nibWithNibName:@"MineAvatarCell" bundle:nil] forCellReuseIdentifier:@"MineAvatarCell"];
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
    [self.itemArray removeAllObjects];
    NSArray *arr = @[
        @{@"title" : LocalString(@"头像")},
        @{@"title" : LocalString(@"昵称"),@"value" :[ThingSmartUser sharedInstance].nickname},
        ];
    [self.itemArray addObjectsFromArray:[MineItemModel mj_objectArrayWithKeyValuesArray:arr]];
    WEAK_SELF
    [[APIManager shared] GET:[APIPortConfiguration getAppAvatarUrl] parameter:nil success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        AvatarModel *model = [AvatarModel mj_objectWithKeyValues:data];
        weakSelf.itemArray[0].value = model.avatarUrl;
        [weakSelf.tableView reloadData];
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        
    }];
    [self.tableView reloadData];
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0){
        MineAvatarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MineAvatarCell"];
        cell.titleLabel.text = self.itemArray[indexPath.row].title;
        [cell.headImgView sd_setImageWithURL:[NSURL URLWithString:self.itemArray[indexPath.row].value] placeholderImage:QD_IMG(@"lanch_logo")];
        return cell;
    }else{
        SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
        cell.titleLabel.text = self.itemArray[indexPath.row].title;
        cell.subTitleLabel.text = self.itemArray[indexPath.row].value;
        cell.indexPath = indexPath;
        cell.rowInSection = self.itemArray.count;
        return cell;
    }
}

#pragma mark -- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    kPreventRepeatClickTime(0.5);
     MineItemModel *model = self.itemArray[indexPath.row];
     NSString *title = model.title;
    if (![ThingSmartUser sharedInstance].isLogin) {
        [UserInfo showLogin];
        return;
    }
    WEAK_SELF
    if([title isEqualToString:LocalString(@"头像")]){
        SelectAvatarVC *VC = [[SelectAvatarVC alloc] init];
//        VC.sureBlock = ^(UIImage * _Nonnull img) {
//            [[ThingSmartUser sharedInstance] updateHeadIcon:img success:^{
//                    NSLog(@"update head icon success");
//                [weakSelf loadData];
//                [weakSelf.tableView reloadData];
//                } failure:^(NSError *error) {
//                    NSLog(@"update head icon failure: %@", error);
//                }];
//        };
        VC.sureBlock = ^(NSString * _Nonnull imgUrl) {
            weakSelf.itemArray[indexPath.row].value = imgUrl;
            [weakSelf.tableView reloadData];
        };
        VC.imgUrl = weakSelf.itemArray[indexPath.row].value;
        VC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:VC animated:NO completion:nil];
    }else if ([title isEqualToString:LocalString(@"昵称")]){
        [self showAlertWithTextField];
    }
    
}

//修改昵称
- (void)showAlertWithTextField {
    WEAK_SELF
    [LGBaseAlertView showAlertInfo:@{@"title":LocalString(@"昵称"),@"value":[ThingSmartUser sharedInstance].nickname?:@"",@"placeholder":LocalString(@"请输入昵称")} withType:ALERT_VIEW_TYPE_EditName confirmBlock:^(BOOL is_value, id obj) {
        NSString *str = (NSString *)obj;
        if (is_value && str.length > 0) {
            [[ThingSmartUser sharedInstance] updateNickname:str success:^{
                [weakSelf loadData];
                [weakSelf.tableView reloadData];
                } failure:^(NSError *error) {
                    [SVProgressHUD showErrorWithStatus:error.description];
                    NSLog(@"updateNickname failure: %@", error);
                }];
        } else {
            if(is_value){
                [SVProgressHUD showErrorWithStatus:LocalString(@"请输入昵称")];
            }
        }
    }];
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
