//
//  DeviceManuallyAddCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import <UIKit/UIKit.h>
#import "FindDollModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceManuallyAddCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *devicebtnClick;
@property (nonatomic, strong) NSArray <FindDollModel *> *dataArr;
@property (nonatomic, copy) void(^devicebtnClickClickBlock)(void);
@end

NS_ASSUME_NONNULL_END
