//
//  IllustrationModel+Selection.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/15.
//  为 IllustrationModel 添加选中状态支持
//

#import "APIResponseModel.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface IllustrationModel (Selection)

/// 是否选中（用于UI选择状态）
@property (nonatomic, assign) BOOL isSelect;

@end

NS_ASSUME_NONNULL_END
