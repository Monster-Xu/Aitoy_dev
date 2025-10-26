//
//  SelctAvatarCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/7/14.
//

#import <UIKit/UIKit.h>
#import "AvatarModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelctAvatarCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImgView;
@property (nonatomic, strong)AvatarModel *model;


@end

NS_ASSUME_NONNULL_END
