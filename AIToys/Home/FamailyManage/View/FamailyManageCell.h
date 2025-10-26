//
//  FamailyManageCell.h
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FamailyManageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) ThingSmartHomeModel *model;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic) NSInteger rowInSection;//每一组的行数
@end

NS_ASSUME_NONNULL_END
