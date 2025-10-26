//
//  LGTipView.m
//  QiDianProhibit
//
//  Created by KWOK on 2019/12/30.
//  Copyright © 2019 Henan Qidian Network Technology Co. All rights reserved.
//

#import "LGTipView.h"
#import "ATFontManager.h"

@interface LGTipView ()
@property (nonatomic, strong) UIView       *bgView;
@property (nonatomic, strong) UIImageView  *imageView;
@property (nonatomic, strong) UILabel      *titleLabel;
@property (nonatomic, strong) UILabel      *descripLabel;
@property (nonatomic, strong) UIButton     *requestBtn;
@property (nonatomic, strong) UIButton     *closeBtn;
@property (nonatomic, assign) Tip_Type     type;
@end
@implementation LGTipView

- (instancetype)initWithView:(UIView *)view {
    return [self initWithFrame:view.bounds withType:Tip_Type_Default];
}
- (instancetype)initWithView:(UIView *)view withType:(Tip_Type)type{
    return [self initWithFrame:view.bounds withType:type];
}
- (instancetype)initWithFrame:(CGRect)frame withType:(Tip_Type)type{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _bgView = [[UIView alloc]init];
        _bgView.layer.cornerRadius = 5;
        _bgView.backgroundColor = UIColorFromRGB(0x1C2027);
        [self addSubview:self.bgView];
        if (type == Tip_Type_Default) {
            [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.left.equalTo(self.mas_left).offset(15);
                make.right.equalTo(self.mas_right).offset(-15);
                make.height.mas_equalTo(290);
            }];
            [self.bgView addSubview:self.imageView];
            [self.bgView addSubview:self.titleLabel];
            [self.bgView addSubview:self.descripLabel];
            [self.bgView addSubview:self.requestBtn];
        } else if (type == Tip_Type_Auth) {
            _bgView.backgroundColor = UIColor.whiteColor;
            [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.left.equalTo(self.mas_left).offset(15);
                make.right.equalTo(self.mas_right).offset(-15);
                make.height.mas_equalTo(200);
            }];
            [self.bgView addSubview:self.closeBtn];
            [self.bgView addSubview:self.titleLabel];
            [self.bgView addSubview:self.descripLabel];
            [self.bgView addSubview:self.requestBtn];
            self.titleLabel.text = @"提示";
            self.titleLabel.textColor = UIColor.blackColor;
            self.descripLabel.text = @"您还未实名认证，请先进行实名认证\n完成实名认证后需重新登录";
            [self.requestBtn setTitle:@"实名认证" forState:UIControlStateNormal];
        }
    }
    return self;
}
+ (void)showAddedTo:(UIView *)view delegate:(id)delegate{
    [LGTipView removeAllPromptForView:view];
    LGTipView *tipView = [[LGTipView alloc] initWithView:view];
    [view addSubview:tipView];
    tipView.delegate = delegate;
}

+ (void)showAuthAddedTo:(UIView *)view delegate:(id)delegate {
    [LGTipView removeAllPromptForView:view];
    LGTipView *tipView = [[LGTipView alloc] initWithView:view withType:Tip_Type_Auth];
    [view addSubview:tipView];
    tipView.delegate = delegate;
}
+ (void)cancelForView:(UIView *)view {
    LGTipView *promptView = [self promptForView:view];
    if (promptView != nil) {
        [promptView removeFromSuperview];
    }
}
- (void)closeBtnAction {
    [self removeFromSuperview];
}
+ (instancetype)promptForView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:self]) {
            return (LGTipView *)subView;
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
#pragma mark btn selector
- (void)request {
    if (self.delegate  && [self.delegate respondsToSelector:@selector(LGTipViewSureBtnClick)]) {
        [self.delegate LGTipViewSureBtnClick];
    }
}

#pragma mark get selector
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.bgView addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView.mas_top).offset(30);
            make.centerX.equalTo(self.bgView);
        }];
        _imageView.image = [UIImage imageNamed:@"errorqrcode"];
    }
    return _imageView;
}
- (UIButton *)requestBtn {
    if (!_requestBtn) {
        _requestBtn = [[UIButton alloc] init];
        [_requestBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_requestBtn addTarget:self action:@selector(request) forControlEvents:UIControlEventTouchUpInside];
        _requestBtn.titleLabel.font = [ATFontManager systemFontOfSize:15];
        _requestBtn.backgroundColor = UIColor.whiteColor;
        _requestBtn.layer.cornerRadius = 5;
        [self.bgView addSubview:_requestBtn];
        [_requestBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.bgView.mas_bottom).offset(-25);
            make.left.equalTo(self.bgView.mas_left).offset(20);
            make.right.equalTo(self.bgView.mas_right).offset(-20);
            make.height.mas_equalTo(40);
        }];
    }
    return _requestBtn;
}
- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setImage:QD_IMG(@"close_icon") forState:UIControlStateNormal];
        [_closeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:_closeBtn];
        [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView.mas_top).offset(10);
            make.right.equalTo(self.bgView.mas_right).offset(-10);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    }
    return _requestBtn;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.font = [ATFontManager boldSystemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        [self.bgView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(15);
            make.centerX.equalTo(self.bgView);
        }];
    }
    return _titleLabel;
}
- (UILabel *)descripLabel {
    if (!_descripLabel) {
        _descripLabel = [[UILabel alloc] init];
        _descripLabel.textColor = UIColorFromRGB(0x888888);
        _descripLabel.font = [ATFontManager systemFontOfSize:16];
        _descripLabel.textAlignment = NSTextAlignmentCenter;
        _descripLabel.numberOfLines = 0;
        [self.bgView addSubview:_descripLabel];
        
        [_descripLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
            make.left.equalTo(self.bgView.mas_left).offset(15);
            make.right.equalTo(self.bgView.mas_right).offset(-15);
        }];
    }
    return _descripLabel;
}
@end
