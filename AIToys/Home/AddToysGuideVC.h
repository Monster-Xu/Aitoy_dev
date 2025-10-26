//
//  AddToysGuideVC.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/22.
//

#import "PresentAlertVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddToysGuideVC : PresentAlertVC
@property (nonatomic, copy) void(^sureBlock)(void);
@end

NS_ASSUME_NONNULL_END
