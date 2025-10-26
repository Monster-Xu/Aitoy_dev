//
//  FamailyMemberCell.h
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FamailyMemberCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (nonatomic, assign) BOOL isExpire;
@end

NS_ASSUME_NONNULL_END
