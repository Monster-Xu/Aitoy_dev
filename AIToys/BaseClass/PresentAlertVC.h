//
//  PresentAlertVC.h
//  XingChiLive
//
//  Created by 张海阔 on 2019/11/27.
//  Copyright © 2019 Yunhai. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PresentAlertVC : BaseViewController
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *alertView;
//出现的动画
- (void)showView;
//消失的动画，handle为YES则页面消失后做一些操作，否则页面消失后不做任何操作
- (void)dismiss:(NSInteger)handle;
//bgView上的点击事件
- (void)tapAction:(UITapGestureRecognizer *)tap;
@end

NS_ASSUME_NONNULL_END
