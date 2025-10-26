//
//  LGInputAlertView.h
//  QiDianProhibit
//
//  Created by KWOK on 2019/4/24.
//  Copyright © 2019 Henan Qidian Network Technology Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LGAlertView;

typedef void(^LGAlertViewBlock)(LGAlertView *alertView, NSInteger index);

@interface LGAlertView : UIView
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *info;
@property (nonatomic, copy) NSArray  *buttons;

+ (void)showWithTitle:(NSString *)title message:(NSString *)message  action:(LGAlertViewBlock)action;

+ (void)showWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons action:(LGAlertViewBlock)action;

+ (void)showWithTitle:(NSString *)title message:(NSString *)message info:(NSString *)info buttons:(NSArray *)buttons action:(LGAlertViewBlock)action;

@end


#pragma mark - LGAppUpdateView

@interface LGAppUpdateView : LGAlertView

+ (void)showUpDataAlertViewWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons action:(LGAlertViewBlock)action;

@end
