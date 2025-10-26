//
//  SwitchFamailyVC.m
//  AIToys
//
//  Created by qdkj on 2025/6/26.
//

#import "SwitchFamailyVC.h"
#import "SwitchFamailyCell.h"
#import "ATFontManager.h"

@interface SwitchFamailyVC ()<UITableViewDelegate,UITableViewDataSource,RYFTableViewDelegate>
@property (nonatomic,strong)RYFTableView *tableView;
@property(nonatomic, strong) NSMutableArray *selectArr;
@end

@implementation SwitchFamailyVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    //初始化选择数组
    for (ThingSmartHomeModel *item in self.homeList) {
        if(self.currentHome.homeId == item.homeId){
            [self.selectArr addObject:@(1)];
        }else{
            [self.selectArr addObject:@(0)];
        }
    }
    [self.tableView reloadData];
}

-(void)setupUI{
    self.view.backgroundColor = UIColorFromRGBA(000000, 0.5);
    CGFloat tableViewH = self.homeList.count * 64 > 0.5*kScreenHeight ? 0.5*kScreenHeight : self.homeList.count * 64;
    CGFloat bottomViewH = 56;
    CGFloat alertViewH = tableViewH + bottomViewH + 16 + StatusBar_Height;
    self.alertView.frame = CGRectMake(0, -alertViewH, kScreenWidth, alertViewH);
    self.alertView.backgroundColor = [UIColor whiteColor];
    [PublicObj makeCornerToView:self.alertView withFrame:self.alertView.bounds withRadius:20 position:2];
    
    self.tableView.loadState = RYFCanLoadNone;
    [self.alertView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.alertView).offset(StatusBar_Height);
        make.bottom.mas_equalTo(self.alertView).offset(-60);
        make.left.right.mas_equalTo(self.alertView);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = UIColorFromRGBA(000000, 0.05);
    [self.alertView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom).offset(2);
        make.left.equalTo(self.alertView).offset(20);
        make.right.equalTo(self.alertView).offset(-20);
        make.height.mas_equalTo(1);
    }];
    
    UIView *bottomView = [[UIView alloc] init];
    [self.alertView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom).offset(2);
        make.left.right.bottom.equalTo(self.alertView);
        make.height.mas_equalTo(bottomViewH);
    }];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:QD_IMG(@"icon_famaily_manager")];
    [bottomView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView).offset(20);
        make.size.mas_equalTo(CGSizeMake(24, 24));
        make.centerY.equalTo(bottomView);
    }];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = LocalString(@"家庭管理");
    nameLabel.font = [ATFontManager systemFontOfSize:16];
    nameLabel.textColor = UIColorFromRGBA(000000, 0.9);
    [bottomView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(12);
        make.centerY.equalTo(bottomView);
    }];
       
    UIButton *managerBtn = [[UIButton alloc] init];
    
    [managerBtn addTarget:self action:@selector(manager:) forControlEvents:UIControlEventTouchUpInside];
   
    [bottomView addSubview:managerBtn];
    [managerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bottomView);
    }];
}

//家庭管理
-(void)manager:(UIButton *)btn{
    if(self.managerBlock){
        self.managerBlock();
    }
    [self dismiss:0];
}

//出现的动画
- (void)showView {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alertView.transform = CGAffineTransformMakeTranslation(0, self.alertView.height);
    } completion:^(BOOL finished) {
        
    }];
}

//消失的动画
- (void)dismiss:(NSInteger)handle {
    [UIView animateWithDuration:0.2 animations:^{
        self.alertView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    [self dismiss:0];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.homeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwitchFamailyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchFamailyCell" forIndexPath:indexPath];
    cell.model = self.homeList[indexPath.row];
    cell.isSel = [self.selectArr[indexPath.row] intValue];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    for (int i = 0; i<self.selectArr.count; i++) {
        self.selectArr[i] = @(0);
        if(indexPath.row == i){
            self.selectArr[i] = @(1);
        }
    }
    if(self.sureBlock){
        self.sureBlock(self.homeList[indexPath.row]);
    }
    [self.tableView reloadData];
    [self dismiss:0];
}

#pragma mark - ThingSmartHomeManagerDelegate

// 添加一个家庭
- (void)homeManager:(ThingSmartHomeManager *)manager didAddHome:(ThingSmartHomeModel *)home {

}

// 删除一个家庭
- (void)homeManager:(ThingSmartHomeManager *)manager didRemoveHome:(long long)homeId {

}

// MQTT 连接成功
- (void)serviceConnectedSuccess {
    // 去云端查询当前家庭的详情，然后去刷新 UI
}


- (RYFTableView *)tableView{
    if (!_tableView) {
        _tableView = [[RYFTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.tableViewDelegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 64;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, CGFLOAT_MIN)];
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 0;
        _tableView.backgroundColor = UIColor.whiteColor;
        [_tableView registerNib:[UINib nibWithNibName:@"SwitchFamailyCell" bundle:nil] forCellReuseIdentifier:@"SwitchFamailyCell"];
    }
    return _tableView;
}



- (NSMutableArray *)selectArr{
    if(!_selectArr){
        _selectArr = [[NSMutableArray alloc] init];
    }
    return _selectArr;
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
