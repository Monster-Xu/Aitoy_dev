//
//  SelectAvatarVC.h
//  AIToys
//
//  Created by 乔不赖 on 2025/7/14.
//

#import "PresentAlertVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectAvatarVC : PresentAlertVC
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, copy) void(^sureBlock)(NSString *imgUrl);
@end

NS_ASSUME_NONNULL_END
