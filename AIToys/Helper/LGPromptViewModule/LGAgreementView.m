//
//  LGAgreementView.m
//  QiDianDriver
//
//  Created by KWOK on 2021/1/22.
//  Copyright © 2021 Henan Qidian Network Technology Co. All rights reserved.
//

#import "LGAgreementView.h"
#import "ATFontManager.h"

@interface LGAgreementView ()
@property (nonatomic, strong) UIView       *bgView;
@property (nonatomic, strong) UILabel      *titleLabel;
@property(nonatomic, retain)  UITextView   *textView;
@property (nonatomic, strong) UIButton     *seeBtn;
@property (nonatomic, strong) UIButton     *nextBtn;
@property (nonatomic, strong) UIButton     *exitBtn;
@end

@implementation LGAgreementView

- (instancetype)initWithView:(UIView *)view {
    return [self initWithFrame:view.bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        _bgView = [[UIView alloc]init];
        _bgView.layer.cornerRadius = 5;
        _bgView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        [self addSubview:self.bgView];
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY).mas_equalTo(-40);
            make.left.equalTo(self.mas_left).offset(30);
            make.right.equalTo(self.mas_right).offset(-30);
            make.height.mas_equalTo(300);
        }];
        [self.bgView addSubview:self.titleLabel];
        [self.bgView addSubview:self.textView];
        [self.bgView addSubview:self.seeBtn];
        [self.bgView addSubview:self.nextBtn];
        [self.bgView addSubview:self.exitBtn];
    }
    return self;
}
+ (void)showAddedTo:(UIView *)view delegate:(id)delegate {
//    [LGAgreementView removeAllPromptForView:view];
    LGAgreementView *tipView = [[LGAgreementView alloc] initWithView:view];
    [[UIApplication sharedApplication].keyWindow addSubview:tipView];
//    [view addSubview:tipView];
    tipView.delegate = delegate;
}
+ (void)cancelForView:(UIView *)view {
//    LGAgreementView *promptView = [self promptForView:view];
//    if (promptView != nil) {
//        [promptView removeFromSuperview];
//    }
}
+ (instancetype)promptForView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:self]) {
            return (LGAgreementView *)subView;
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
- (void)btnAction:(UIButton *)sender {
    [self removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(LGAgreementViewBtnClickWithType:)]) {
        [self.delegate LGAgreementViewBtnClickWithType:sender.tag];
    }
}
#pragma mark get selector
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = UIColorFromRGB(0x000000);
        _titleLabel.font = [ATFontManager systemFontOfSize:18];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgView addSubview:_titleLabel];
        _titleLabel.text = @"用户协议及隐私政策";
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView.mas_top).offset(15);
            make.centerX.equalTo(self.bgView);
        }];
    }
    return _titleLabel;
}
- (UITextView *)textView {
    if (!_textView) {
        _textView = UITextView .new;
        _textView.textColor = UIColorFromRGB(0x333333);
        _textView.backgroundColor = UIColor.clearColor;
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.editable = NO;
        _textView.selectable = NO;
        _textView.font = [ATFontManager systemFontOfSize:14];
        _textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _textView.text = @"为更好的保障您的合法权益，请您\n阅读并同意以下协议";
        [self.bgView addSubview:_textView];
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
            make.centerX.equalTo(self);
            make.width.mas_equalTo(kScreenWidth - 100);
            make.height.mas_equalTo(50);
        }];
    }
    return _textView;
}
- (UIButton *)seeBtn {
    if (!_seeBtn) {
        _seeBtn = [[UIButton alloc]init];
        _seeBtn.tag = Agreement_Type_See;
        [_seeBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_seeBtn setTitle:@"《用户协议》《隐私协议》" forState:UIControlStateNormal];
        [_seeBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
        [self.bgView addSubview:_seeBtn];
        [_seeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textView.mas_bottom).offset(10);
            make.centerX.equalTo(self.bgView);
        }];
    }
    return _seeBtn;
}
- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [[UIButton alloc]init];
        _nextBtn.tag = Agreement_Type_Next;
        _nextBtn.backgroundColor = UIColorFromRGB(0x4A71D5);
        _nextBtn.layer.cornerRadius = 22;
        [_nextBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_nextBtn setTitle:@"同意并继续" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        [_nextBtn.titleLabel setFont:[ATFontManager systemFontOfSize:15]];
        [self.bgView addSubview:_nextBtn];
        [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.seeBtn.mas_bottom).offset(30);
            make.centerX.equalTo(self.bgView);
            make.height.mas_equalTo(44);
            make.left.equalTo(self.bgView.mas_left).offset(30);
            make.right.equalTo(self.bgView.mas_right).offset(-30);
        }];
    }
    return _nextBtn;
}
- (UIButton *)exitBtn {
    if (!_exitBtn) {
        _exitBtn = [[UIButton alloc]init];
        _exitBtn.tag = Agreement_Type_Exit;
        _exitBtn.backgroundColor = [UIColor clearColor];
        [_exitBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_exitBtn setTitle:@"不同意并退出APP" forState:UIControlStateNormal];
        [_exitBtn setTitleColor:UIColorFromRGB(0x606060) forState:UIControlStateNormal];
        [_exitBtn.titleLabel setFont:[ATFontManager systemFontOfSize:15]];
        [self.bgView addSubview:_exitBtn];
        [_exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nextBtn.mas_bottom).offset(20);
            make.centerX.equalTo(self.bgView);
            make.height.mas_equalTo(20);
        }];
    }
    return _exitBtn;
}
@end
