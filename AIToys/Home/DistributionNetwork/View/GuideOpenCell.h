//
//  GuideOpenCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GuideOpenCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic, assign) BOOL isBluetooth;
@end

NS_ASSUME_NONNULL_END
