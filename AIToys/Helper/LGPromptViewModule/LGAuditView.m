//
//  LGAuditView.m
//  QiDianDriver
//
//  Created by KWOK on 2021/8/13.
//  Copyright © 2021 Henan Qidian Network Technology Co. All rights reserved.
//

#import "LGAuditView.h"
#import "ATFontManager.h"

@interface LGAuditView()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *tipLab;
@property (nonatomic, assign) AuditType   type;
@end

@implementation LGAuditView

- (instancetype)initWithView:(UIView *)view {
    return [self initWithFrame:view.bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        [self addSubview:self.iconView];
        [self addSubview:self.tipLab];
        if (self.type == AuditTypeOngoing) {
            self.tipLab.text = @"资料正在审核中";
        }
    }
    return self;
}
+ (void)showAuditViewWithViwe:(UIView *)view WithType:(AuditType)type {
    [LGAuditView removeAllPromptForView:view];
    LGAuditView *auditView = [[LGAuditView alloc] initWithView:view];
    auditView.type = type;
    [view addSubview:auditView];
}
+ (void)cancelForView:(UIView *)view {
    LGAuditView *promptView = [self promptForView:view];
    if (promptView != nil) {
        [promptView removeFromSuperview];
    }
}
+ (instancetype)promptForView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:self]) {
            return (LGAuditView *)subView;
        }
    }
    return nil;
}
+ (void)removeAllPromptForView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:self]) {
            [subView removeFromSuperview];
        }
    }
}
- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc]init];
        _iconView.image = QD_IMG(@"auditing");
        [self addSubview:_iconView];
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(160);
            make.centerX.equalTo(self);
        }];
    }
    return _iconView;
}
- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.textColor = UIColorFromRGB(0x0079FE);
        _tipLab.font = [ATFontManager systemFontOfSize:18];
        _tipLab.textAlignment = NSTextAlignmentCenter;
        _tipLab.numberOfLines = 0;
        [self addSubview:_tipLab];
        [_tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconView.mas_bottom).offset(20);
            make.centerX.equalTo(self);
        }];
    }
    return _tipLab;
}
@end
