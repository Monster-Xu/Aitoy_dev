//
//  DeviceAddVC.h
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import "BaseViewController.h"
#import "DeviceAddCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceAddVC : BaseViewController
@property (nonatomic, strong) ThingBLEAdvModel  *deviceInfo;//扫描到的设备
@property (nonatomic, strong) NSDictionary  *deviceDic;//扫描到的设备
@property (nonatomic, assign) long long homeId;
@property (nonatomic, assign)AddStatusType status;
@end

NS_ASSUME_NONNULL_END
