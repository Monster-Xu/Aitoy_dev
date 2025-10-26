//
//  AccessPermissionsSettingCell.h
//  AIToys
//
//  Created by qdkj on 2025/7/17.
//

#import <UIKit/UIKit.h>
#import "MineItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AccessPermissionsSettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightImgW;
@property (nonatomic, strong) MineItemModel *model;
@end

NS_ASSUME_NONNULL_END
