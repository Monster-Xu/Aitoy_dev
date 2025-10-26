//
//  FamailyNameCell.h
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FamailyNameCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightImgW;

@property (nonatomic, strong)ThingSmartHomeModel *model;
@end

NS_ASSUME_NONNULL_END
