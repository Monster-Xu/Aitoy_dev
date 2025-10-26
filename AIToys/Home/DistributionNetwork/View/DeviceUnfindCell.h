//
//  DeviceUnfindCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceUnfindCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *tryBtn;
@property (nonatomic, copy) void(^tryBlock)(void);
@end

NS_ASSUME_NONNULL_END
