//
//  LGImageView.h
//  QiDianDriver
//
//  Created by KWOK on 2020/11/30.
//  Copyright © 2020 Henan Qidian Network Technology Co. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGImageView : UIView
+ (void)showAddedTo:(UIView *)view withUrl:(NSString *)imgUrl;
@property (nonatomic, copy) void(^loginBlock)(BOOL isLogin);
@end

NS_ASSUME_NONNULL_END
