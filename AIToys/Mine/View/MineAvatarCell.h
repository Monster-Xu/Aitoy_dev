//
//  MineAvatarCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/7/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MineAvatarCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;

@end

NS_ASSUME_NONNULL_END
