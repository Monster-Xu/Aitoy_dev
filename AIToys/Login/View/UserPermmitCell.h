//
//  UserPermmitCell.h
//  AIToys
//
//  Created by qdkj on 2025/7/9.
//

#import <UIKit/UIKit.h>
#import "MineItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserPermmitCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *selImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLab;

@property (nonatomic, strong)MineItemModel *model;
@end

NS_ASSUME_NONNULL_END
