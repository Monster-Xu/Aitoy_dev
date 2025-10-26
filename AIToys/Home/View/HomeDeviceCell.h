//
//  HomeDeviceCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeDeviceCell : UITableViewCell
@property (nonatomic, strong)NSArray <ThingSmartDeviceModel *> *deviceList;
@property (nonatomic, copy) void(^itemClickBlock)(NSInteger index);
@property (nonatomic, copy) void(^manageBlock)(void);
@end

NS_ASSUME_NONNULL_END
