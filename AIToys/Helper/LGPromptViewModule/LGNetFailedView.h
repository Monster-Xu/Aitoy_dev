//
//  LGNetFailedView.h
//  QiDianProhibit
//
//  Created by KWOK on 2019/4/24.
//  Copyright © 2019 Henan Qidian Network Technology Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LGNetFailedViewDelegate<NSObject>
@optional
- (void)netFailedViewClickRequest;
@end

@interface LGNetFailedView : UIView
@property (nonatomic, weak) id<LGNetFailedViewDelegate>  delegate;

/**
 @ 把提示添加到View上
 * @pram view 将要添加到的View
 * @pram text 提示语
 * @pram delegate 代理
 * @pram buttonName 按钮名称
 * @pram image 提示图片
 */
+ (instancetype)showAddedTo:(UIView *)view text:(NSString *)text delegate:(id)delegate buttonName:(NSString *)buttonName image:(UIImage *)image;
+ (instancetype)showAddedTo:(UIView *)view delegate:(id)delegate;
+ (void)cancelForView:(UIView *)view;
@end
