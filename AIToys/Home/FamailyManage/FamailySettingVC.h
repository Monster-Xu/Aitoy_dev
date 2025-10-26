//
//  FamailySettingVC.h
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FamailySettingVC : BaseViewController
@property (nonatomic, strong) ThingSmartHomeModel *homeModel;
@property (nonatomic, assign) BOOL isSignalHome;//是否只有一个家庭
@end

NS_ASSUME_NONNULL_END
