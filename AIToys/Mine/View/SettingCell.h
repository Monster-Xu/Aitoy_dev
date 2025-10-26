//
//  SettingCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/7/13.
//

#import <UIKit/UIKit.h>
#import "MineItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightImgW;

@property (nonatomic, assign)BOOL isShowSub;//是否显示右边标题
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic) NSInteger rowInSection;//每一组的行数

@property (nonatomic, strong) MineItemModel *model;
@end

NS_ASSUME_NONNULL_END
