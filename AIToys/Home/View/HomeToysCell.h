//
//  HomeToysCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/21.
//

#import <UIKit/UIKit.h>
#import "HomeDollModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeToysCell : UITableViewCell
@property (nonatomic, strong) NSArray <HomeDollModel *> *dataArr;
@property (nonatomic, copy) void(^itemClickBlock)(NSInteger index);
@property (nonatomic, copy) void(^manageBlock)(void);
@end

NS_ASSUME_NONNULL_END
