//
//  CompressImageData.h
//  HD
//
//  Created by 乔不赖 on 2020/2/19.
//  Copyright © 2020 HD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CompressImageData : NSObject

//网络图片转化为UIImage
+(UIImage *) getImageFromURL:(NSString *)fileURL;
/**
 *  将图片压缩并返回二进制流
 */
+ (NSData *)compressImageQuality:(UIImage *)image toByte:(NSUInteger)maxLength;

+ (UIImage *)compressImgQuality:(UIImage *)image toByte:(NSUInteger)maxLength;
@end

NS_ASSUME_NONNULL_END
