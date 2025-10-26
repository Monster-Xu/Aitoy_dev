//
//  SelectIllustrationVC.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/15.
//  功能：选择官方插画
//

#import "SelectIllustrationVC.h"
#import "SelctAvatarCell.h"
#import "ATFontManager.h"
#import "AFStoryAPIManager.h"
#import "APIResponseModel.h"
#import "IllustrationModel+Selection.h"

@interface SelectIllustrationVC ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<IllustrationModel *> *dataArr;

@end

@implementation SelectIllustrationVC

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(84, 84);
        layout.minimumLineSpacing = 40;
        layout.minimumInteritemSpacing = 30;
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"SelctAvatarCell" bundle:nil] 
              forCellWithReuseIdentifier:@"cell"];
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

- (void)setupUI {
    self.view.backgroundColor = UIColorFromRGBA(0, 0.5);
    self.alertView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight - StatusBar_Height);
    self.alertView.layer.cornerRadius = 12;
    self.alertView.backgroundColor = [UIColor whiteColor];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = LocalString(@"选择插画");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [ATFontManager systemFontOfSize:17];
    titleLabel.textColor = UIColorFromRGBA(0, 0.9);
    [self.alertView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.alertView).offset(10);
        make.left.equalTo(self.alertView).offset(20);
        make.right.equalTo(self.alertView).offset(-20);
        make.height.mas_equalTo(40);
    }];
    
    // 完成按钮
    UIButton *sureBtn = [[UIButton alloc] init];
    sureBtn.titleLabel.font = [ATFontManager systemFontOfSize:16];
    [sureBtn setTitle:LocalString(@"完成") forState:UIControlStateNormal];
    [sureBtn setTitleColor:mainColor forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.alertView);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(50);
        make.centerY.equalTo(titleLabel);
    }];
    
    // 集合视图
    [self.alertView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
        make.left.right.bottom.equalTo(self.alertView);
    }];
}

- (void)loadData {
    WEAK_SELF
    [SVProgressHUD show];
    
    // 使用 AFStoryAPIManager 获取官方插画列表
    [[AFStoryAPIManager sharedManager] getIllustrationsSuccess:^(IllustrationListResponseModel *response) {
        [SVProgressHUD dismiss];
        
        weakSelf.dataArr = [NSMutableArray arrayWithArray:response.list];
        
        // 如果有预选的URL，标记为选中
        if (weakSelf.imgUrl) {
            for (IllustrationModel *item in weakSelf.dataArr) {
                if ([item.avatarUrl isEqualToString:weakSelf.imgUrl]) {
                    item.isSelect = YES;
                    break;
                }
            }
        }
        
        [weakSelf.collectionView reloadData];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:error.localizedDescription ?: LocalString(@"加载失败")];
    }];
}

#pragma mark - Actions

// 关闭
- (void)close {
    [self dismiss:0];
}

// 确定
- (void)sureBtnClick {
    NSString *selectUrl = @"";
    NSString *selectName = @"";
    
    // 查找选中的插画
    for (IllustrationModel *item in self.dataArr) {
        if (item.isSelect) {
            selectUrl = item.avatarUrl;
            selectName = item.avatarName;
            break;
        }
    }
    
    if (selectUrl.length > 0) {
        // 只有当选择的URL与之前不同时才回调
        if (![selectUrl isEqualToString:self.imgUrl]) {
            NSLog(@"=== 选择插画 ===");
            NSLog(@"插画名称: %@", selectName);
            NSLog(@"插画URL: %@", selectUrl);
            NSLog(@"===============");
            
            // 只回调，不上传
            if (self.sureBlock) {
                self.sureBlock(selectUrl);
            }
        }
        [self dismiss:0];
    } else {
        [SVProgressHUD showErrorWithStatus:LocalString(@"请选择插画")];
    }
}

#pragma mark - Animations

// 出现的动画
- (void)showView {
    [UIView animateWithDuration:0.2 animations:^{
        self.alertView.transform = CGAffineTransformMakeTranslation(0, -self.alertView.height);
    } completion:nil];
}

// 消失的动画
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView 
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelctAvatarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" 
                                                                       forIndexPath:indexPath];
    
    IllustrationModel *illustration = self.dataArr[indexPath.row];
    cell.model = (id)illustration;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 取消所有选中状态
    for (IllustrationModel *item in self.dataArr) {
        item.isSelect = NO;
    }
    
    // 设置当前选中
    self.dataArr[indexPath.row].isSelect = YES;
    
    [self.collectionView reloadData];
}

@end
