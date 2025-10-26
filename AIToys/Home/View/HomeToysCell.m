//
//  HomeToysCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/21.
//

#import "HomeToysCell.h"
#import "HomeToysItem.h"
#import <AudioToolbox/AudioToolbox.h>
@interface HomeToysCell()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIView *picView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong)UILongPressGestureRecognizer *longPress;//长按手势
@end

@implementation HomeToysCell

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout.alloc init];
        layout.itemSize = CGSizeMake(kScreenWidth - 15 - 24, 144);
//        layout.minimumLineSpacing = 12;
        layout.minimumInteritemSpacing = 12;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 0);
        _collectionView = [UICollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"HomeToysItem" bundle:nil] forCellWithReuseIdentifier:@"cell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (void)setDataArr:(NSArray<HomeDollModel *> *)dataArr{
    _dataArr = dataArr;
    [self.collectionView reloadData];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self.picView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.picView);
    }];
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    self.longPress.minimumPressDuration = 0.6;
    [self.collectionView addGestureRecognizer:self.longPress];
}

//长按进入编辑页面
-(void)pan:(UILongPressGestureRecognizer *)pan{
    if (pan.state == UIGestureRecognizerStateBegan) {
            // 处理长按开始逻辑
            NSLog(@"长按开始");
        // 触发单次震动
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        } else if (pan.state == UIGestureRecognizerStateEnded) {
            // 处理长按结束逻辑
            NSLog(@"长按结束");
            if(self.manageBlock){
                self.manageBlock();
            }
        }
    
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count > 5 ? 5 :self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeToysItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.itemClickBlock) {
        self.itemClickBlock(indexPath.row);
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
