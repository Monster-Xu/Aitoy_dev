//
//  GlobalBluetoothManager.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/1.
//

#import "GlobalBluetoothManager.h"

@implementation GlobalBluetoothManager
+ (instancetype)sharedManager {
    static GlobalBluetoothManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
    return self;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSString *stateString = nil;
    switch (central.state) {
        case CBManagerStatePoweredOn:
            stateString = @"蓝牙已开启";
            self.isOpen = YES;
            self.isAuthorized = YES;
            break;
        case CBManagerStatePoweredOff:
            stateString = @"蓝牙已关闭";
            self.isOpen = NO;
            self.isAuthorized = NO;
            break;
        case CBManagerStateUnauthorized:
            stateString = @"蓝牙未授权";
            self.isAuthorized = NO;
            self.isOpen = NO;
            break;
        case CBManagerStateUnsupported:
            stateString = @"设备不支持蓝牙";
            self.isOpen = NO;
            self.isAuthorized = NO;
            break;
        default:
            stateString = @"蓝牙状态未知";
            self.isOpen = NO;
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BluetoothStateChanged" object:@(self.isOpen)];
}
@end
