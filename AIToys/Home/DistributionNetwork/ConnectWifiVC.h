//
//  ConnectWifiVC.h
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConnectWifiVC : BaseViewController
@property(nonatomic, copy) NSString *UUID;
@property(nonatomic, copy) NSString *ssid;
@property (nonatomic, assign) long long homeId;
@end

NS_ASSUME_NONNULL_END
