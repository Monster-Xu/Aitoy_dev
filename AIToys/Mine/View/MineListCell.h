//
//  MineListCell.h
//  DistributionStore
//
//  Created by 乔不赖 on 2020/7/15.
//  Copyright © 2020 OceanCodes. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MineListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UIView *redPointView;


@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic) NSInteger rowInSection;//每一组的行数
@end

NS_ASSUME_NONNULL_END
