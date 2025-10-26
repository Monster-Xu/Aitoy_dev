//
//  HomeDollModel.h
//  AIToys
//
//  Created by qdkj on 2025/7/7.
//

#import <Foundation/Foundation.h>
#import "FindDollModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeDollModel : NSObject
@property (nonatomic ,copy) NSString *Id;
@property (nonatomic ,copy) NSString *ownerId;
@property (nonatomic ,copy) NSString *memberUserId;
@property (nonatomic ,copy) NSString *active;
@property (nonatomic ,copy) NSString *activeTime;
@property (nonatomic ,copy) NSString *createTime;
@property (nonatomic ,copy) NSString *deviceInstanceId;
@property (nonatomic, strong) FindDollModel *dollModel;
@property (nonatomic ,copy) NSString *dollModelId;
@property (nonatomic ,copy) NSString *hardwareCode;
@property (nonatomic ,assign) NSInteger totalStoryNum;//总的故事数量
@property (nonatomic ,assign) NSInteger totalStoryDuration;//总的故事时长(秒)
@end

NS_ASSUME_NONNULL_END
