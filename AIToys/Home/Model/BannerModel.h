//
//  BannerModel.h
//  AIToys
//
//  Created by qdkj on 2025/7/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BannerModel : NSObject
@property (nonatomic ,copy) NSString *Id;
@property (nonatomic ,copy) NSString *title;
@property (nonatomic ,copy) NSString *positionCode;
@property (nonatomic ,copy) NSString *mediaUrl;
@property (nonatomic ,copy) NSString *linkUrl;
@property (nonatomic ,copy) NSString *linkParams;//跳转参数（JSON格式）

@property (nonatomic ,copy) NSString *imageUrl;//启动图
@end

NS_ASSUME_NONNULL_END
