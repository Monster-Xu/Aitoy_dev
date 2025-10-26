//
//  AvatarModel.h
//  AIToys
//
//  Created by qdkj on 2025/8/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AvatarModel : NSObject
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *memberUserId;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *avatarName;
@property (nonatomic, assign) NSInteger isDefault;
@property (nonatomic, copy) NSString *createTime;

@property (nonatomic, assign) NSInteger isSelect;
@end

NS_ASSUME_NONNULL_END
