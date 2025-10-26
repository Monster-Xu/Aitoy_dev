//
//  LGImageView.m
//  QiDianDriver
//
//  Created by KWOK on 2020/11/30.
//  Copyright © 2020 Henan Qidian Network Technology Co. All rights reserved.
//

#import "LGImageView.h"
#import "ATFontManager.h"

@interface  LGImageView()
@property (nonatomic, strong) UIView       *bgView;
@property (nonatomic, strong) UIImageView  *imageView;
@property (nonatomic, strong) UIButton     *requestBtn;
@property (nonatomic, strong) NSString     *imgUrl;
@property (nonatomic, strong) UIButton     *deleteBtn;
@property (nonatomic, strong) UIImageView  *carView;
@property (nonatomic, strong) UILabel      *tipLab;
@property (nonatomic, strong) UIButton     *loginBtn;
@property (nonatomic, strong) UIButton     *cancelBtn;
@end

@implementation LGImageView

- (instancetype)initWithView:(UIView *)view {
    return [self initWithFrame:view.bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bgView];
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        if (self.imgUrl.length > 0) {
            [self.bgView addSubview:self.imageView];
            [self.bgView addSubview:self.requestBtn];
        } else {
            self.bgView.backgroundColor = UIColorFromRGB(0xF7F7F7);
            [self.bgView addSubview:self.deleteBtn];
            [self.bgView addSubview:self.carView];
            [self.bgView addSubview:self.tipLab];
            [self.bgView addSubview:self.loginBtn];
            [self.bgView addSubview:self.cancelBtn];
        }
    }
    return self;
}
+ (void)showAddedTo:(UIView *)view withUrl:(NSString *)imgUrl {
    [LGImageView removeAllPromptForView:view];
    LGImageView *tipView = [[LGImageView alloc] initWithView:view];
    tipView.imgUrl = imgUrl;
    [view addSubview:tipView];
}
+ (void)cancelForView:(UIView *)view {
    LGImageView *promptView = [self promptForView:view];
    if (promptView != nil) {
        [promptView removeFromSuperview];
    }
}
+ (instancetype)promptForView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:self]) {
            return (LGImageView *)subView;
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
    [self removeFromSuperview];
}

#pragma mark get selector
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
//        [_imageView sd_setImageWithURL:[NSURL URLWithString:_CustomerInfo.qrUrl]];
        [self.bgView addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bgView);
            make.centerY.equalTo(self.mas_centerY).offset(- 50);
            make.size.mas_equalTo(CGSizeMake(300, 300));
        }];
//        _imageView.image = [UIImage imageNamed:@"errorqrcode"];
    }
    return _imageView;
}
- (UIButton *)requestBtn {
    if (!_requestBtn) {
        _requestBtn = [[UIButton alloc] init];
        [_requestBtn addTarget:self action:@selector(request) forControlEvents:UIControlEventTouchUpInside];
        [_requestBtn setImage:QD_IMG(@"qr_close") forState:UIControlStateNormal];
        [self.bgView addSubview:_requestBtn];
        [_requestBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(20);
            make.centerX.equalTo(self.bgView);
        }];
    }
    return _requestBtn;
}
- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc]init];
        [_deleteBtn addTarget:self action:@selector(deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_deleteBtn setImage:QD_IMG(@"scan_close") forState:UIControlStateNormal];
        [self.bgView addSubview:_deleteBtn];
        [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bgView.mas_left).offset(15);
            make.top.equalTo(self.bgView.mas_top).offset(20);
            make.size.mas_equalTo(CGSizeMake(30, 50));
        }];
    }
    return _deleteBtn;
}
- (UIImageView *)carView {
    if (!_carView) {
        _carView = [[UIImageView alloc]init];
        _carView.image = QD_IMG(@"chezai");
        [self.bgView addSubview:_carView];
        [_carView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView.mas_top).offset(160);
            make.centerX.equalTo(self.bgView);
            make.size.mas_equalTo(CGSizeMake(145, 131));
        }];
    }
    return _carView;
}
- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.textColor = UIColorFromRGB(0x333333);
        _tipLab.font = [ATFontManager boldSystemFontOfSize:20];
        _tipLab.textAlignment = NSTextAlignmentCenter;
        _tipLab.numberOfLines = 1;
        _tipLab.text = @"车载版登录确认";
        [self addSubview:_tipLab];
        [_tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.carView.mas_bottom).offset(15);
            make.centerX.equalTo(self.bgView);
        }];
    }
    return _tipLab;
}
- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [[UIButton alloc] init];
        [_loginBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[ATFontManager systemFontOfSize:18]];
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        _loginBtn.backgroundColor = UIColor.blueColor;
        _loginBtn.layer.cornerRadius = 7.5;
        [_loginBtn addTarget:self action:@selector(loginBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:_loginBtn];
        [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tipLab.mas_bottom).offset(100);
            make.size.mas_equalTo(CGSizeMake(225, 40));
            make.centerX.equalTo(self.bgView);
        }];
    }
    return _loginBtn;
}
- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        [_cancelBtn addTarget:self action:@selector(deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        [_cancelBtn.titleLabel setFont:[ATFontManager systemFontOfSize:18]];
        [_cancelBtn setTitle:@"取消登录" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(request) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:_cancelBtn];
        [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loginBtn.mas_bottom).offset(20);
            make.size.mas_equalTo(CGSizeMake(225, 40));
            make.centerX.equalTo(self.bgView);
        }];
    }
    return _cancelBtn;
}
   
- (void)loginBtnAction {
    if (self.loginBlock) {
        self.loginBlock(YES);
    }
}
- (void)deleteBtnAction {
    if (self.loginBlock) {
        self.loginBlock(NO);
    }
    [self removeFromSuperview];
}
@end
