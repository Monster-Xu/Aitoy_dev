//
//  RYFTableView.m
//  RDSQ
//
//  Created by renyufei on 2016/12/28.
//  Copyright © 2016年 renyufei. All rights reserved.
//

#import "RYFTableView.h"
#import "RYFGifHeader.h"

@interface RYFTableView ()

@end
@implementation RYFTableView

- (NSString *)emptyTitle {
    if (!_emptyTitle) {
        _emptyTitle = @"刷新试试";
    }
    return _emptyTitle;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.tableFooterView = [UIView new];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = YES;
    self.loadState = RYFCanLoadAll;
    self.emptyTitle = @"";
    self.emptySubtitle = @"";
    self.emptyAtrtibutedTitle = nil;
    self.emptyAtrtibutedSubtitle = nil;
    self.emptyImage = nil;
    self.emptyColor = [UIColor whiteColor];
    self.showEmpty = YES;
    self.page = 1;
    self.backgroundColor = UIColorHex(F6F7FB);
    [self beginLoading];

}

-(void)setPage:(NSInteger)page
{
    _page = page;
}

- (void)setTableViewDelegate:(id<RYFTableViewDelegate>)tableViewDelegate {
    _tableViewDelegate = tableViewDelegate;
    self.dataSource = (id<UITableViewDataSource>)tableViewDelegate;
    self.delegate = (id<UITableViewDelegate>)tableViewDelegate;
}

- (void)setLoadState:(RYFCanLoadState)loadState {
    _loadState = loadState;
    switch (loadState) {
        case RYFCanLoadAll:{
            [self setUpRefreshHeader];
            [self setUpRefreshFooter];
        }break;
        case RYFCanLoadRefresh:{
            [self setUpRefreshHeader];
            self.mj_footer = nil;
        }break;
        case RYFCanLoadNone:{
            self.mj_footer = nil;
            self.mj_header = nil;
        }break;
        default:
            break;
    }
}

- (void)beginLoading {
    WS(weakSelf);
    [self.mj_header beginRefreshingWithCompletionBlock:^{
        if (weakSelf.showEmpty) {
        }
    }];
}

- (void)endLoading {
    if ([self.mj_header isRefreshing]) {
        [self.mj_header endRefreshingWithCompletionBlock:^{
            [self ryfReloadData];
        }];
    }
    if ([self.mj_footer isRefreshing]) {
        [self.mj_footer endRefreshingWithCompletionBlock:^{
            [self ryfReloadData];
        }];
    }
}

-(void)noMoreData {
    if ([self.mj_footer isRefreshing] || [self.mj_header isRefreshing]){
        [self.mj_header endRefreshing];
        [self.mj_footer endRefreshingWithNoMoreData];
    }
}

- (void)setUpRefreshHeader {
    self.mj_header = [RYFGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.mj_header.multipleTouchEnabled = NO;
}

- (void)setUpRefreshFooter {
    self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullData)];
    self.mj_footer.multipleTouchEnabled = NO;
    self.mj_footer.hidden = YES;
}

- (void)refreshData {
    if (self.mj_footer.state == MJRefreshStateNoMoreData) {
        [self.mj_footer resetNoMoreData];
    }
    
    if (_tableViewDelegate && [_tableViewDelegate respondsToSelector:@selector(loadDataRefreshOrPull:)]) {
        [_tableViewDelegate loadDataRefreshOrPull:RYFRefreshTypeRefreshing];
    }
}

- (void)pullData {
    if (_tableViewDelegate && [_tableViewDelegate respondsToSelector:@selector(loadDataRefreshOrPull:)]) {
        [_tableViewDelegate loadDataRefreshOrPull:RYFRefreshTypePull];
    }
}

- (void)ryfReloadData {
    [self reloadData];
    if (self.loadState == RYFCanLoadAll && [self isEmptyTableView]) {
        self.mj_footer.hidden = YES;
    }else if (self.loadState == RYFCanLoadAll){
        self.mj_footer.hidden = NO;
    }
}

- (NSNumber *)getCurrentPage {
    return [NSNumber numberWithInteger:++self.page];
}

- (BOOL)isEmptyTableView {
    id<UITableViewDataSource> dataSource = self.dataSource;
    NSInteger section = 1;
    if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        section = [dataSource numberOfSectionsInTableView:self];
    }
    for (NSInteger i = 0; i < section; ++i) {
        NSInteger rows = [dataSource tableView:self numberOfRowsInSection:i];
        if (rows > 0) {
            return NO;
        }
    }
    return YES;
}


@end
