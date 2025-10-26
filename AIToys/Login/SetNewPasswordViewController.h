//
//  SetNewPasswordViewController.h
//  AIToys
//
//  Created by qdkj on 2025/6/20.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SetNewPasswordViewController : BaseViewController
@property (nonatomic,copy)NSString *numStr;//账号
@property (nonatomic,copy)NSString *codeStr;//验证码
@property (nonatomic,assign) EmailType type;
@end

NS_ASSUME_NONNULL_END
