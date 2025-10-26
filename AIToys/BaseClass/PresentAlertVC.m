//
//  PresentAlertVC.m
//  XingChiLive
//
//  Created by 张海阔 on 2019/11/27.
//  Copyright © 2019 Yunhai. All rights reserved.
//

#import "PresentAlertVC.h"

@interface PresentAlertVC ()
@property (nonatomic, assign) BOOL isShowAlert;
@end

@implementation PresentAlertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.definesPresentationContext = YES;
    _isShowAlert = YES;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [_bgView addGestureRecognizer:tap];
    [self.view addSubview:_bgView];
    
    self.alertView = [[UIView alloc] init];
    [self.view addSubview:self.alertView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_isShowAlert) {
        _isShowAlert = NO;
        [self showView];
    }
}

#pragma mark -- 动画

//出现的动画
- (void)showView {
    
}

//消失的动画
- (void)dismiss:(NSInteger)handle {
    
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    
}

@end
