//
//  LGRemindDialogView.h
//  QiDianProhibit
//
//  Created by KWOK on 2019/4/24.
//  Copyright © 2019 Henan Qidian Network Technology Co. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/*---------------通用 提示对话框视图---------------*/
@interface LGRemindDialogView : UILabel
//实例化
- (instancetype)initWithSuperView:(UIView *)superView;
//显示内容(延迟消失)
- (void)displayWithContentString:(NSString *)contentString;
- (void)displayWithContentStr:(NSString *)contentString;
@end

NS_ASSUME_NONNULL_END
