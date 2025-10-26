//
//  FindDollModel.h
//  AIToys
//
//  Created by qdkj on 2025/7/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FindDollModel : NSObject
@property (nonatomic ,copy) NSString *Id;
@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,copy) NSString *type;//公仔类型(ip: ip公仔, creative: 创意公仔, explore: 探索公仔)
@property (nonatomic ,copy) NSString *family;
@property (nonatomic ,copy) NSString *model;//公仔型号
@property (nonatomic ,copy) NSString *desc;
@property (nonatomic ,copy) NSString *coverImg;
@property (nonatomic ,copy) NSString *backgroundImg;
@property (nonatomic ,copy) NSString *preview3d;
@property (nonatomic ,copy) NSString *releaseStatus;//发布状态(draft, gray, released, archived)
@property (nonatomic ,copy) NSString *grayConfig;//灰度规则配置
@property (nonatomic ,copy) NSString *createTime;

@property (nonatomic ,assign) NSInteger totalStoryNum;//总的故事数量
@property (nonatomic ,assign) NSInteger totalStoryDuration;//总的故事时长(秒)
@end

NS_ASSUME_NONNULL_END
