//
//  UIAlertController+simpleCreate.m
//  CSConsulting
//
//  Created by 刘璇 on 2020/6/2.
//  Copyright © 2020 ChangSong. All rights reserved.
//

#import "UIAlertController+simpleCreate.h"
#import "AppDelegate.h"
@implementation UIAlertController (simpleCreate)

+(void)cs_alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle cancleButtonTitle:(nullable NSString *)cancleButtonTitle otherTitle:(NSArray<NSString *> *)otherTitle controller:(UIViewController *)vc actionBlock:(void (^ __nullable)(UIAlertAction *action , NSInteger idx))handler{
    

    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    
    if (cancleButtonTitle && cancleButtonTitle.length) {
        [alert addAction:[UIAlertAction actionWithTitle:cancleButtonTitle style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            handler(action,0);
        }]];
    }
    for (int i = 0; i<otherTitle.count; i++) {
        [alert addAction:[UIAlertAction actionWithTitle:otherTitle[i] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            handler(action,i+1);
        }]];
    }
    
    /* 修改按钮的颜色 */
//    NSArray *actionArr = [alert actions];
//    for (int i = 0; i<actionArr.count; i++) {
//        if(i>0){
//            [actionArr[i] setValue:[UIColor orangeColor] forKey:@"titleTextColor"];
//        }
//    }
    
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
    
}






@end
