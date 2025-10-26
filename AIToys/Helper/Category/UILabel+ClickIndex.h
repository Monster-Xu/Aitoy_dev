//
//  UILabel+ClickIndex.h
//  AIToys
//
//  Created by qdkj on 2025/6/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (ClickIndex)
- (CFIndex)characterIndexAtPoint:(CGPoint)point;
@end

NS_ASSUME_NONNULL_END
