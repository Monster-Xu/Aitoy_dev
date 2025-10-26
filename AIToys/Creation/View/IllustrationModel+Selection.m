//
//  IllustrationModel+Selection.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/15.
//

#import "IllustrationModel+Selection.h"

@implementation IllustrationModel (Selection)

static const char kIsSelectKey;

- (void)setIsSelect:(BOOL)isSelect {
    objc_setAssociatedObject(self, &kIsSelectKey, @(isSelect), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSelect {
    NSNumber *value = objc_getAssociatedObject(self, &kIsSelectKey);
    return [value boolValue];
}

@end
