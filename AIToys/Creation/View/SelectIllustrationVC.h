//
//  SelectIllustrationVC.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/15.
//  功能：选择官方插画
//

#import "PresentAlertVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectIllustrationVC : PresentAlertVC

/// 当前选中的插画URL（用于预选）
@property (nonatomic, copy) NSString *imgUrl;

/// 确定选择后的回调，返回选中的插画URL
@property (nonatomic, copy) void(^sureBlock)(NSString *imgUrl);

@end

NS_ASSUME_NONNULL_END
