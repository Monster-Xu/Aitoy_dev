//
//  HomeExploreToysView.m
//  AIToys
//
//  Created by qdkj on 2025/6/26.
//

#import "HomeExploreToysView.h"
#import "HomeExploreToysCell.h"
#import <ThingSmartMiniAppBizBundle/ThingSmartMiniAppBizBundle.h>

@interface HomeExploreToysView()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, copy) void(^scrollCallback)(UIScrollView *scrollView);
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation HomeExploreToysView

- (void)dealloc
{
    self.scrollCallback = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.tableFooterView = [UITableView new];
        self.tableView.estimatedRowHeight = 320;
        self.tableView.backgroundColor = UIColor.clearColor;
        self.tableView.scrollEnabled = false;
        [self.tableView registerNib:[UINib nibWithNibName:@"HomeExploreToysCell" bundle:nil] forCellReuseIdentifier:@"HomeExploreToysCell"];
        self.backgroundColor = tableBgColor;
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.tableView.frame = self.bounds;
}

-(void)setModel:(FindDollModel *)model{
    _model = model;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeExploreToysCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeExploreToysCell"];
    WEAK_SELF
    cell.playBlock = ^{
        // 埋点上报：探索页面点击公仔
        [[AnalyticsManager sharedManager] reportExploreClickDollWithId:weakSelf.model.Id ?: @""
                                                                  name:weakSelf.model.name ?: @""];
        //试听一下点击
        [[NSNotificationCenter defaultCenter] postNotificationName:@"auditionNotification"
                                                            object:nil
                                                          userInfo:@{@"DollId": weakSelf.model.Id}];
//        // 跳转小程序
//        NSString *currentHomeId = [CoreArchive strForKey:KCURRENT_HOME_ID];
//        [[ThingMiniAppClient coreClient] openMiniAppByUrl:@"godzilla://ty7y8au1b7tamhvzij/pages/doll-detail/index" params:@{@"dollId":weakSelf.model.Id,@"BearerId":(kMyUser.accessToken?:@""),@"type":@"explore",@"homeId":(currentHomeId?:@""),@"langType":@"en"}];
    };
    cell.model = self.model;
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !self.scrollCallback?:self.scrollCallback(scrollView);
}

#pragma mark - JXPagingViewListViewDelegate

- (UIScrollView *)listScrollView {
    return self.tableView;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.scrollCallback = callback;
}

- (void)listViewLoadDataIfNeeded { 
    
}


@end
