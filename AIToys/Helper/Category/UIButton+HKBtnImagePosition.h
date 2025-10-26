//
//  UIButton+HKBtnImagePosition.h
//  ButtonEdgeInsets
//
//  Created by 张海阔 on 2019/11/1.
//  Copyright © 2019 OceanCodes. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HKBtnImagePosition) {
    HKBtnImagePosition_Top,    // image在上，label在下
    HKBtnImagePosition_Left,   // image在左，label在右
    HKBtnImagePosition_Bottom, // image在下，label在上
    HKBtnImagePosition_Right   // image在右，label在左
};

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (HKBtnImagePosition)

- (void)layoutWithStyle:(HKBtnImagePosition)Position space:(CGFloat)space;

@end

NS_ASSUME_NONNULL_END
