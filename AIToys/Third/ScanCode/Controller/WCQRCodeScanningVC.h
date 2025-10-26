//
//  WCQRCodeScanningVC.h
//  SGQRCodeExample
//
//  Created by kingsic on 17/3/20.
//  Copyright © 2017年 kingsic. All rights reserved.
//

#import "BaseViewController.h"

@interface WCQRCodeScanningVC : BaseViewController
@property (nonatomic, copy) void(^scanResultBlock)(NSString *result);
@end
