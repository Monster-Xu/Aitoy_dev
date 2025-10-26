//
//  DeviceHavenFindItem.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceHavenFindItem : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic, copy) void(^clickItemBlock)(void);
@end

NS_ASSUME_NONNULL_END
