//
//  RYFGifHeader.m
//  RDSQ
//
//  Created by renyufei on 2016/12/28.
//  Copyright © 2016年 renyufei. All rights reserved.
//

#import "RYFGifHeader.h"

@implementation RYFGifHeader

- (void)prepare {
    [super prepare];

 
// 添加普通状态下的GIF图片（可选多张）
NSString *filePath = [[NSBundle mainBundle] pathForResource:@"my_gif" ofType:@"gif"]; // 替换为你的GIF文件路径
    
    NSData  *imageData = [NSData dataWithContentsOfFile:filePath];
    UIImage *gifImg = [UIImage sd_imageWithGIFData:imageData];
 

    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i <= 3; i++) {
        UIImage *image = [UIImage imageNamed:@"icon_refresh_1"];
        [idleImages addObject:image];
    }
    [idleImages addObject:gifImg];
//    [self setImages:idleImages forState:MJRefreshStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i <= 7; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_refresh_%zd", i]];
        [refreshingImages addObject:image];
    }
//    [refreshingImages addObject:gifImg];
    [self setImages:refreshingImages forState:MJRefreshStatePulling];
    
    // 设置正在刷新状态的动画图片
    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];

    self.lastUpdatedTimeLabel.hidden = YES;
    self.stateLabel.hidden = YES;
}

@end
