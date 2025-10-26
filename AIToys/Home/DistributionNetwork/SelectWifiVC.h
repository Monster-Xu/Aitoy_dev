//
//  SelectWifiVC.h
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectWifiVC : BaseViewController
@property(nonatomic, copy) NSString *UUID;
@property (nonatomic, assign) long long homeId;
@property (nonatomic, strong)NSArray *wifiArr;
@end

NS_ASSUME_NONNULL_END
