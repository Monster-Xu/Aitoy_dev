//
//  GuideOpenAppPermmitCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GuideOpenAppPermmitCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (nonatomic, copy) void(^clickBlock)(void);
@end

NS_ASSUME_NONNULL_END
