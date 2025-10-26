//
//  HomeToysItem.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/21.
//

#import <UIKit/UIKit.h>
#import "HomeDollModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeToysItem : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;

@property (weak, nonatomic) IBOutlet UIView *topLeftView;
@property (weak, nonatomic) IBOutlet UIImageView *topLeftImgView;
@property (weak, nonatomic) IBOutlet UILabel *topLeftTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyNamLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *toysImgView;
@property (weak, nonatomic) IBOutlet UIView *rankView;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chooseImgView;

@property(nonatomic, assign) BOOL isEdit;
@property(nonatomic, assign) BOOL isSel;
@property(nonatomic, assign) NSInteger index;
@property (nonatomic, strong) HomeDollModel *model;
@end

NS_ASSUME_NONNULL_END
