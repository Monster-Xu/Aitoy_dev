//
//  HomeDeviceListVC.h
//  AIToys
//
//  Created by qdkj on 2025/6/25.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeDeviceListVC : BaseViewController
@property(strong, nonatomic) ThingSmartHome *home;
@property (nonatomic, assign) BOOL isEdit;//是否是编辑状态
@end

NS_ASSUME_NONNULL_END
