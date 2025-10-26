//
//  LGNoDataView.m
//  QiDianProhibit
//
//  Created by KWOK on 2019/4/24.
//  Copyright © 2019 Henan Qidian Network Technology Co. All rights reserved.
//

#import "LGNoDataView.h"
#import "ATFontManager.h"

@interface LGNoDataView()
@property (nonatomic, strong) UILabel       *textLabel;
@property (nonatomic, strong) UIImageView   *imageView;

@end


@implementation LGNoDataView
- (instancetype)initWithView:(UIView *)view {
    return [self initWithFrame:view.bounds];
}
- (instancetype)initWithViewNoHeader:(UIView *)view {
    return [self initWithFrame:view.bounds withNoHeader:YES];
}
- (instancetype)initWithViewSubviewFrame:(CGRect )frame {
    return [self initWithFrame:frame withNoHeader:YES];
}
- (instancetype)initWithFrame:(CGRect)frame withNoHeader:(BOOL )isValue{
    if (isValue) {
        self = [super initWithFrame:CGRectMake(0, 60, frame.size.width, frame.size.height - 60)];
    } else {
        self = [super initWithFrame:frame];
    }
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.textLabel];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self addSubview:self.imageView];
        [self addSubview:self.textLabel];
    }
    return self;
}
+ (void)removeAllPromptView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:self]) {
            [subView removeFromSuperview];
        }
    }
}
+ (instancetype)showAddTo:(UIView *)view withText:(NSString *)text withImage:(UIImage *)image {
    [LGNoDataView removeAllPromptView:view];
    LGNoDataView *noView = [[LGNoDataView alloc]initWithView:view];
    [view addSubview:noView];
    noView.textLabel.text = text;
    if (image) {
        noView.imageView.image = image;
        noView.imageView.frame = CGRectMake((noView.bounds.size.width - image.size.width) * 0.5, noView.bounds.size.height * 0.5 - image.size.height, image.size.width, image.size.height);
    }
    return noView;
}
+ (instancetype)showAddTo:(UIView *)view {
    [LGNoDataView removeAllPromptView:view];
    LGNoDataView *noView = [[LGNoDataView alloc]initWithViewNoHeader:view];
    [view addSubview:noView];
    noView.textLabel.text = @"暂无数据";
    UIImage *img = QD_IMG(@"no_data");
    noView.imageView.image = img;
    noView.imageView.frame = CGRectMake((noView.bounds.size.width - img.size.width) * 0.5, noView.bounds.size.height * 0.5 - img.size.height, img.size.width, img.size.height);
    return noView;
}
+ (instancetype)showAddToSubView:(UIView *)view delegate:(id)delegate withFrame:(CGRect)frame {
    [LGNoDataView removeAllPromptView:view];
    LGNoDataView *noView = [[LGNoDataView alloc]initWithFrame:frame];
    noView.delegate = delegate;
    noView.backgroundColor = [UIColor clearColor];
    [view addSubview:noView];
    UIImage *img = QD_IMG(@"no_data");
    noView.imageView.image = img;
    noView.imageView.frame = CGRectMake((noView.bounds.size.width - img.size.width) * 0.5, 10, img.size.width, img.size.height);
    noView.textLabel.frame = CGRectMake(15,CGRectGetMaxY(noView.imageView.frame) + 10, frame.size.width - 30, 20);
    noView.textLabel.text = @"暂无数据";
    UIButton *btn = [UIButton new];
    [btn addTarget:noView action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, noView.bounds.size.width, noView.bounds.size.height);
    btn.backgroundColor = [UIColor clearColor];
    [noView addSubview:btn];
    return noView;
}
+ (instancetype)showAddToSubView:(UIView *)view delegate:(id)delegate withTitle:(NSString *)title withFrame:(CGRect)frame {
    [LGNoDataView removeAllPromptView:view];
    LGNoDataView *noView = [[LGNoDataView alloc]initWithFrame:frame];
    noView.delegate = delegate;
    noView.backgroundColor = [UIColor clearColor];
    [view addSubview:noView];
    UIImage *img = [title isEqualToString:@"暂无待办信息"] ? nil : QD_IMG(@"no_data");
    noView.imageView.image = img;
    noView.imageView.frame = CGRectMake((noView.bounds.size.width - img.size.width) * 0.5, 10, img.size.width, img.size.height);
    noView.textLabel.frame = CGRectMake(15,CGRectGetMaxY(noView.imageView.frame) + 10, frame.size.width - 30, 20);
    noView.textLabel.text = title.length > 0 ? title : @"暂无数据";
    UIButton *btn = [UIButton new];
    [btn addTarget:noView action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, noView.bounds.size.width, noView.bounds.size.height);
    btn.backgroundColor = [UIColor clearColor];
    [noView addSubview:btn];
    return noView;
}
- (void)btnAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(LGNoDataViewClick)]) {
        [self.delegate LGNoDataViewClick];
    }
}
+ (instancetype)showAddTo:(UIView *)view withText:(NSString *)text{
    [LGNoDataView removeAllPromptView:view];
    LGNoDataView *noView = [[LGNoDataView alloc]initWithViewNoHeader:view];
    [view addSubview:noView];
    noView.textLabel.text = text.length > 0 ? text : @"暂无数据";
    UIImage *img = QD_IMG(@"no_data");
    noView.imageView.image = img;
    noView.imageView.frame = CGRectMake((noView.bounds.size.width - img.size.width) * 0.5, 10, img.size.width, img.size.height);
    noView.textLabel.centerX = noView.imageView.centerX;
    noView.textLabel.centerY = CGRectGetMaxY(noView.imageView.frame) + 20;
    return noView;
}
+ (instancetype)showAddToNoHeader:(UIView *)view
                         withText:(NSString *)text {
    [LGNoDataView removeAllPromptView:view];
    LGNoDataView *noView = [[LGNoDataView alloc]initWithViewNoHeader:view];
    [view addSubview:noView];
    noView.textLabel.text = text;
    UIImage *img = QD_IMG(@"no_data");
    noView.imageView.image = img;
    noView.imageView.frame = CGRectMake((noView.bounds.size.width - img.size.width) * 0.5, noView.bounds.size.height * 0.5 - img.size.height, img.size.width, img.size.height);
    return noView;
}
+ (void)cancelForView:(UIView *)view {
    LGNoDataView *noView = [self promptForView:view];
    if (noView != nil) {
        [noView removeFromSuperview];
    }
}
+ (instancetype)promptForView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:self]) {
            return (LGNoDataView *)subView;
        }
    }
    return nil;
}
- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.bounds.size.height * 0.5 + 25, self.bounds.size.width - 30, 20)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        _textLabel.textColor = UIColorFromRGB(0x888888);
        _textLabel.font = [ATFontManager boldSystemFontOfSize:16];
    }
    return _textLabel;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        UIImage *image = [UIImage imageNamed:@"no_data"];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width - image.size.width) * 0.5, self.bounds.size.height * 0.5 - image.size.height, image.size.width, image.size.height)];
        _imageView.image = image;
    }
    return _imageView;
}
@end
