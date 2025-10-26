//
//  NSDictionary+KeySortJoin.m
//  AIToys
//
//  Created by qdkj on 2025/8/20.
//

#import "NSDictionary+KeySortJoin.h"

@implementation NSDictionary (KeySortJoin)
- (NSString *)sortedKeysJoinedByAmpersand {
    return [self sortedKeysJoinedByAmpersandAscending:YES];
}

- (NSString *)sortedKeysJoinedByAmpersandAscending:(BOOL)ascending {
    // 字典判空
    if (!self || [self isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    NSArray *keys = [self allKeys];
    if (!keys || keys.count == 0) {
        return @"";
    }
    
    // 过滤nil key并处理value
    NSMutableArray *keyValuePairs = [NSMutableArray array];
    for (id key in keys) {
        if (key && ![key isKindOfClass:[NSNull class]]) {
            id value = self[key];
            NSString *pair = value ?
                [NSString stringWithFormat:@"%@=%@", key, value] :
                [NSString stringWithFormat:@"%@=", key];
            [keyValuePairs addObject:pair];
        }
    }
    
    if (keyValuePairs.count == 0) {
        return @"";
    }
    
    // 排序处理
    NSArray *sortedPairs = ascending ?
        [keyValuePairs sortedArrayUsingSelector:@selector(compare:)] :
        [keyValuePairs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj2 compare:obj1];
        }];
    
    return [sortedPairs componentsJoinedByString:@"&"];
}
@end
