//
//  LGInputAlertView.m
//  QiDianProhibit
//
//  Created by KWOK on 2019/4/24.
//  Copyright © 2019 Henan Qidian Network Technology Co. All rights reserved.
//

#import "LGAlertView.h"
#import "ATFontManager.h"

static CGFloat const AlvertViewWidth = 260.0f;

#pragma mark - LGAlertView

@interface LGAlertView()

@property (nonatomic, strong) UIView *mainView;

@property (nonatomic, strong) UIView *hView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, copy) LGAlertViewBlock block;

- (UIButton *)setupButton:(NSString *)title tag:(NSInteger)tag;

- (CGFloat)heightForText:(NSString *)text width:(CGFloat)width font:(UIFont *)font;

- (void)touchButton:(UIButton *)button;

@end

@implementation LGAlertView
+ (void)showWithTitle:(NSString *)title message:(NSString *)message action:(LGAlertViewBlock)action {
    LGAlertView *view = [[LGAlertView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    view.titleLabel.text = title;
    view.detailLabel.text = message;
    view.buttons = @[@"取消",@"确定"];
    view.block = action;
    [[UIApplication sharedApplication].keyWindow addSubview:view];
}
+ (void)showWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons action:(LGAlertViewBlock)action {
    LGAlertView *view = [[LGAlertView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    view.titleLabel.text = title;
    view.detailLabel.text = message;
    view.buttons = buttons;
    view.block = action;
    [[UIApplication sharedApplication].keyWindow addSubview:view];
}

+ (void)showWithTitle:(NSString *)title message:(NSString *)message info:(NSString *)info buttons:(NSArray *)buttons action:(LGAlertViewBlock)action {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        self.mainView = [[UIView alloc] init];
        self.mainView.backgroundColor = [UIColor whiteColor];
//        self.mainView.layer.masksToBounds = YES;
        self.mainView.layer.cornerRadius = 10.0;
        [self addSubview:self.mainView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [ATFontManager systemFontOfSize:14 weight:0.2];
        self.titleLabel.textColor = UIColorFromRGBA(000000, 0.9);// HEX(0x4C4743);
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 0;
        [self.mainView addSubview:self.titleLabel];
        
        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.backgroundColor = [UIColor clearColor];
        self.detailLabel.font = [ATFontManager systemFontOfSize:14];
        self.detailLabel.textColor = [UIColor colorWithRed:166.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];// HEX(0xA6A6A6);
        self.detailLabel.numberOfLines = 0;
        [self.mainView addSubview:self.detailLabel];
        
        self.hView = [[UIView alloc] init];
        self.hView.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];// HEX(0xD8D8D8);
        [self.mainView addSubview:self.hView];
    }
    return self;
}

- (NSArray *)buttons {
    if (!_buttons) {
        _buttons = @[@"取消",@"确定"];
    }
    return _buttons;
}

- (UIButton *)setupButton:(NSString *)title tag:(NSInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectZero;
//    [button.titleLabel setFont:MCNFont(17)];
    [button.titleLabel setFont:[ATFontManager systemFontOfSize:17 weight:0]];
    [button setTitle:title forState:UIControlStateNormal];
//    [button setTitleColor:RGB(0, 128, 255) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0 green:128.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = tag;
    [self.mainView addSubview:button];
    return button;
}

- (void)layoutSubviews {
    CGFloat width = AlvertViewWidth;
    CGRect rect = CGRectMake(0, 0, width, 0);
    self.mainView.frame = rect;
    rect = CGRectMake(15, 8, width-30, 0);
    if (self.titleLabel.text && self.titleLabel.text.length > 0) {
        rect.size.height = [self heightForText:self.titleLabel.text width:(width-40) font:self.titleLabel.font];
        self.titleLabel.frame = rect;
        rect.origin.y += rect.size.height;
    }
    if (self.detailLabel.text && self.detailLabel.text.length > 0) {
        rect.size.height = [self heightForText:self.detailLabel.text width:(width-40) font:self.detailLabel.font];
        self.detailLabel.frame = rect;
        rect.origin.y += rect.size.height;
    }
    rect = CGRectMake(0, CGRectGetMinY(rect) + 8, width, 1);
    self.hView.frame = rect;
    
    rect.origin.y += rect.size.height;
    rect.size.height = 44;
    NSInteger count = self.buttons.count;
    CGFloat iw = (width - (count - 1))/count;
    rect.size.width = iw;
    for (NSInteger i = 0; i < count; i++) {
        UIButton *button = [self setupButton:self.buttons[i] tag:i];
        button.frame = rect;
        rect.origin.x += rect.size.width;
        rect.size.width = 1;
        if (count > 1 && i < count - 1) {
            UIView *line = [[UIView alloc] initWithFrame:rect];
            line.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];// HEX(0xE0E0E0);
            [self.mainView addSubview:line];
            rect.origin.x += rect.size.width;
            rect.size.width = iw;
        }
    }
    
    rect = CGRectMake(0, 0, width, CGRectGetMaxY(rect));
    self.mainView.frame = rect;
    self.mainView.center = self.center;
}

- (CGFloat)heightForText:(NSString *)text width:(CGFloat)width font:(UIFont *)font {
    return ceilf([text boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.height) + 10;
}

- (void)touchButton:(UIButton *)button {
    NSInteger tag = button.tag;
    if (self.block) {
        self.block(self, tag);
    }
    [self removeFromSuperview];
}

- (void)dealloc {
    if (self.block) {
        self.block = nil;
    }
}

@end


#pragma mark - LGAppUpdateView
@interface LGAppUpdateView()
@property (nonatomic, strong) UIImageView *iconImg;
@end

@implementation LGAppUpdateView

+ (void)showUpDataAlertViewWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons action:(LGAlertViewBlock)action{
    LGAppUpdateView * appUpdateView = [[LGAppUpdateView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    appUpdateView.titleLabel.text = title;
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByCharWrapping;
    paragraph.lineSpacing = 4.0f;
    message = message?:@"";
    appUpdateView.detailLabel.attributedText = [[NSAttributedString alloc] initWithString:message attributes:@{NSParagraphStyleAttributeName:paragraph}];
    appUpdateView.block = action;
    appUpdateView.buttons = buttons;
    [[UIApplication sharedApplication].keyWindow addSubview:appUpdateView];
    [appUpdateView setNeedsLayout];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _iconImg = [[UIImageView alloc] init];
        _iconImg.image = [UIImage imageNamed:@"icon_alert"];
        [self.mainView addSubview:_iconImg];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat width = AlvertViewWidth;
    CGRect rect = CGRectMake(0, - 61, width, 0);
    self.mainView.frame = rect;
    self.iconImg.frame = CGRectMake(0, -61, 175, 122);
    rect = CGRectMake(15, self.iconImg.height *0.5 + 8, width-30, 0);
    if (self.titleLabel.text && self.titleLabel.text.length > 0) {
        rect.size.height = [self heightForText:self.titleLabel.text width:(width-40) font:self.titleLabel.font];
        self.titleLabel.frame = rect;
        rect.origin.y += rect.size.height;
    }
    if (self.detailLabel.text && self.detailLabel.text.length > 0) {
        rect.size.height = [self heightForText:self.detailLabel.text width:(width-40) font:self.detailLabel.font];
        NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByCharWrapping;
        paragraph.lineSpacing = 4.0f;
        rect.size.height = ceilf([[self.detailLabel.attributedText string] boundingRectWithSize:CGSizeMake(width - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.detailLabel.font,NSParagraphStyleAttributeName:paragraph} context:nil].size.height) + 10;
        self.detailLabel.frame = rect;
        rect.origin.y += rect.size.height;
    }
    rect = CGRectMake(0, CGRectGetMinY(rect) + 8, width, 1);
    self.hView.frame = rect;
    
    rect.origin.y += rect.size.height;
    rect.size.height = 44;
    NSInteger count = self.buttons.count;
    CGFloat iw = (width - (count - 1))/count;
    rect.size.width = iw;
    for (NSInteger i = 0; i < count; i++) {
        UIButton *button = [self setupButton:self.buttons[i] tag:i];
        if (count >=2 && i ==0) {
//            [button setTitleColor:HEX(0xC9C9C9) forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
        button.frame = rect;
        rect.origin.x += rect.size.width;
        rect.size.width = 1;
        if (count > 1 && i < count - 1) {
            UIView *line = [[UIView alloc] initWithFrame:rect];
            line.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];// HEX(0xE0E0E0);
            [self.mainView addSubview:line];
            rect.origin.x += rect.size.width;
            rect.size.width = iw;
        }
    }
    
    rect = CGRectMake(0, self.iconImg.height *0.5 + 8, width, CGRectGetMaxY(rect));
    self.mainView.frame = rect;
    CGPoint cent = CGPointMake(self.center.x, self.center.y + self.iconImg.height * 0.25);
    self.mainView.center = cent;
    self.iconImg.left = (self.mainView.width - self.iconImg.width) *0.5;
}

@end
