//
//  GuideOpenBluetoothVC.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/29.
//

#import "GuideOpenBluetoothVC.h"
#import "GuideOpenCell.h"
#import "GuideOpenAppPermmitCell.h"
#import "GuideOpenTopCell.h"

@interface GuideOpenBluetoothVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation GuideOpenBluetoothVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGBA(000000, 0.5);
    self.alertView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 450);
    self.alertView.layer.cornerRadius = 24;
    self.alertView.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.estimatedRowHeight = 55;
    tableView.backgroundColor = [UIColor clearColor];
    [_tableView registerNib:[UINib nibWithNibName:@"GuideOpenTopCell" bundle:nil] forCellReuseIdentifier:@"GuideOpenTopCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"GuideOpenAppPermmitCell" bundle:nil] forCellReuseIdentifier:@"GuideOpenAppPermmitCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"GuideOpenCell" bundle:nil] forCellReuseIdentifier:@"GuideOpenCell"];
    [self.alertView addSubview:tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.alertView);
    }];
       
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn setImage:[UIImage imageNamed:@"right_close"] forState:0];
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(self.alertView);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(50);
    }];
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WEAK_SELF
    if(indexPath.row == 0){
        GuideOpenTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuideOpenTopCell" forIndexPath:indexPath];
        cell.isBluetooth = YES;
        return cell;
    }else if(indexPath.row == 1){
        GuideOpenAppPermmitCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuideOpenAppPermmitCell" forIndexPath:indexPath];
        cell.clickBlock = ^{
            if(weakSelf.clickBlock){
                weakSelf.clickBlock();
            }
            [weakSelf dismiss:0];
        };
        return cell;
    }else{
        GuideOpenCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuideOpenCell" forIndexPath:indexPath];
        cell.isBluetooth = YES;
        return cell;
    }
}


#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
}


//关闭
-(void)close{
    [self dismiss:0];
}

//出现的动画
- (void)showView {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alertView.transform = CGAffineTransformMakeTranslation(0, -self.alertView.height);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
