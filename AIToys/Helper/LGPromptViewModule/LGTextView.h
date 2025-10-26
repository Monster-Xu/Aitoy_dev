//
//  LGTextView.h
//  nobalmetal
//
//  Created by lichenbiao on 16/8/20.
//  Copyright © 2016年 judu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGTextView : UITextView
{
    // 提醒控件
    UILabel *_placeholderLable;
}

@property (nonatomic, copy)NSString* tx;
/** 设置提醒文字 */
@property (nonatomic,copy) NSString *placeholder;

/** 设置提醒文字的颜色 */
@property (nonatomic,strong) UIColor *placeholderColor;

@end
