//
//  NSString+Regex.m
//  HFKitDemo
//
//  Created by helfy on 16/6/29.
//  Copyright © 2016年 helfy. All rights reserved.
//

#import "NSString+Regex.h"

@implementation NSString(Regex)

+(NSString *)userNameRegex
{
    return @"^[\u4e00-\u9fa5]{0,8}";
}
+(NSString *)passWordRegex
{
    return @"^(?=.*[A-Za-z])(?=.*\\d)[\\x20-\\x7E]{6,20}$";
}
+(NSString *)emailRegex
{
    return  @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
}

+(NSString *)phoneNumberRegex
{
    return  @"^1(3|4|5|6|7|8|9)\\d{9}$";
}

+(NSString *)carNoRegex
{
    return  @"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$";
}


+(NSString *)identityCardPredicate
{
    return @"^(\\d{14}|\\d{17})(\\d|[xX])$";
}

- (BOOL)validateForRegex:(NSString *)regex {
   
    NSPredicate *regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [regexPredicate evaluateWithObject:self];
}
+ (UIViewController*)stringChangeToClass:(NSString *)str {
    id vc = [[NSClassFromString(str) alloc]init];
    if ([vc isKindOfClass:[UIViewController class]]) {
        return vc;
    }
    return nil;
}

//验证银行卡号
+ (BOOL)checkCardNo:(NSString*)cardNo{
    
    if (cardNo.length < 15) {
        
        return NO;
        
    }
    int oddsum = 0;//奇数求和
    
    int evensum = 0;//偶数求和
    
    int allsum = 0;
    
    int cardNoLength = (int)[cardNo length];
    
    int lastNum = [[cardNo substringFromIndex:cardNoLength-1] intValue];
    
    cardNo = [cardNo substringToIndex:cardNoLength - 1];
    
    for (int i = cardNoLength -1 ; i>=1;i--) {
        
        NSString *tmpString = [cardNo substringWithRange:NSMakeRange(i-1, 1)];
        
        int tmpVal = [tmpString intValue];
        
        if (cardNoLength % 2 ==1 ) {
            
            if((i % 2) == 0){
                
                tmpVal *= 2;
                
                if(tmpVal>=10)
                    
                    tmpVal -= 9;
                
                evensum += tmpVal;
                
            }else{
                
                oddsum += tmpVal;
                
            }
            
        }else{
            
            if((i % 2) == 1){
                
                tmpVal *= 2;
                
                if(tmpVal>=10)
                    
                    tmpVal -= 9;
                
                evensum += tmpVal;
                
            }else{
                
                oddsum += tmpVal;
                
            }
            
        }
        
    }
    
    allsum = oddsum + evensum;
    
    allsum += lastNum;
    
    if((allsum % 10) == 0)
        
        return YES;
    
    else
        
        return NO;
    
}

@end
