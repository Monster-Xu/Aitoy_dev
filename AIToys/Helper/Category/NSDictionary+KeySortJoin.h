//
//  NSDictionary+KeySortJoin.h
//  AIToys
//
//  Created by qdkj on 2025/8/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (KeySortJoin)
- (NSString *)sortedKeysJoinedByAmpersand;
- (NSString *)sortedKeysJoinedByAmpersandAscending:(BOOL)ascending;
@end

NS_ASSUME_NONNULL_END
