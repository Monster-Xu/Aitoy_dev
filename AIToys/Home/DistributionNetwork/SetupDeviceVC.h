//
//  SetupDeviceVC.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/29.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SetupDeviceVC : BaseViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *imgView;
@property (weak, nonatomic) IBOutlet UILabel *detaileLabel;
@property (weak, nonatomic) IBOutlet UIButton *resetBtn;
@property (nonatomic, copy) void(^clickBlock)(void);
@end

NS_ASSUME_NONNULL_END
