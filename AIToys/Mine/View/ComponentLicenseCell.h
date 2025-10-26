//
//  ComponentLicenseCell.h
//  AIToys
//
//  Created by qdkj on 2025/7/18.
//

#import <UIKit/UIKit.h>
#import "ComponentLicenseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ComponentLicenseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *licenceLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic, copy) void(^clickItemBlock)(NSInteger tag);
@property (nonatomic, strong)ComponentLicenseModel *model;
@property (nonatomic, assign) NSInteger row;
@end

NS_ASSUME_NONNULL_END
