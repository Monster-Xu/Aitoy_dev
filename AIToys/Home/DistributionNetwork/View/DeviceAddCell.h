//
//  DeviceAddCell.h
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import <UIKit/UIKit.h>
#import "DACircularProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceAddCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *addImgView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingCircle;

@property (nonatomic, strong) DACircularProgressView *progressView;
@property (nonatomic, assign) AddStatusType type;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) void(^addBlock)(void);
@property (nonatomic, copy) void(^editBlock)(void);
@end

NS_ASSUME_NONNULL_END
