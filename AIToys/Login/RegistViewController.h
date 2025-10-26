//
//  RegistViewController.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/18.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RegistViewController : BaseViewController
@property (nonatomic,copy)NSString *numStr;
@property (nonatomic,assign) EmailType type;//0.注册 1.忘记密码
@end

NS_ASSUME_NONNULL_END
