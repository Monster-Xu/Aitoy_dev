//
//  FindDeviceAlertCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FindDeviceAlertCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, copy) void(^clickBlock)(void);
@end

NS_ASSUME_NONNULL_END
