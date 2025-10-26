//
//  UILabel+ClickIndex.m
//  AIToys
//
//  Created by qdkj on 2025/6/19.
//

#import "UILabel+ClickIndex.h"
#import <CoreText/CoreText.h>

@implementation UILabel (ClickIndex)
- (CFIndex)characterIndexAtPoint:(CGPoint)point {
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NSNotFound;
    }
    
    CGRect textRect = [self textRectForBounds:self.bounds
                    limitedToNumberOfLines:self.numberOfLines];
    if (!CGRectContainsPoint(textRect, point)) {
        return NSNotFound;
    }
    
    // 坐标转换（UILabel坐标系 → CoreText坐标系）
    point = CGPointMake(point.x - textRect.origin.x,
                       textRect.size.height - point.y + textRect.origin.y);
    
    // 创建CoreText布局
    NSMutableAttributedString *attrStr = [self.attributedText mutableCopy];
    [attrStr addAttribute:NSFontAttributeName
                   value:self.font
                   range:NSMakeRange(0, attrStr.length)];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(
                        (__bridge CFAttributedStringRef)attrStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                        CFRangeMake(0, attrStr.length), path, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint *origins = malloc(lineCount * sizeof(CGPoint));
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    CFIndex charIndex = NSNotFound;
    for (CFIndex i = 0; i < lineCount; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGPoint lineOrigin = origins[i];
        
        // 检查点击是否在当前行
        CGFloat ascent, descent, leading;
        CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGRect lineRect = CGRectMake(lineOrigin.x,
                                   lineOrigin.y - descent,
                                   lineWidth,
                                   ascent + descent);
        
        if (CGRectContainsPoint(lineRect, point)) {
            // 计算字符索引
            CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x,
                                              point.y - lineOrigin.y);
            charIndex = CTLineGetStringIndexForPosition(line, relativePoint);
            break;
        }
    }
    
    free(origins);
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    
    return charIndex;
}
@end
