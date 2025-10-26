//
//  LGTipView.h
//  QiDianProhibit
//
//  Created by KWOK on 2019/12/30.
//  Copyright © 2019 Henan Qidian Network Technology Co. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, Tip_Type) {
    Tip_Type_Default,
    Tip_Type_Perfect,//完善名片
    Tip_Type_Auth//实名认证
};

@protocol LGTipViewDelegate<NSObject>
@optional
- (void)LGTipViewSureBtnClick;
@end

@interface LGTipView : UIView
@property (nonatomic, weak) id<LGTipViewDelegate>  delegate;
/**
 @ 把提示添加到View上
 * @pram view 将要添加到的View
 * @pram text 提示语
 * @pram delegate 代理
 * @pram buttonName 按钮名称
 * @pram image 提示图片
 */
+ (void)showAddedTo:(UIView *)view delegate:(id)delegate;
+ (void)showAuthAddedTo:(UIView *)view delegate:(id)delegate;
+ (void)cancelForView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
