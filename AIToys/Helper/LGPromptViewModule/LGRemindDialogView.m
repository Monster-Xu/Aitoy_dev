//
//  LGRemindDialogView.m
//  QiDianProhibit
//
//  Created by KWOK on 2019/4/24.
//  Copyright © 2019 Henan Qidian Network Technology Co. All rights reserved.
//

#import "LGRemindDialogView.h"
#import "ATFontManager.h"

@interface LGRemindDialogView ()
@property (nonatomic,assign)BOOL isRemindDialogShowFlag;
@property (nonatomic, strong) UILabel *label;
@end

@implementation LGRemindDialogView
- (UILabel *)label {
    if (_label == nil) {
        _label = [[UILabel alloc]init];
    }
    return _label;
}
- (instancetype)initWithSuperView:(UIView *)superView
{
    if(self = [self initWithFrame:CGRectZero]){
        if(superView != nil){
            [superView addSubview:self];
        }
    }
    return self;
}

//代码创建
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self uiSetting];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        [self uiSetting];
    }
    return self;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark - 初始化方法
//页面初始化设置
- (void)uiSetting {
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
    self.layer.cornerRadius = 6.0;
    self.layer.masksToBounds = YES;
    self.userInteractionEnabled = NO;
    self.font = [ATFontManager systemFontOfSize:14];
    self.textColor = [UIColor whiteColor];
    self.textAlignment = NSTextAlignmentCenter;
    self.bounds = CGRectMake(0, 0, 260, 50);
    self.numberOfLines = 0;
    [self hideRemindDialog];
}

#pragma mark - 外部方法
//显示内容(延迟消失)
- (void)displayWithContentString:(NSString *)contentString {
    if((self.superview == nil)
       || [PublicObj isEmptyObject:contentString]){
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //取消延时隐藏
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideRemindDialog) object:nil];
        self.hidden = NO;
        self.text = contentString;
        NSDictionary *attrs = @{NSFontAttributeName :[ATFontManager boldSystemFontOfSize:17]};
        CGSize size=[self.text sizeWithAttributes:attrs];
        [self setFrame:CGRectMake(0, 0, size.width, 50)];
        self.center = CGPointMake(self.superview.bounds.size.width/2.0,
                                  self.superview.bounds.size.height/2.0 - 50);
        [self.superview bringSubviewToFront:self];
        //延时隐藏(2s后消失)
        [self performSelector:@selector(hideRemindDialog) withObject:nil afterDelay:1.0];
    });
}
- (void)displayWithContentStr:(NSString *)contentString {
    if((self.superview == nil)
       ||(contentString == nil)
       ||([contentString isEqualToString:@""])){
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //取消延时隐藏
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideRemindDialog) object:nil];
        self.hidden = NO;
        self.text = contentString;
        NSDictionary *attrs = @{NSFontAttributeName :[ATFontManager boldSystemFontOfSize:17]};
        CGSize size=[self.text sizeWithAttributes:attrs];
        [self setFrame:CGRectMake(0, 0, size.width, 50)];
        self.center = CGPointMake(self.superview.bounds.size.width/2.0,
                                  self.superview.bounds.size.height/2.0 - 50 - 146);
        [self.superview bringSubviewToFront:self];
        //延时隐藏(2s后消失)
        [self performSelector:@selector(hideRemindDialog) withObject:nil afterDelay:1.0];
    });
}
//隐藏提示消息视图
-(void)hideRemindDialog
{
    self.text = @"";
    self.hidden = YES;
    if((self.hidden == YES)
       &&(self.superview != nil)){
        [self.superview sendSubviewToBack:self];
    }
}

@end
