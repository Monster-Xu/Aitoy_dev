//
//  DeviceConnectingVC.h
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceConnectingVC : BaseViewController

@property(nonatomic,strong)NSDictionary * connectDeviceInfo;
@property (nonatomic, assign)AddStatusType status;
@end

NS_ASSUME_NONNULL_END
