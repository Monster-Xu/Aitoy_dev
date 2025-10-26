//
//  UIAlertController+simpleCreate.h
//  CSConsulting
//
//  Created by 刘璇 on 2020/6/2.
//  Copyright © 2020 ChangSong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (simpleCreate)

+(void)cs_alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle cancleButtonTitle:(nullable NSString *)cancleButtonTitle otherTitle:(NSArray<NSString *> *)otherTitle controller:(UIViewController *)vc actionBlock:(void (^ __nullable)(UIAlertAction *action , NSInteger idx))handler;


@end

NS_ASSUME_NONNULL_END
