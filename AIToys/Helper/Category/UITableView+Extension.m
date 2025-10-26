//
//  UITableView+Extension.m
//  SocialLive
//
//  Created by 张海阔 on 2019/8/13.
//  Copyright © 2019 Mac. All rights reserved.
//

#import "UITableView+Extension.h"

@implementation UITableView (Extension)

//delaysContentTouches 默认值为YES，即UIScrollView会在接受到手势是延迟150ms来判断该手势是否能触发UIScrollView的滑动事件；
//反之值为NO时，UIScrollView会立马将接受到的手势分发到子视图上。即button在点击时会立即呈现高亮状态
- (BOOL)delaysContentTouches {
    return NO;
}

/**
 delaysContentTouches设置为NO是远远不够的，因为这样的话你想要拖动UIScrollView而起点落在其它有手势识别的视图上是会拖不动的。 于是我们要重载touchesShouldCancelInContentView，此方法决定手势是否取消传递到subView上，拖动UIScrollView时触发。
 */
- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    // 如果是button, 则点击button的时候不影响滑动
    if ([view isKindOfClass:[UIButton class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

@end
