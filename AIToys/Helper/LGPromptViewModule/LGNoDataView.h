//
//  LGNoDataView.h
//  QiDianProhibit
//
//  Created by KWOK on 2019/4/24.
//  Copyright © 2019 Henan Qidian Network Technology Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LGNoDataViewDelegate<NSObject>
@optional
- (void)LGNoDataViewClick;
@end

@interface LGNoDataView : UIView
@property (nonatomic, weak) id<LGNoDataViewDelegate>  delegate;
/**
 @添加到指定View

 @param view 将要加载的View
 @param text 提示语
 @param image 提示图片
 @return 提示View
 */
+ (instancetype)showAddTo:(UIView *)view
                 withText:(NSString *)text
             withImage:(UIImage *)image;
+ (instancetype)showAddTo:(UIView *)view
    withText:(NSString *)text;
+ (instancetype)showAddToNoHeader:(UIView *)view
    withText:(NSString *)text;
+ (instancetype)showAddTo:(UIView *)view;
+ (instancetype)showAddToSubView:(UIView *)view  delegate:(id)delegate withTitle:(NSString *)title withFrame:(CGRect )frame;
+ (instancetype)showAddToSubView:(UIView *)view delegate:(id)delegate withFrame:(CGRect)frame;
+ (void)cancelForView:(UIView *)view;
@end
