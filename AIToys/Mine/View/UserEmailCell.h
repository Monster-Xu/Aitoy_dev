//
//  UserEmailCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/7/16.
//

#import <UIKit/UIKit.h>
#import "MineItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserEmailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIImageView *rightImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightImgW;

@property (nonatomic, strong) MineItemModel *model;
@end

NS_ASSUME_NONNULL_END
