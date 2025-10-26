//
//  DeviceHavenFindCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceHavenFindCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong)NSArray *deviceList;
@property (nonatomic, copy) void(^itemClickBlock)(NSInteger index);
@end

NS_ASSUME_NONNULL_END
