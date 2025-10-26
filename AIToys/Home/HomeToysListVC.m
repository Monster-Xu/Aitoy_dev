//
//  HomeToysListVC.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/25.
//

#import "HomeToysListVC.h"
#import "HomeToysItem.h"
#import "ATFontManager.h"
#import <ThingSmartMiniAppBizBundle/ThingSmartMiniAppBizBundle.h>

@interface HomeToysListVC ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colletionBottomH;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *makeTopBtn;

@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic,strong)NSMutableArray <HomeDollModel *>*dataArr;
//修改之前的数据
@property (nonatomic, strong) NSArray <HomeDollModel *>*historyArr;

//拖拉排序相关
@property (nonatomic, strong)UILongPressGestureRecognizer *longPress;//长按手势
@property (nonatomic,strong) HomeToysItem *cell ;
@property (nonatomic,strong)UIView *tempMoveCell;
@property (nonatomic,strong)NSIndexPath *indexPath;
@property (nonatomic,strong)NSIndexPath *moveIndexPath;
@property (nonatomic,assign)CGPoint lastPoint;
@property (nonatomic,assign)BOOL isMoved;//是否移动了
//选中的设备Id
@property (nonatomic,copy)NSString *selectDeviceId;
@end

@implementation HomeToysListVC

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LocalString(@"我的公仔");
    self.dataArr = [[NSMutableArray alloc] initWithArray:self.diyDollList];
    self.historyArr = self.diyDollList;
    [self setupUI];
    if(self.isEdit){
        self.isEdit = NO;
        [self dealViewEditStatus:NO];
    }
}

-(void)setupUI{
    [self setRightBtn];
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout.alloc init];
    layout.itemSize = CGSizeMake(kScreenWidth - 30, 144);;
    layout.minimumLineSpacing = 12;
    layout.minimumInteritemSpacing = 12;
    layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    self.collectionView.collectionViewLayout = layout;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"HomeToysItem" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.deleteBtn setTitle:LocalString(@"删除公仔") forState:0];
    [self.makeTopBtn setTitle:LocalString(@"置顶") forState:0];
}

//设置左侧按钮
-(void)setLeftBtn{
    self.cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 40, 44)];
    [self.cancelBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:UIColorFromRGBA(000000, 0.9) forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = [ATFontManager systemFontOfSize:15 weight:600];
    self.cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* leftItem = [[UIBarButtonItem alloc]initWithCustomView:self.cancelBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

//设置右侧按钮
-(void)setRightBtn{
    self.editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 106, 44)];
    [self.editBtn setTitle:LocalString(@"管理") forState:UIControlStateNormal];
    [self.editBtn setTitleColor:mainColor forState:UIControlStateNormal];
    self.editBtn.titleLabel.font = [ATFontManager systemFontOfSize:15 weight:600];
    self.editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; // 设置内容水平对齐方式为右对齐
    [self.editBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.editBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

//管理按钮
-(void)editBtnClick:(UIButton *)btn{
    [self dealViewEditStatus:self.isMoved];
}

//取消按钮
-(void)cancelBtnClick:(UIButton *)btn{
    [self dealViewEditStatus:NO];
}

//处理页面编辑页状态
- (void)dealViewEditStatus:(BOOL)deal{
    self.isEdit = !self.isEdit;
    [self.editBtn setTitle: self.isEdit ?  LocalString(@"完成"): LocalString(@"管理") forState:UIControlStateNormal];
    self.btnView.hidden = !self.isEdit;
    if(self.isEdit){
        [self setLeftBtn];
        self.colletionBottomH.constant = 68;
        [self.collectionView addGestureRecognizer:self.longPress];
    }else{
        [self setupNavBackBtn];
        self.colletionBottomH.constant = 0;
        self.selectDeviceId = nil;
        if(deal){
            //排序
            [self sortDevice];
        }else{
            self.dataArr = [[NSMutableArray alloc] initWithArray:self.historyArr];
        }
        [self.collectionView removeGestureRecognizer:self.longPress];
    }
    [self.collectionView reloadData];
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeToysItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    cell.index = indexPath.row;
    cell.isEdit = self.isEdit;
    cell.isSel = [self.selectDeviceId isEqualToString:self.dataArr[indexPath.row].Id];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_isEdit){
        self.selectDeviceId = self.dataArr[indexPath.row].Id;
        [self.collectionView reloadData];
    }else{
        // 埋点上报：我的公仔点击
        HomeDollModel *dollModel = self.dataArr[indexPath.row];
        [[AnalyticsManager sharedManager] reportMyDollClickWithId:dollModel.dollModelId ?: @""
                                                             name:dollModel.dollModel.name ?: @""];

        // 跳转小程序
        NSString *currentHomeId = [CoreArchive strForKey:KCURRENT_HOME_ID];
        [[ThingMiniAppClient coreClient] openMiniAppByUrl:@"godzilla://ty7y8au1b7tamhvzij/pages/doll-detail/index" params:@{@"dollId":self.dataArr[indexPath.row].Id,@"BearerId":(kMyUser.accessToken?:@""),@"homeId":(currentHomeId?:@""),@"langType":@"en"}];
    }
}

//拖动排序手势
-(void)pan:(UILongPressGestureRecognizer *)pan
{
    WEAK_SELF
    //判断手势状态
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{

//            self.isEdit = YES;
//            [self.collectionView reloadData];
            [self.collectionView performBatchUpdates:^{
                
            } completion:^(BOOL finished) {
                //判断手势落点位置是否在路径上
                weakSelf.indexPath = [weakSelf.collectionView indexPathForItemAtPoint:[pan locationOfTouch:0 inView:pan.view]];
                //得到该路径上的cell
                weakSelf.cell = (HomeToysItem *)[weakSelf.collectionView cellForItemAtIndexPath:weakSelf.indexPath];
                //截图cell，得到一个view
                weakSelf.tempMoveCell = [weakSelf.cell snapshotViewAfterScreenUpdates:NO];
                weakSelf.tempMoveCell.frame = weakSelf.cell.frame;
                
                 [weakSelf.collectionView addSubview:weakSelf.tempMoveCell];
                weakSelf.cell.hidden = YES;
                //记录当前手指位置
                weakSelf.lastPoint = [pan locationOfTouch:0 inView:pan.view];
                }];
            }
            break;
        case UIGestureRecognizerStateChanged:
        {
            //偏移量
            CGFloat tranX = [pan locationOfTouch:0 inView:pan.view].x - _lastPoint.x;
            CGFloat tranY = [pan locationOfTouch:0 inView:pan.view].y - _lastPoint.y;
            
            //更新cell位置
            _tempMoveCell.center = CGPointApplyAffineTransform(_tempMoveCell.center, CGAffineTransformMakeTranslation(tranX, tranY));
             //记录当前手指位置
            _lastPoint = [pan locationOfTouch:0 inView:pan.view];
            
            for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
                //剔除隐藏的cell
                if ([self.collectionView indexPathForCell:cell] == self.indexPath) {
                    continue;
                }
                //计算中心，如果相交一半就移动
                CGFloat spacingX = fabs(_tempMoveCell.center.x - cell.center.x);
                CGFloat spacingY = fabs(_tempMoveCell.center.y - cell.center.y);
                if (spacingX <= _tempMoveCell.bounds.size.width / 2.0f && spacingY <= _tempMoveCell.bounds.size.height / 2.0f){
                    self.moveIndexPath = [self.collectionView indexPathForCell:cell];
                    //更新数据源（移动前必须更新数据源）
                    [self updateDataSource];
                    //移动cell
                    [self.collectionView moveItemAtIndexPath:self.indexPath toIndexPath:self.moveIndexPath];
                   //设置移动后的起始indexPath
                    self.indexPath = self.moveIndexPath;
                    break;
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self.collectionView performBatchUpdates:^{
                
            } completion:^(BOOL finished) {
                weakSelf.cell  = (HomeToysItem *)[weakSelf.collectionView cellForItemAtIndexPath:weakSelf.indexPath];
                [UIView animateWithDuration:0.1 animations:^{
                    weakSelf.tempMoveCell.center = weakSelf.cell.center;
                } completion:^(BOOL finished) {
                    [weakSelf.tempMoveCell removeFromSuperview];
                    weakSelf.cell.hidden = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.collectionView reloadData];
                    });
                }];

            }];
        }
            break;
        default:
            break;
    }
}

-(void)updateDataSource
{
    self.isMoved = YES;
    //取出源item数据
    id objc =  [self.dataArr objectAtIndex:self.indexPath.row];
    //从资源数组中移除该数据,不能直接删除某个数据，因为有可能有相同的数据，一下子删除了多个数据源，造成clash
    //    [[self.numArray objectAtIndex:self.indexPath.section] removeObject:objc];
    
    //删除指定位置的数据，这样就只删除一个，不会重复删除
    
    [self.dataArr removeObjectAtIndex:self.indexPath.row];
    //将数据插入到资源数组中的目标位置上
    [self.dataArr insertObject:objc atIndex:self.moveIndexPath.row];
}

//删除设备
- (IBAction)deleteDeviceBtnClick:(id)sender {
    if([PublicObj isEmptyObject:self.selectDeviceId]){
        [SVProgressHUD showErrorWithStatus:LocalString(@"请选择公仔")];
        return;
    }
    WEAK_SELF
    [LGBaseAlertView showAlertWithTitle:LocalString(@"确定要删除设备吗？")  content:nil cancelBtnStr:LocalString(@"取消") confirmBtnStr:LocalString(@"删除") confirmBlock:^(BOOL isValue, id obj) {
        if (isValue){
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:self.selectDeviceId forKey:@"id"];
            [[APIManager shared] DELETE:[APIPortConfiguration getDoolDeleteUrl] parameter:dic success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
                [SVProgressHUD showSuccessWithStatus:LocalString(@"删除成功")];
                NSInteger temp = 0;
                for (int i = 0; i<self.dataArr.count; i++) {
                    if([weakSelf.selectDeviceId isEqualToString:weakSelf.dataArr[i].Id]){
                        temp = i;
                        break;
                    }
                }
                [weakSelf.dataArr removeObjectAtIndex:temp];
                weakSelf.historyArr = weakSelf.dataArr;
                [self.collectionView reloadData];
                //删除设备不退出编辑状态
//                [weakSelf dealViewEditStatus:NO];
            } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
                NSLog(@"remove failure: %@", error);
            }];
        }
    }];
}

//置顶设备
- (IBAction)setDeviceTop:(id)sender {
    if([PublicObj isEmptyObject:self.selectDeviceId]){
        [SVProgressHUD showErrorWithStatus:LocalString(@"请选择设备")];
        return;
    }
    id objc;
    NSInteger temp = 0;
    for (int i = 0; i<self.dataArr.count; i++) {
        if([self.selectDeviceId isEqualToString:self.dataArr[i].Id]){
            temp = i;
            objc = self.dataArr[i];
            break;
        }
    }
    [self.dataArr removeObjectAtIndex:temp];
    
    //将数据插入到资源数组中的目标位置上
    [self.dataArr insertObject:objc atIndex:0];
    [self.collectionView reloadData];
    self.isMoved = YES;
}

//设备排序接口
-(void)sortDevice{
    NSString *idStr = @"";
    NSMutableArray *IdArr = [NSMutableArray array];
    for (HomeDollModel *model in self.dataArr) {
        [IdArr addObject:model.Id];
//        if([PublicObj isEmptyObject:idStr]){
//            idStr = model.Id;
//        }else{
//            idStr = [idStr stringByAppendingFormat:@",%@",model.Id];
//        }
    }
    WEAK_SELF
    //设备或群组排序
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:IdArr forKey:@"sortIds"];
    [[APIManager shared] PUTJSON:[APIPortConfiguration getDoolSortUrl] parameter:dic success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        NSLog(@"sort device or group success");
        [SVProgressHUD showSuccessWithStatus:LocalString(@"操作成功")];
        weakSelf.historyArr = weakSelf.dataArr;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeDeviceRefresh" object:nil];
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        NSLog(@"sort device or group failure: %@", error);
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
