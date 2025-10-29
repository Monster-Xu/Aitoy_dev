//
//  WiFiListViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/19.
//

#import "WiFiListViewController.h"
#import "WiFiListTableViewCell.h"

@interface WiFiListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property(nonatomic,strong)NSMutableArray * dataArr;
@end

@implementation WiFiListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    self.view.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    [self.listTableView registerNib:[UINib nibWithNibName:@"WiFiListTableViewCell" bundle:nil] forCellReuseIdentifier:@"WiFiListTableViewCell"];
    self.dataArr = [NSMutableArray new];
    [self loadDate];
    
}
-(void)loadDate{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:@"connectedWifi" forKey:@"propKey"];
    
    WEAK_SELF
    [[APIManager shared] GET:[APIPortConfiguration getAppPropertyByKeyUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {

        NSDictionary * dic = [NSDictionary dictionaryWithDictionary:result];
        // 修复：正确获取数据路径 - 从 dic[@"data"][@"list"] 获取
        if([dic[@"code"] integerValue] == 0){
            NSDictionary * dataDict = dic[@"data"];
            // 修复：检查dataDict是否有效且不为空
            if(dataDict && ![dataDict isKindOfClass:[NSNull class]] && [dataDict count] > 0){
                NSArray * listArray = @[dataDict];
                weakSelf.dataArr = [NSMutableArray arrayWithArray:listArray];
                weakSelf.emptyView.hidden = YES;
            }else{
                weakSelf.dataArr = [NSMutableArray new];
                weakSelf.emptyView.hidden = NO;
            }
            [weakSelf.listTableView reloadData];
        }

    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        NSLog(@"加载数据失败: %@", msg);
    }];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WiFiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WiFiListTableViewCell"];
    
    // 修复：为cell赋值 - 获取当前section对应的数据
    NSDictionary * wifiData = self.dataArr[indexPath.section];
    if(wifiData){
        // 根据WiFiListTableViewCell的属性来赋值，示例：
         cell.wifiNameLabel.text = wifiData[@"propValue"];
        // cell.timeLabel.text = [self formatTimeFromTimeStamp:[wifiData[@"createTime"] longLongValue]];
        // 这里需要根据你的cell具体属性来修改
    }
    
    cell.clickItemBlock = ^{
        [self deleteDateWithId:self.dataArr[indexPath.section][@"id"]];
    };
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArr.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * view  = [UIView new];
    view.backgroundColor  =[UIColor clearColor];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * view  = [UIView new];
    view.backgroundColor  =[UIColor clearColor];
    return view;
}
-(void)deleteDateWithId:(NSString *)wifiId{
    NSMutableDictionary * param = [NSMutableDictionary new];
    [param setValue:wifiId forKey:@"id"];
    WEAK_SELF
    [[APIManager shared] DELETE:[APIPortConfiguration getDeleteProPertUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        NSDictionary * dic = [NSDictionary dictionaryWithDictionary:result];
        if ([dic[@"code"] integerValue] == 0) {
            [SVProgressHUD showSuccessWithStatus:@"删除成功"];
        }
        // 优化：删除成功后，先从数组中移除，再更新UI，不需要重新加载全部数据
        // 找到并删除该项
        for(NSInteger i = 0; i < weakSelf.dataArr.count; i++){
            NSDictionary * item = weakSelf.dataArr[i];
            if([item[@"id"] isEqual:wifiId] || [[item[@"id"] stringValue] isEqualToString:[NSString stringWithFormat:@"%@", wifiId]]){
                [weakSelf.dataArr removeObjectAtIndex:i];
                break;
            }
        }
        
        // 更新UI - 检查数组是否为空来显示/隐藏空视图
        dispatch_main_async_safe(^{
            if(weakSelf.dataArr.count == 0){
                weakSelf.emptyView.hidden = NO;
            }else{
                weakSelf.emptyView.hidden = YES;
            }
            [weakSelf.listTableView reloadData];
        });

    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        NSLog(@"删除失败: %@", msg);
    }];
    
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the user controller.
 }
 */



@end
