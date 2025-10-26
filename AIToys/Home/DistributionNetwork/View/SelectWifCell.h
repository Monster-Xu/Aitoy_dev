//
//  SelectWifCell.h
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectWifCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *isPwdImgView;
@property (weak, nonatomic) IBOutlet UIImageView *wifiImgView;

@property (nonatomic, strong) NSDictionary *dic;
@end

NS_ASSUME_NONNULL_END
