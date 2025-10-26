//
//  LGBaseAlertView.m
//  QiDianProhibit
//
//  Created by KWOK on 2019/4/24.
//  Copyright © 2019 Henan Qidian Network Technology Co. All rights reserved.
//

#import "LGBaseAlertView.h"
#import "LGTextView.h"
#import <MBProgressHUD+JDragon.h>
#import "ATFontManager.h"

@interface LGBaseAlertView ()<UITextViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray        *dataArr;
@property (nonatomic, strong) UIControl* bgControl;
@property (nonatomic, assign) float keyBoardHight;
@property (assign, nonatomic) CGRect originalFrame;
@end

@implementation LGBaseAlertView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // 首先检查是否在bgView内
    if (self.bgView) {  // 添加nil检查
        CGPoint bgViewPoint = [self convertPoint:point toView:self.bgView];
        if ([self.bgView pointInside:bgViewPoint withEvent:event]) {
            // 在bgView内，让bgView处理
            UIView *hitView = [self.bgView hitTest:bgViewPoint withEvent:event];
            if (hitView) {
                return hitView;
            }
        }
    }
    // 不在bgView内，处理背景点击
    return self;
}

- (instancetype)initWithType:(ALERT_VIEW_TYPE )type block:(void (^)(BOOL, id))block
{
    if(self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)]){
        _type = type;
        _block = block;
        _lastHeight = 0;
        _originalFrame = self.frame;
        [self setBackgroundColor:UIColorFromRGBA(0x000000, 0.4)];

        // 添加背景点击手势
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        tapGesture.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

#pragma mark - 键盘弹出事件
- (void)keyboardWasShow:(NSNotification*)notification{
    if (!notification.userInfo) return;  // 添加安全检查
    
    CGRect keyBoardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyBoardHight = keyBoardFrame.size.height;
    [self translationWhenKeyboardDidShow:_keyBoardHight];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification{
    [self translationWhenKeyBoardDidHidden];
}

- (void)translationWhenKeyboardDidShow:(CGFloat)keyBoardHight{
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, kScreenHeight-(keyBoardHight+self.frame.size.height - 100), self.frame.size.width, self.frame.size.height);
    }];
}

- (void)translationWhenKeyBoardDidHidden{
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = _originalFrame;
    }];
}

//默认弹窗
+ (LGBaseAlertView* )showAlertWithTitle:(NSString *)titleStr content:(NSString *)contentStr cancelBtnStr:(NSString *)cancelStr confirmBtnStr:(NSString *)confirmStr confirmBlock:(void (^)(BOOL is_value, id obj))block
{
    NSMutableDictionary* info = @{}.mutableCopy;
    if(titleStr){
        [info setValue:titleStr forKey:@"title"];
    }
    if(contentStr){
        [info setValue:contentStr forKey:@"content"];
    }
    if(cancelStr){
        [info setValue:cancelStr forKey:@"cancelStr"];
    }
    if(confirmStr){
        [info setValue:confirmStr forKey:@"confirmStr"];
    }
    return [self showAlertInfo:info withType:ALERT_VIEW_TYPE_NORMAL confirmBlock:block];
}

+ (LGBaseAlertView *)showAlertwWithContent:(NSString *)contentStr WithHandle:(void (^)(BOOL isValue, id obj))block{
    NSMutableDictionary* info = @{}.mutableCopy;
    [info setValue:LocalString(@"温馨提示") forKey:@"title"];
    [info setValue:contentStr forKey:@"content"];
    [info setValue:LocalString(@"取消") forKey:@"cancelStr"];
    [info setValue:LocalString(@"确定") forKey:@"confirmStr"];
    return [self showAlertInfo:info withType:ALERT_VIEW_TYPE_NORMAL confirmBlock:block];
}

+ (LGBaseAlertView* )showAlertWithContent:(NSString *)contentStr  confirmBlock:(void (^)(BOOL is_value, id obj))block {
    NSMutableDictionary* info = @{}.mutableCopy;
    [info setValue:LocalString(@"温馨提示") forKey:@"title"];
    [info setValue:contentStr forKey:@"content"];
    [info setValue:LocalString(@"确定") forKey:@"confirmStr"];
    return [self showAlertInfo:info withType:ALERT_VIEW_TYPE_NORMAL_VERTION confirmBlock:block];
}

+ (LGBaseAlertView *)showDepositAlertwWithContent:(NSString *)contentStr WithHandle:(void (^)(BOOL isValue, id obj))block {
    // 实现缺失的方法
    return [self showAlertwWithContent:contentStr WithHandle:block];
}

//自定义弹出
+ (LGBaseAlertView * )showAlertInfo:(id)info withType:(ALERT_VIEW_TYPE )type confirmBlock:(void (^)(BOOL is_value, id obj))block
{
    LGBaseAlertView* alert = [[self alloc] initWithType:type block:block];
    alert.info = info;
    [alert layoutAlert];
    [alert show];  // 移到layoutAlert之后，确保布局完成

    // 确保布局正确计算
    [alert ensureCorrectLayout];

    return alert;
}

- (void)ensureCorrectLayout {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsLayout];
        [self layoutIfNeeded];

        // 延迟确保所有约束都已生效
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setNeedsLayout];
            [self layoutIfNeeded];

            // 如果自动布局失败，手动设置高度
            if (CGRectGetHeight(self.bgView.frame) == 0) {
                [self applyManualLayout];
            }
        });
    });
}

- (void)applyManualLayout {
    CGFloat height = 20 + 56 + 20; // 默认高度：上边距 + 按钮高度 + 下边距

    if (self.info[@"title"]) {
        height += 40; // 标题高度和间距
    }
    if (self.info[@"content"]) {
        height += 40; // 内容高度和间距
    }

    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [self layoutIfNeeded];
}

/**
 背景点击回调
 */
- (void)backgroundTapped:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    
    if (!self.bgView) return;  // 添加安全检查
    
    CGPoint bgViewPoint = [self convertPoint:point toView:self.bgView];

    // 如果点击在bgView外面，才处理背景点击
    if (![self.bgView pointInside:bgViewPoint withEvent:nil]) {
        [self bgControlResponse];
    }
}

- (void)bgControlResponse
{
    if(_isAllowDismiss){
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:.25 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [weakSelf removeFromSuperview];
            if(weakSelf.block) {
                weakSelf.block(NO, @(0));
            }
        }];
    }
}

- (void)btnSelect:(UIButton* )btn
{
    if (self.type == ALERT_VIEW_TYPE_NORMAL_CANCEL && btn.tag == 1) {
        if (self.textView.text.length == 0) {  // 修复：使用text而不是tx
            [MBProgressHUD showErrorMessage:@"取消原因不能为空"];
            return;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
        
        if (!weakSelf.block) return;  // 添加block存在性检查
        
        // 修复：逻辑运算符错误，应该用||而不是|
        if (weakSelf.type == ALERT_VIEW_TYPE_NORMAL_REJECT ||
            weakSelf.type == ALERT_VIEW_TYPE_NORMAL_CANCEL ||
            weakSelf.type == ALERT_VIEW_TYPE_EditText) {
            weakSelf.block(btn.tag, weakSelf.textView.text);
        } else if (weakSelf.type == ALERT_VIEW_TYPE_EditName) {
            weakSelf.block(btn.tag, weakSelf.textField.text);
        } else {
            weakSelf.block(btn.tag, nil);
        }
    }];
}

/**
 弹出方法
 */
- (void)show
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        // 如果keyWindow不可用，尝试获取其他window
        window = [UIApplication sharedApplication].windows.firstObject;
    }
    
    if (!window) return;  // 安全检查
    
    [window addSubview:self];
    self.alpha = 1.0;
    self.userInteractionEnabled = YES;

    // 确保bgView已创建
    if (self.bgView) {
        self.bgView.userInteractionEnabled = YES;
        self.bgView.transform = CGAffineTransformMakeScale(.8, .8);
        
        [UIView animateWithDuration:.25 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.bgView.transform = CGAffineTransformIdentity;
            self.alpha = 1.0;
        } completion:nil];
    }
}

#pragma mark - 获取根视图视图控制器
- (UINavigationController *)getRootVCformViewController
{
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController *nav = nil;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabbar = (UITabBarController *)rootVC;
        NSInteger index = tabbar.selectedIndex;
        if (index < tabbar.childViewControllers.count) {  // 添加数组越界检查
            nav = tabbar.childViewControllers[index];
        }
    }else if ([rootVC isKindOfClass:[UINavigationController class]]) {
        nav = (UINavigationController *)rootVC;
    }else if ([rootVC isKindOfClass:[UIViewController class]]) {
        NSLog(@"This no UINavigationController...");
    }
    return nav;
}

#pragma mark - Layout
/**
 layout
 */
- (void)layoutAlert
{
    switch (_type) {
        case ALERT_VIEW_TYPE_NORMAL_VERTION:{
            if(_info[@"title"]){
                self.titleLabel.text = _info[@"title"];
                [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_offset(20);
                    make.centerX.mas_equalTo(self.bgView);
                    make.width.mas_lessThanOrEqualTo(self.bgView.mas_width).mas_offset(-80);
                }];
                _lastObj = _titleLabel;
            }
            if(_info[@"content"]){
                UIView *lastView = (UIView *)_lastObj;
                self.contentLabel.text = _info[@"content"];
                [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(lastView ? lastView.mas_bottom : self.bgView.mas_top).offset(20);
                    make.centerX.mas_equalTo(self.bgView);
                    make.width.mas_lessThanOrEqualTo(self.bgView.mas_width).mas_offset(-80);
                }];
                _lastObj = _contentLabel;
            }
            [self.bgView addSubview:self.lineView];
            UIView *lastView = (UIView *)_lastObj;
            [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastView ? lastView.mas_bottom : self.bgView.mas_top).offset(20);
                make.left.equalTo(self.bgView);
                make.right.equalTo(self.bgView);
                make.height.mas_equalTo(.5);
            }];
            _lastObj = _lineView;
            if(_info[@"confirmStr"]){
                [self.confirmBtn setTitle:_info[@"confirmStr"] forState:UIControlStateNormal];
                [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.lineView.mas_bottom);
                    make.centerX.mas_equalTo(self.bgView);
                    make.size.mas_equalTo(CGSizeMake(200, 56));
                }];
                [self.bgLayer setFillColor:UIColorFromRGB(0xF4F5F9).CGColor];
                [self.bgLayer setShadowColor:UIColorFromRGB(0xF4F5F9).CGColor];
                _lastObj = _confirmBtn;
                _lastHeight = 0;
            }
        }
            break;
        case ALERT_VIEW_TYPE_NORMAL:{
            if(_info[@"title"]){
                self.titleLabel.text = _info[@"title"];
                [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_offset(20);
                    make.centerX.mas_equalTo(self.bgView);
                    make.width.mas_lessThanOrEqualTo(self.bgView.mas_width).mas_offset(-20);
                }];
                _lastObj = _titleLabel;
            }
            if(_info[@"content"]){
                UIView *lastView = (UIView *)_lastObj;
                self.contentLabel.text = _info[@"content"];
                [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(lastView ? lastView.mas_bottom : self.bgView.mas_top).offset(20);
                    make.centerX.mas_equalTo(self.bgView);
                    make.width.mas_lessThanOrEqualTo(self.bgView.mas_width).mas_offset(-20);
                }];
                _lastObj = _contentLabel;
            }
            [self.bgView addSubview:self.lineView];
            UIView *lastView = (UIView *)_lastObj;
            [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastView ? lastView.mas_bottom : self.bgView.mas_top).offset(20);
                make.left.equalTo(self.bgView);
                make.right.equalTo(self.bgView);
                make.height.mas_equalTo(.5);
            }];
            _lastObj = _lineView;
            if(_info[@"cancelStr"] && _info[@"confirmStr"]){
                [self.bgView addSubview:self.midlleView];
                [self.midlleView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.lineView.mas_bottom);
                    make.centerX.equalTo(self.bgView);
                    make.size.mas_equalTo(CGSizeMake(.5, 56));
                }];
                _lastObj = _midlleView;
            }
            if(_info[@"cancelStr"]){
                [self.cancelBtn setTitle:_info[@"cancelStr"] forState:UIControlStateNormal];
                [self.cancelBtn setTitleColor:UIColorFromRGBA(0x000000, 0.5) forState:UIControlStateNormal];
                [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.lineView.mas_bottom);
                    make.left.mas_offset(0);
                    make.right.equalTo(self.midlleView.mas_left);
                    make.height.mas_equalTo(56);
                }];
            }
            if(_info[@"confirmStr"]){
                [self.confirmBtn setTitle:_info[@"confirmStr"] forState:UIControlStateNormal];
                if(_cancelBtn){
                    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(self.lineView.mas_bottom);
                        make.right.mas_offset(0);
                        make.left.equalTo(self.midlleView.mas_right);
                        make.height.mas_equalTo(56);
                    }];
                }else{
                    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(self.lineView.mas_bottom);
                        make.centerX.mas_equalTo(self.bgView);
                        make.size.mas_equalTo(CGSizeMake(180, 56));
                    }];
                }
                [self.bgLayer setFillColor:UIColorFromRGB(0xF4F5F9).CGColor];
                [self.bgLayer setShadowColor:UIColorFromRGB(0xF4F5F9).CGColor];
                _lastObj = _confirmBtn;
                _lastHeight = 0;
            }
        }
            break;
        case ALERT_VIEW_TYPE_NORMAL_REJECT:
        case ALERT_VIEW_TYPE_NORMAL_CANCEL: {  // 合并相似逻辑
            [self.bgView addSubview:self.textView];
            [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_offset(20);
                make.centerX.mas_equalTo(self.bgView);
                make.width.mas_equalTo(251);
                make.height.mas_equalTo(60);
            }];
            [self.bgView addSubview:self.lineView];
            [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_textView.mas_bottom);
                make.left.right.equalTo(self.bgView);
                make.height.mas_equalTo(0.5);
            }];
            [self.bgView addSubview:self.midlleView];
            [_midlleView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_lineView.mas_bottom);
                make.bottom.equalTo(self.bgView.mas_bottom);
                make.width.mas_equalTo(1);
                make.centerX.equalTo(self.bgView);
            }];
            [self.cancelBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
            [self.cancelBtn setTitleColor:UIColorFromRGBA(0x000000, 0.5) forState:UIControlStateNormal];
            [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_lineView.mas_bottom);
                make.left.equalTo(self.bgView);
                make.right.equalTo(self.midlleView);
                make.bottom.equalTo(self.bgView);
            }];
            [self.confirmBtn setTitle:LocalString(@"确定")forState:UIControlStateNormal];
            [self.confirmBtn setTitleColor:mainColor forState:UIControlStateNormal];
            [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_lineView.mas_bottom);
                make.left.equalTo(self.midlleView.mas_right);
                make.right.equalTo(self.bgView);
                make.bottom.equalTo(self.bgView);
            }];
            [self.bgLayer setFillColor:UIColorFromRGB(0xF4F5F9).CGColor];
            [self.bgLayer setShadowColor:UIColorFromRGB(0xF4F5F9).CGColor];
            _lastObj = _confirmBtn;
            _lastHeight = 10;
        }
            break;
        case ALERT_VIEW_TYPE_EditName: {
            if(_info[@"title"]){
                self.titleLabel.text = _info[@"title"];
                [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_offset(20);
                    make.centerX.mas_equalTo(self.bgView);
                    make.width.mas_lessThanOrEqualTo(self.bgView.mas_width).mas_offset(-20);
                    make.height.mas_equalTo(20);
                }];
            }
            self.textField.placeholder = _info[@"placeholder"] ? : @"请输入名称";
            self.textField.text = _info[@"value"];
            
            // 添加安全检查
            if (_info[@"bordType"]) {
                self.textField.keyboardType = [_info[@"bordType"] integerValue];
            }
            
            [self.bgView addSubview:self.textField];
            [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
                make.left.equalTo(self.bgView).offset(15);
                make.right.equalTo(self.bgView).offset(-15);
                make.height.mas_equalTo(40);
            }];
            [self.textField becomeFirstResponder];
            [self.bgView addSubview:self.lineView];
            [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_textField.mas_bottom).offset(15);
                make.left.right.equalTo(self.bgView);
                make.height.mas_equalTo(0.5);
            }];
            [self.bgView addSubview:self.midlleView];
            [_midlleView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_lineView.mas_bottom);
                make.bottom.equalTo(self.bgView.mas_bottom);
                make.width.mas_equalTo(1);
                make.centerX.equalTo(self.bgView);
            }];
            [self.cancelBtn setTitle:LocalString(@"取消")forState:UIControlStateNormal];
            [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_lineView.mas_bottom);
                make.left.equalTo(self.bgView);
                make.right.equalTo(self.midlleView);
                make.bottom.equalTo(self.bgView);
            }];
            [self.confirmBtn setTitle:LocalString(@"确定") forState:UIControlStateNormal];
            [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_lineView.mas_bottom);
                make.left.equalTo(self.midlleView.mas_right);
                make.right.equalTo(self.bgView);
                make.bottom.equalTo(self.bgView);
            }];
            [self.bgLayer setFillColor:UIColorFromRGB(0xF4F5F9).CGColor];
            [self.bgLayer setShadowColor:UIColorFromRGB(0xF4F5F9).CGColor];
            _lastObj = _confirmBtn;
            _lastHeight = 10;
        }
            break;
        case ALERT_VIEW_TYPE_EditText: {
            if(_info[@"title"]){
                self.titleLabel.text = _info[@"title"];
                [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_offset(20);
                    make.centerX.mas_equalTo(self.bgView);
                    make.width.mas_lessThanOrEqualTo(self.bgView.mas_width).mas_offset(-20);
                    make.height.mas_equalTo(20);
                }];
            }
            self.textView.placeholder = @"请输入";
            self.textView.text = _info[@"value"];
            
            // 添加安全检查
            if (_info[@"bordType"]) {
                self.textView.keyboardType = [_info[@"bordType"] integerValue];
            }
            
            [self.bgView addSubview:self.textView];
            [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
                make.left.equalTo(self.bgView).offset(15);
                make.right.equalTo(self.bgView).offset(-15);
                make.height.mas_equalTo(40);
            }];
            [self.bgView addSubview:self.lineView];
            [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_textView.mas_bottom).offset(15);
                make.left.right.equalTo(self.bgView);
                make.height.mas_equalTo(0.5);
            }];
            [self.bgView addSubview:self.midlleView];
            [_midlleView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_lineView.mas_bottom);
                make.bottom.equalTo(self.bgView.mas_bottom);
                make.width.mas_equalTo(1);
                make.centerX.equalTo(self.bgView);
            }];
            [self.cancelBtn setTitle:_info[@"cancelStr"] ? _info[@"cancelStr"] :LocalString(@"取消") forState:UIControlStateNormal];
            [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_lineView.mas_bottom);
                make.left.equalTo(self.bgView);
                make.right.equalTo(self.midlleView);
                make.bottom.equalTo(self.bgView);
            }];
            [self.confirmBtn setTitle:_info[@"confirmStr"] ? _info[@"confirmStr"] :LocalString(@"确定") forState:UIControlStateNormal];
            [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_lineView.mas_bottom);
                make.left.equalTo(self.midlleView.mas_right);
                make.right.equalTo(self.bgView);
                make.bottom.equalTo(self.bgView);
            }];
            [self.bgLayer setFillColor:UIColorFromRGB(0xF4F5F9).CGColor];
            [self.bgLayer setShadowColor:UIColorFromRGB(0xF4F5F9).CGColor];
            _lastObj = _confirmBtn;
            _lastHeight = 10;
        }
            break;
        default:
            break;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutIfNeeded];

    if (_lastObj) {  // 添加安全检查
        CGFloat f_y = CGRectGetMaxY([(UIView* )_lastObj frame]) + _lastHeight;
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(f_y);
        }];
    }

    UIBezierPath* bezier = [UIBezierPath bezierPathWithRoundedRect:self.bgView.frame byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(16.0, 16.0)];
    self.bgLayer.path = bezier.CGPath;
}

#pragma mark - Getter

- (UILabel *)titleLabel
{
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = UIColorFromRGBA(000000,0.9);
        _titleLabel.font = [ATFontManager boldSystemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        [self.bgView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)subLabel
{
    if(!_subLabel){
        _subLabel = [[UILabel alloc] init];
        _subLabel.textColor = UIColorFromRGB(0x323232);
        _subLabel.font = [ATFontManager systemFontOfSize:16];
        _subLabel.textAlignment = NSTextAlignmentCenter;
        _subLabel.numberOfLines = 0;
        [self.bgView addSubview:_subLabel];
    }
    return _subLabel;
}

- (UILabel *)contentLabel
{
    if(!_contentLabel){
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = UIColorFromRGBA(000000,0.5);
        _contentLabel.font = [ATFontManager systemFontOfSize:14];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.numberOfLines = 0;
        [self.bgView addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (UILabel *)detaileLab {
    if (!_detaileLab) {
        _detaileLab = [[UILabel alloc] init];
        _detaileLab.textColor = UIColorFromRGB(0x8E8E8E);
        _detaileLab.font = [ATFontManager systemFontOfSize:14];
        _detaileLab.textAlignment = NSTextAlignmentCenter;
        _detaileLab.numberOfLines = 0;
        [self.bgView addSubview:_detaileLab];
    }
    return _detaileLab;
}

- (UIButton *)cancelBtn
{
    if(!_cancelBtn){
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bgView addSubview:_cancelBtn];
        [_cancelBtn.titleLabel setFont:[ATFontManager systemFontOfSize:16]];
        [_cancelBtn setTitleColor:UIColorFromRGBA(000000, 0.5) forState:UIControlStateNormal];
        _cancelBtn.tag = 0;
        _cancelBtn.userInteractionEnabled = YES;
        [_cancelBtn addTarget:self action:@selector(btnSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)confirmBtn
{
    if(!_confirmBtn){
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bgView addSubview:_confirmBtn];
        [_confirmBtn.titleLabel setFont:[ATFontManager boldSystemFontOfSize:16]];
        [_confirmBtn setTitleColor:UIColorFromRGBA(000000, 0.9) forState:UIControlStateNormal];
        _confirmBtn.tag = 1;
        _confirmBtn.userInteractionEnabled = YES;
        [_confirmBtn addTarget:self action:@selector(btnSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

- (UIView *)lineView
{
    if(!_lineView){
        _lineView = [UIView new];
        _lineView.backgroundColor = UIColorFromRGBA(000000, 0.1);
        [self.bgView addSubview:_lineView];
    }
    return _lineView;
}

- (UIView *)midlleView
{
    if(!_midlleView){
        _midlleView = [UIView new];
        _midlleView.backgroundColor = UIColorFromRGBA(000000, 0.1);
        [self.bgView addSubview:_midlleView];
    }
    return _midlleView;
}

- (UIView *)bgView
{
    if(!_bgView){
        _bgView = [UIView new];
        [self addSubview:_bgView];
        [_bgView setBackgroundColor:[UIColor whiteColor]];
        _bgView.layer.cornerRadius = 16;
        _bgView.layer.masksToBounds = YES;  // 添加裁剪，确保圆角生效
        _bgView.userInteractionEnabled = YES;
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY).offset(-50);
            make.centerX.equalTo(self);
            make.width.mas_equalTo(kScreenWidth-80);
            make.height.mas_equalTo(150);
        }];
    }
    return _bgView;
}

- (CAShapeLayer *)bgLayer
{
    if(!_bgLayer){
        _bgLayer = [CAShapeLayer layer];
        [self.bgControl.layer addSublayer:_bgLayer];
        _bgLayer.zPosition = -1;
        [_bgLayer setFillColor:UIColorFromRGB((0xffffff)).CGColor];
        [_bgLayer setShadowColor:UIColorFromRGB(0xffffff).CGColor];
        [_bgLayer setShadowOpacity:.3];
        [_bgLayer setShadowRadius:2.0];
        [_bgLayer setShadowOffset:CGSizeMake(0, 2)];
    }
    return _bgLayer;
}

- (UIControl *)bgControl
{
    if(!_bgControl){
        _bgControl = [UIControl new];
        _bgControl.backgroundColor = [UIColor clearColor];
        [_bgControl addTarget:self action:@selector(bgControlResponse) forControlEvents:UIControlEventTouchUpInside];
        _bgControl.alpha = 1.0;
        _bgControl.userInteractionEnabled = YES;
    }
    return _bgControl;
}

- (LGTextView *)textView {
    if(!_textView){
        _textView = [[LGTextView alloc]init];
        _textView.delegate = self;
        _textView.backgroundColor = UIColor.whiteColor;
        _textView.tag = 1999;
        _textView.placeholder = @"请输入原因....";
        [_textView setFont:[ATFontManager systemFontOfSize:16]];
        [_textView setTextColor:UIColorFromRGBA(000000, 0.9)];
        [_textView setTintColor:mainColor];
    }
    return _textView;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSInteger existedLength = textView.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = text.length;
    NSInteger length = existedLength - selectedLength + replaceLength;
    if (self.type == ALERT_VIEW_TYPE_NORMAL_CANCEL) {
        if (length > 50) {
            [MBProgressHUD showWarnMessage:@"最多输入50字"];
            return NO;
        }
    }
    return YES;
}

- (UITextField *)textField{
    if (!_textField) {
        _textField = [[UITextField alloc]init];
        [_textField setFont:[ATFontManager systemFontOfSize:16]];
        [_textField setTextColor:UIColorFromRGBA(000000, 0.9)];
        _textField.clearButtonMode = UITextFieldViewModeAlways;
    }
    return _textField;
}

- (void)dealloc {
    // 移除通知观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
