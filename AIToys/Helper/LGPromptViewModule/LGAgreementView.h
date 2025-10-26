//
//  LGAgreementView.h
//  QiDianDriver
//
//  Created by KWOK on 2021/1/22.
//  Copyright © 2021 Henan Qidian Network Technology Co. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, Agreement_Type) {
    Agreement_Type_See,//查看完整版
    Agreement_Type_Next,//同意并继续
    Agreement_Type_Exit//不同意并退出APP
};
@protocol LGAgreementViewDelegate<NSObject>
@optional
- (void)LGAgreementViewBtnClickWithType:(Agreement_Type)type;
@end
@interface LGAgreementView : UIView
@property (nonatomic, weak) id<LGAgreementViewDelegate>  delegate;
/**
 @ 把提示添加到View上
 * @pram view 将要添加到的View
 * @pram text 提示语
 * @pram delegate 代理
 * @pram buttonName 按钮名称
 * @pram image 提示图片
 */
+ (void)showAddedTo:(UIView *)view delegate:(id)delegate;
+ (void)cancelForView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
