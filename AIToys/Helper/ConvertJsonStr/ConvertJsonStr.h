//
//  ConvertJsonStr.h
//  Saicio
//
//  Created by Mwave_wuyu on 2017/8/3.
//  Copyright © 2017年 blinq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConvertJsonStr : NSObject

+(NSString *)convertToJsonData:(NSObject *)dict;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
@end
