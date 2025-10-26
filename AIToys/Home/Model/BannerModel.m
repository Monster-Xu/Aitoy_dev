//
//  BannerModel.m
//  AIToys
//
//  Created by qdkj on 2025/7/11.
//

#import "BannerModel.h"

@implementation BannerModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"Id": @"id"};
}

//归档
- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    unsigned int count = 0;
    Ivar * ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char * name = ivar_getName(ivar);
        NSString * key = [[NSString alloc]initWithUTF8String:name];
        [coder encodeObject:[self valueForKey:key] forKey:key];
    }
}

//反归档
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        unsigned int count = 0;
          Ivar * ivars = class_copyIvarList([self class], &count);
          for (int i = 0; i < count; i++) {
              Ivar ivar = ivars[i];
              NSString * key = [[NSString alloc]initWithUTF8String:ivar_getName(ivar)];
              id value =  [coder decodeObjectForKey:key];
              [self setValue:value forKey:key];
          }
    }
    return  self;
}

@end
