//
//  LGGuideViewController.m
//  GasClient
//
//  Created by KWOK on 2021/4/1.
//

#import "LGGuideViewController.h"
#import "LGGuideCollectionViewCell.h"
#import "ATFontManager.h"

@interface LGGuideViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSArray* _objs;
    void(^_block)(void);
}
@property (nonatomic, strong) UICollectionView* collection;
@property (nonatomic, strong) UIButton* joinBtn;

@end

@implementation LGGuideViewController

- (instancetype)initWithBlock:(void(^)(void))block
{
    if(self = [super init]){
        _block = block;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _objs = @[@"guide1", @"guide2", @"guide3"];
    [self.collection mas_makeConstraints:^(MASConstraintMaker *make) {
           make.edges.mas_equalTo(self.view);
    }];
    [self.collection reloadData];
    [self.view addSubview:self.joinBtn];
}

- (void)startGoApp
{
    if(_block)_block();
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        if(_block)_block();
    }
}
#pragma mark--------collectionDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _objs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LGGuideCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"lg_guide_cell" forIndexPath:indexPath];
    NSString* imgStr = _objs[indexPath.row];
    cell.imgView.image = QD_IMG(imgStr);
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (UICollectionView *)collection
{
    if(!_collection){
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = CGSizeMake(kScreenSize.width, kScreenSize.height);
        _collection = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        [self.view addSubview:_collection];
        [_collection setBackgroundColor:UIColorFromRGB(0xffffff)];
        [_collection setShowsHorizontalScrollIndicator:NO];
        _collection.pagingEnabled = YES;
        _collection.delegate = self;
        _collection.dataSource = self;
        [_collection registerClass:[LGGuideCollectionViewCell class] forCellWithReuseIdentifier:@"lg_guide_cell"];
    }
    return _collection;
}

- (UIButton *)joinBtn {
    if(!_joinBtn){
        _joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _joinBtn.frame = CGRectMake(kScreenWidth - 70, IS_iPhoneX?40:50, 50, 30);
        _joinBtn.backgroundColor = UIColor.whiteColor;
        _joinBtn.layer.cornerRadius = 5;
        [_joinBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
        [_joinBtn setTitle:@"跳过" forState:UIControlStateNormal];
        [_joinBtn.titleLabel setFont:[ATFontManager systemFontOfSize:16]];
        [_joinBtn addTarget:self action:@selector(startGoApp) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_joinBtn];
    }
    return _joinBtn;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
