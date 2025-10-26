//
//  HomeNoDeviceCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,CellType) {
    CellTypeDevice = 0,
    CellTypeToys,
};

@interface HomeNoDeviceCell : UITableViewCell
@property (nonatomic, assign) CellType type;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (nonatomic, copy) void (^addBtnClickBlock) (void);
@end

NS_ASSUME_NONNULL_END
