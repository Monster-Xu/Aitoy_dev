//
//  HWTextCodeView.m
//  AIToys
//
//  Created by qdkj on 2025/6/17.
//

#import "HWTextCodeView.h"
#import "ATFontManager.h"

@interface HWTextCodeView ()

@property (nonatomic, assign) NSInteger itemCount;

@property (nonatomic, assign) CGFloat itemMargin;

@property (nonatomic, weak) UITextField *textField;

@property (nonatomic, weak) UIControl *maskView;

@property (nonatomic, strong) NSMutableArray<UILabel *> *labels;
@property (nonatomic, strong) NSMutableArray<UIView *> *bgViews;

@property (nonatomic, strong) NSMutableArray<HWTC_lineView *> *lines;

/// 临时保存上次输入的内容(用于判断 删除 还是 输入)
@property (nonatomic, copy) NSString *tempStr;

@end

@implementation HWTextCodeView

- (instancetype)initWithCount:(NSInteger)count margin:(CGFloat)margin
{
    if (self = [super init]) {
    
        self.itemCount = count;
        self.itemMargin = margin;
        
        [self configTextField];
    }
    return self;
}

- (void)configTextField
{
    self.backgroundColor = [UIColor whiteColor];
    self.bgViews = @[].mutableCopy;
    self.labels = @[].mutableCopy;
    self.lines = @[].mutableCopy;
    
    UITextField *textField = [[UITextField alloc] init];
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    [textField addTarget:self action:@selector(tfEditingChanged:) forControlEvents:(UIControlEventEditingChanged)];
    [self addSubview:textField];
    self.textField = textField;
    
    UIButton *maskView = [UIButton new];
    maskView.backgroundColor = [UIColor whiteColor];
    [maskView addTarget:self action:@selector(clickMaskView) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:maskView];
    self.maskView = maskView;
    
    for (NSInteger i = 0; i < self.itemCount; i++)
    {
        UIView *bgView = [UIView new];
        bgView.layer.cornerRadius = 8;
        bgView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
        [self addSubview:bgView];
        [self.bgViews addObject:bgView];
    }
    
    for (NSInteger i = 0; i < self.itemCount; i++)
    {
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = [ATFontManager mappedFontWithName:@"SF-Pro-Rounded-Regular" size:30];
        [self addSubview:label];
        [self.labels addObject:label];
    }
    
    for (NSInteger i = 0; i < self.itemCount; i++)
    {
        HWTC_lineView *line = [HWTC_lineView new];
        line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:line];
        [self.lines addObject:line];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.labels.count != self.itemCount) return;
    
    CGFloat temp = self.bounds.size.width - (self.itemMargin * (self.itemCount - 1));
    CGFloat w = temp / self.itemCount;
    CGFloat x = 0;
    
    for (NSInteger i = 0; i < self.labels.count; i++)
    {
        x = i * (w + self.itemMargin);
        
        UIView *bgview = self.bgViews[i];
        bgview.frame = CGRectMake(x, 0, w, self.bounds.size.height);
        
        UILabel *label = self.labels[i];
        label.frame = CGRectMake(x, 0, w, self.bounds.size.height);
        
        UIView *line = self.lines[i];
        line.frame = CGRectMake(x, self.bounds.size.height - 1, w, 1);
    }
    
    self.textField.frame = self.bounds;
    self.maskView.frame = self.bounds;
}

#pragma mark - 编辑改变
- (void)tfEditingChanged:(UITextField *)textField
{
    if (textField.text.length > self.itemCount) {
        textField.text = [textField.text substringWithRange:NSMakeRange(0, self.itemCount)];
    }
    
    for (int i = 0; i < self.itemCount; i++)
    {
        UIView *bgView = [self.bgViews objectAtIndex:i];
        UILabel *label = [self.labels objectAtIndex:i];
        UIView *line = [self.lines objectAtIndex:i];
        
        if (i < textField.text.length) {
            label.text = [textField.text substringWithRange:NSMakeRange(i, 1)];
            line.backgroundColor = UIColorHex(0x5C61F4);
            bgView.backgroundColor = UIColorHex(0xF6F6F6);
            label.textColor = UIColor.blackColor;
        } else {
            if(i == textField.text.length){
                bgView.backgroundColor = UIColorHex(0x1989FA);
                label.textColor = UIColor.blackColor;
            }else{
                bgView.backgroundColor = UIColorHex(0xF6F6F6);
                label.textColor = UIColor.blackColor;
            }
            label.text = nil;
            line.backgroundColor = [UIColor lightGrayColor];
        }
    }
    
    // 动画效果，这里是删除时，不要动画，输入时显示动画
    if (self.tempStr.length < textField.text.length) {
        if (textField.text == nil || textField.text.length <= 0) {
            [self.lines.firstObject animation];
            
        } else if (textField.text.length >= self.itemCount) {
            [self.lines.lastObject animation];
            
            [self animation:self.labels.lastObject];
            
        } else {
            [self.lines[self.textField.text.length - 1] animation];
            
            UILabel *ff = self.labels[self.textField.text.length - 1];
            [self animation:ff];
        }
    }
    
    self.tempStr = textField.text;
    
    if (textField.text.length >= self.itemCount) {
        [textField resignFirstResponder];
    }
}

- (void)animation:(UILabel *)label
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = 0.15;
    animation.repeatCount = 1;
    animation.fromValue = @(0.1);
    animation.toValue = @(1);
    [label.layer addAnimation:animation forKey:@"zoom"];
}

- (void)clickMaskView
{
    [self.textField becomeFirstResponder];
}

- (BOOL)endEditing:(BOOL)force
{
    [self.textField endEditing:force];
    return [super endEditing:force];
}

- (NSString *)code
{
    return self.textField.text;
}

@end


// ------------------------------------------------------------------------
// -----------------------------HWTC_lineView------------------------------
// ------------------------------------------------------------------------


@implementation HWTC_lineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

#pragma mark - 初始化View
- (void)setupView
{
    UIView *colorView = [UIView new];
    [self addSubview:colorView];
    self.colorView = colorView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.colorView.frame = self.bounds;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:[UIColor clearColor]];
    self.colorView.backgroundColor = backgroundColor;
}

- (void)animation
{
    [self.colorView.layer removeAllAnimations];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    animation.duration = 0.18;
    animation.repeatCount = 1;
    animation.fromValue = @(1.0);
    animation.toValue = @(0.1);
    animation.autoreverses = YES;
    
    [self.colorView.layer addAnimation:animation forKey:@"zoom.scale.x"];
}

@end
