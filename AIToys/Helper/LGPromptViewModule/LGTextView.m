//
//  LGTextView.m
//  nobalmetal
//
//  Created by lichenbiao on 16/8/20.
//  Copyright © 2016年 judu. All rights reserved.
//

#import "LGTextView.h"
#import "ATFontManager.h"
@implementation LGTextView

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        [self.layer setOpaque:NO];
        _placeholderLable = [[UILabel alloc]init];
        _placeholderLable.numberOfLines = 0;
        [self insertSubview:_placeholderLable atIndex:0];
        [_placeholderLable setFont:[ATFontManager systemFontOfSize:14]];
        self.placeholderColor = UIColorFromRGBA(000000, 0.5);
        // 2.监听自己文字的改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textChange
{
    if (self.text.length){
        _placeholderLable.hidden = YES;
    }else{
        _placeholderLable.hidden = NO;
    }
}
-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    
    _placeholderLable.text = _placeholder;
    [self setNeedsLayout];
}

-(void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    _placeholderLable.font = font;
    
    [self setNeedsLayout];
}

-(void)setText:(NSString *)text{
    [super setText: text];
    if (text.length){
        _placeholderLable.hidden = YES;
    }else{
        _placeholderLable.hidden = NO;
    }
}

-(void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    
    _placeholderLable.textColor = placeholderColor;
}

- (NSString *)tx
{
    return [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize sz = QDSize(_placeholder, [ATFontManager systemFontOfSize:14], CGSizeZero);
    _placeholderLable.frame = CGRectMake(4, 8, sz.width, sz.height);
    
}

//- (void)drawLineWithContext:(CGContextRef )ctx
//{
//    CGContextSetLineWidth(ctx, .5);
//    CGContextSetStrokeColorWithColor(ctx, UIColorFromRGB(0xd8d8d8).CGColor);
//    CGContextMoveToPoint(ctx, 0, BOUNDS_HEIGHT-1);
//    CGContextAddLineToPoint(ctx, BOUNDS_WIDTH, BOUNDS_HEIGHT-1);
//    CGContextStrokePath(ctx);
//}

//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [self drawLineWithContext:context];
//}

@end
