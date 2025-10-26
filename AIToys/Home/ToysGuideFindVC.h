//
//  ToysGuideFindVC.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/25.
//

#import "PresentAlertVC.h"
#import "HomeDollModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ToysGuideFindVC : PresentAlertVC
@property (nonatomic, strong) FindDollModel *model;
@property (nonatomic, copy) void(^sureBlock)(void);
@end

NS_ASSUME_NONNULL_END
