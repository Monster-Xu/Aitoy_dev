//
//  CompressImageData.m
//  HD
//
//  Created by 乔不赖 on 2020/2/19.
//  Copyright © 2020 HD. All rights reserved.
//

#import "CompressImageData.h"

@implementation CompressImageData

+(UIImage *) getImageFromURL:(NSString *)fileURL
{
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}

+ (NSData *)compressImageQuality:(UIImage *)image toByte:(NSUInteger)maxLength{
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
       if (data.length < maxLength) return data;
       
       // Compress by size
       NSUInteger lastDataLength = 0;
       while (data.length > maxLength && data.length != lastDataLength) {
           lastDataLength = data.length;
           CGFloat ratio = (CGFloat)maxLength / data.length;
           CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                    (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
           UIGraphicsBeginImageContext(size);
           [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
           resultImage = UIGraphicsGetImageFromCurrentImageContext();
           UIGraphicsEndImageContext();
           data = UIImageJPEGRepresentation(resultImage, compression);
       }
    return data;
}

+ (UIImage *)compressImgQuality:(UIImage *)image toByte:(NSUInteger)maxLength{
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return image;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
       if (data.length < maxLength) return resultImage;
       
       // Compress by size
       NSUInteger lastDataLength = 0;
       while (data.length > maxLength && data.length != lastDataLength) {
           lastDataLength = data.length;
           CGFloat ratio = (CGFloat)maxLength / data.length;
           CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                    (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
           UIGraphicsBeginImageContext(size);
           [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
           resultImage = UIGraphicsGetImageFromCurrentImageContext();
           UIGraphicsEndImageContext();
           data = UIImageJPEGRepresentation(resultImage, compression);
       }
    return resultImage;
}
@end
