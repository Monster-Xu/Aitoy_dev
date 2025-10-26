//
//  CodeViewController.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/18.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CodeViewController : BaseViewController
@property (nonatomic,assign) EmailType type;//0.注册 1.忘记密码
@property (nonatomic,copy)NSString *numStr;
@end

NS_ASSUME_NONNULL_END
