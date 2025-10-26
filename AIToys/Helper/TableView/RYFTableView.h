//
//  RYFTableView.h
//  RDSQ
//
//  Created by renyufei on 2016/12/28.
//  Copyright © 2016年 renyufei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,RYFRefreshType) {
    RYFRefreshTypeRefreshing = 0,
    RYFRefreshTypePull
};

typedef NS_ENUM(NSInteger,RYFCanLoadState) {
    RYFCanLoadNone = 0,
    RYFCanLoadRefresh,
    RYFCanLoadAll,
    PersonnalRefresh
};

@protocol RYFTableViewDelegate <NSObject>

@optional

- (void)loadDataRefreshOrPull:(RYFRefreshType)type;

@end
@interface RYFTableView : UITableView

@property (nonatomic, weak) id<RYFTableViewDelegate> tableViewDelegate;
/** 是否展示空白页 默认为YES*/
@property (nonatomic, assign) BOOL showEmpty;
/** 加载支持，默认同时支持下拉和加载更多*/
@property (nonatomic, assign) IBInspectable RYFCanLoadState loadState;

/**空白页的标题 默认为 “" 为空,不显示*/
@property(nonatomic,copy) IBInspectable NSString *emptyTitle;
/**  空白页的副标题 默认为 “" 为空,不显示*/
@property(nonatomic,copy) IBInspectable NSString *emptySubtitle;
/**  空白页展位图名称 默认为 nil,不显示*/
@property(nonatomic,strong) IBInspectable UIImage *emptyImage;
/**  空白页背景颜色,默认白色*/
@property(nonatomic,strong) IBInspectable UIColor *emptyColor;


/**空白页的标题 默认为 nil,显示emptyTitle*/
@property(nonatomic,copy) IBInspectable NSAttributedString *emptyAtrtibutedTitle;
/**  空白页的副标题 默认为 nil,emptySubtitle*/
@property(nonatomic,copy) IBInspectable NSAttributedString *emptyAtrtibutedSubtitle;

@property (nonatomic,assign) NSInteger page;

- (NSNumber *)getCurrentPage;

- (void)beginLoading;

- (void)endLoading;

- (void)noMoreData;


@end
