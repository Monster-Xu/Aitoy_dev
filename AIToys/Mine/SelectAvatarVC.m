//
//  SelectAvatarVC.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/14.
//

#import "SelectAvatarVC.h"
#import "SelctAvatarCell.h"
#import "ATFontManager.h"

@interface SelectAvatarVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic,strong)NSMutableArray <AvatarModel *>*dataArr;
@end

@implementation SelectAvatarVC

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout.alloc init];
        layout.itemSize = CGSizeMake(84,84);
        layout.minimumLineSpacing = 40;
        layout.minimumInteritemSpacing = 30;
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
        _collectionView = [UICollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"SelctAvatarCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadData];
}

-(void)setupUI{
    self.view.backgroundColor = UIColorFromRGBA(000000, 0.5);
    self.alertView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight-StatusBar_Height);
    self.alertView.layer.cornerRadius = 12;
    self.alertView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = LocalString(@"头像");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [ATFontManager systemFontOfSize:17];
    titleLabel.textColor = UIColorFromRGBA(000000, 0.9);
    [self.alertView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.alertView).offset(10);
        make.left.equalTo(self.alertView).offset(20);
        make.right.equalTo(self.alertView).offset(-20);
        make.height.mas_equalTo(40);
    }];
    
    UIButton *sureBtn = [[UIButton alloc] init];
    sureBtn.titleLabel.font = [ATFontManager systemFontOfSize:16];
    [sureBtn setTitle:LocalString(@"完成") forState:0];
    [sureBtn setTitleColor:mainColor forState:0];
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.alertView);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(50);
        make.centerY.equalTo(titleLabel);
    }];
    
    [self.alertView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
        make.left.right.bottom.equalTo(self.alertView);
    }];
    
}

-(void)loadData{
    WEAK_SELF
    [[APIManager shared] GET:[APIPortConfiguration getAppAvatarListUrl] parameter:nil success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        weakSelf.dataArr = [NSMutableArray arrayWithArray:[AvatarModel mj_objectArrayWithKeyValuesArray:data]];
        if(self.imgUrl){
            for (AvatarModel *item in weakSelf.dataArr) {
                if([item.avatarUrl isEqualToString:weakSelf.imgUrl]){
                    item.isSelect = YES;
                }
            }
        }
        [weakSelf.collectionView reloadData];
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        
    }];
}


//关闭
-(void)close{
    [self dismiss:0];
}

//确定
-(void)sureBtnClick{
    NSString *selectUrl = @"";
    for (AvatarModel *item in self.dataArr) {
        if(item.isSelect){
            selectUrl = item.avatarUrl;
            break;
        }
    }
    if(selectUrl.length > 0){
        if(![selectUrl isEqualToString:self.imgUrl]){
            //上传头像
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:selectUrl forKey:@"avatarUrl"];
            WEAK_SELF
            [[APIManager shared] PUTJSON:[APIPortConfiguration getAppAvatarUpdateUrl] parameter:dic success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
                [SVProgressHUD showSuccessWithStatus:LocalString(@"设置成功")];
                if (weakSelf.sureBlock) {
                    weakSelf.sureBlock(selectUrl);
                }
                [weakSelf dismiss:0];
            } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
                [SVProgressHUD showErrorWithStatus:msg];
                [weakSelf dismiss:0];
            }];
        }else{
            [self dismiss:0];
        }
    }else{
        [SVProgressHUD showErrorWithStatus:LocalString(@"请选择头像")];
        [self dismiss:0];
    }
    
    
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

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelctAvatarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    for (AvatarModel *item in self.dataArr) {
        item.isSelect = NO;
    }
    self.dataArr[indexPath.row].isSelect = YES;
    [self.collectionView reloadData];
    
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
