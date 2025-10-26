//
//  FindDeviceNoBluetoothCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FindDeviceNoBluetoothCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic, assign) BOOL isBluetooth;
@end

NS_ASSUME_NONNULL_END
