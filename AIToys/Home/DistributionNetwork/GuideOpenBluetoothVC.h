//
//  GuideOpenBluetoothVC.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/29.
//

#import "PresentAlertVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface GuideOpenBluetoothVC : PresentAlertVC
@property (nonatomic, copy) void(^clickBlock)(void);
@end

NS_ASSUME_NONNULL_END
