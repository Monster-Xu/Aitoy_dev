//
//  ADImageView.m
//  HKHouse591
//
//  Created by Addcn on 16/6/29.
//  Copyright © 2016年 guojian. All rights reserved.
//

#import "ADImageView.h"
#import "Masonry.h"
#import "ATFontManager.h"

//默认倒计时
#define secondCount 3

@interface ADImageView()

@property(nonatomic,weak) UIImageView *adImageView;
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,assign) NSInteger times;
@property(nonatomic,strong) UIButton *pushButton;

@end

@implementation ADImageView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.times = secondCount;
        [self setUI];
        [self timer];
    }
    return self;
}

- (void)setUI{
    self.backgroundColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;
    
    //广告点击手势
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adTapClick:)];
    [self addGestureRecognizer:tapGR];
    
    //跳过按钮
    self.pushButton = [[UIButton alloc] init];
    self.pushButton.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.7];
    self.pushButton.layer.masksToBounds = YES;
    self.pushButton.layer.borderWidth = 1;
    self.pushButton.layer.cornerRadius = 5;
    [self.pushButton setTitle:[NSString stringWithFormat:LocalString(@"跳过(%d)s"), secondCount] forState:UIControlStateNormal];
    self.pushButton.titleLabel.font = [ATFontManager systemFontOfSize:14];
    [self.pushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.pushButton setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [self.pushButton addTarget:self action:@selector(jumpOver) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.pushButton];
    [self.pushButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-10);
        make.top.mas_equalTo(self.mas_top).offset(StatusBar_Height + 5);
        make.width.mas_equalTo(@(80));
        make.height.mas_equalTo(@(30));
    }];
}

- (void)adTapClick:(UITapGestureRecognizer *)tap {
    if ([_timer isValid] == YES) {
        [_timer invalidate];
        _timer = nil;
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.5;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    if (_adPicTapClick) {
        _adPicTapClick();
    }
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeSecond) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (void)jumpOver{
    if ([_timer isValid] == YES) {
        [_timer invalidate];
        _timer = nil;
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.5;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)changeSecond{
    if (_times<=0) {
        [self jumpOver];
    }else{
        _times --;
        [self.pushButton setTitle:[NSString stringWithFormat:LocalString(@"跳过(%d)s"), _times] forState:UIControlStateNormal];
    }
}

@end

