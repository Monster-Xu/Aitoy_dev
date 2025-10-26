//
//  UITextField+IndexPath.m
//  RDSQ
//
//  Created by renyufei on 2017/3/14.
//  Copyright © 2017年 renyufei. All rights reserved.
//

#import "UITextField+IndexPath.h"

@implementation UITextField (IndexPath)
static char indexPathKey;
- (NSIndexPath *)indexPath{
    return objc_getAssociatedObject(self, &indexPathKey);
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    objc_setAssociatedObject(self, &indexPathKey, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
