//
//  AppSettingModel.h
//  AIToys
//
//  Created by qdkj on 2025/8/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppSettingModel : NSObject
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *memberUserId;
@property (nonatomic, copy) NSString *propKey;
@property (nonatomic, copy) NSString *propValue;
@end

NS_ASSUME_NONNULL_END
