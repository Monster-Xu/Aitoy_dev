//
//  LGAuditView.h
//  QiDianDriver
//
//  Created by KWOK on 2021/8/13.
//  Copyright © 2021 Henan Qidian Network Technology Co. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AuditType) {
    AuditTypeOngoing,//审核中
};

@interface LGAuditView : UIView
+ (void)showAuditViewWithViwe:(UIView *)view WithType:(AuditType )type;
@end

NS_ASSUME_NONNULL_END
