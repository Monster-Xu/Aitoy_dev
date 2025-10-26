//
//  SwitchFamailyCell.h
//  AIToys
//
//  Created by qdkj on 2025/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwitchFamailyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *chooseImgView;
@property (weak, nonatomic) IBOutlet UIImageView *homeImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTrailing;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong)ThingSmartHomeModel *model;
@property(nonatomic, assign) BOOL isSel;
@end

NS_ASSUME_NONNULL_END
