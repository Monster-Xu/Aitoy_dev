//
//  GlobalBluetoothManager.h
//  AIToys
//
//  Created by 乔不赖 on 2025/7/1.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobalBluetoothManager : NSObject<CBCentralManagerDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) BOOL isAuthorized;//是否授权
+ (instancetype)sharedManager;
@end

NS_ASSUME_NONNULL_END
