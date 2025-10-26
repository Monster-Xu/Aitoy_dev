//
//  HomeViewController.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/18.
//

#import "HomeViewController.h"
#import <SDCycleScrollView.h>
#import "HomeNoDeviceCell.h"
#import "HomeDeviceCell.h"
#import "HomeToysCell.h"
#import "JHCustomMenu.h"
#import "FamailyManageVC.h"
#import "AddToysGuideVC.h"
#import "ToysGuideFindVC.h"
#import "HomeDeviceListVC.h"
#import "HomeToysListVC.h"
#import "SwitchFamailyVC.h"
#import "JXPageListView.h"
#import "HomeExploreToysView.h"
#import "RYFGifHeader.h"
#import "FindDeviceViewController.h"
#import "BannerModel.h"
#import "LineTableViewHeaderFooterView.h"
#import "QATabAnimationTwoCell.h"
#import "QATabAnimationThreeCell.h"
#import <ThingSmartMiniAppBizBundle/ThingSmartMiniAppBizBundle.h>
#import <ThingSmartBizCore/ThingSmartBizCore.h>
#import <ThingModuleServices/ThingFamilyProtocol.h>
#import <ThingModuleServices/ThingSmartHomeDataProtocol.h>

#import <AudioToolbox/AudioToolbox.h>
#import "WCQRCodeScanningVC.h"
#import "SGQRCodeScanManager.h"
#import "ATFontManager.h"
#import "SwitchConfigViewController.h"
#import "AnalyticsManager.h"
#import "AppSettingModel.h"
#import "AudioPlayerView.h"

static const CGFloat JXPageheightForHeaderInSection = 100;

@interface HomeViewController ()<SDCycleScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,JHCustomMenuDelegate,ThingSmartHomeManagerDelegate,JXPageListViewDelegate,ThingSmartHomeDelegate,ThingSmartBLEManagerDelegate,ThingSmartBLEWifiActivatorDelegate,AudioPlayerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;

@property (nonatomic, strong) JHCustomMenu *menu;

@property (nonatomic, strong) NSArray <ThingSmartDeviceModel *>*deviceArr;

@property(strong, nonatomic) ThingSmartHomeManager *homeManager;
@property(strong, nonatomic) NSMutableArray<ThingSmartHomeModel *> *homeList;
@property(strong, nonatomic) ThingSmartHome *currentHome;

@property (nonatomic, strong) NSMutableArray <NSString *> *titles;
@property (nonatomic, strong) NSMutableArray <NSURL *> *imageURLs;
@property (nonatomic, strong) JXPageListView *pageListView;
@property (nonatomic, strong) NSMutableArray <HomeExploreToysView *> *listViewArray;

@property(strong, nonatomic) NSMutableArray<HomeDollModel *> *diyDollList;
@property(strong, nonatomic) NSMutableArray<FindDollModel *> *exploreDollList;
@property (nonatomic, strong) NSMutableArray <BannerModel *> *bannerImgArray;
@property (nonatomic, copy) NSString *lastHardwareCode;//最新一次toyID
@property (nonatomic, copy) NSString *homeDisplayMode; // 首页显示模式控制，从propValue获取
//播放器
@property (nonatomic, strong) AudioPlayerView *currentAudioPlayer;

@end

@implementation HomeViewController

-(NSMutableArray *)listViewArray{
    if (!_listViewArray) {
        _listViewArray = [NSMutableArray array];
    }
    return _listViewArray;
}

-(NSMutableArray *)titles{
    if (!_titles) {
        _titles = [NSMutableArray array];
    }
    return _titles;
}

-(NSMutableArray *)imageURLs{
    if (!_imageURLs) {
        _imageURLs = [NSMutableArray array];
    }
    return _imageURLs;
}

-(NSMutableArray *)bannerImgArray{
    if (!_bannerImgArray) {
        _bannerImgArray = [NSMutableArray array];
    }
    return _bannerImgArray;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getData];
    [self becomeFirstResponder];// 激活第一响应者
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HomeDeviceRefresh" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hj_NavIsHidden = YES;
    self.view.backgroundColor = tableBgColor;
    self.topView.hidden = YES;
    self.titleLabel.text = NSLocalizedString(@"小朋友，你好！", @"");
    
    // 添加缓存支持
    [self setupDataCache];
    
    //家庭业务包实现 ThingFamilyProtocol 协议以提供服务，为了触发thing_custom_config.json这个配置文件
    [[ThingSmartBizCore sharedInstance] registerService:@protocol(ThingFamilyProtocol) withInstance:self];
    NSString *currentHomeId = [CoreArchive strForKey:KCURRENT_HOME_ID];
    if(![PublicObj isEmptyObject:currentHomeId]){
        self.currentHome = [ThingSmartHome homeWithHomeId:[currentHomeId longLongValue]];
        self.currentHome.delegate = self;
        [self updateCurrentFamilyProtocol];
    }

    [self setUpUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceSortChanged:) name:@"HomeDeviceRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(auditionClick:) name:@"auditionNotification" object:nil];
}

- (void)setupDataCache {
    // 先从缓存加载数据，提供即时显示（仅首次加载时）
    [self loadCachedDataIfNeeded];
}

//更新ThingFamilyProtocol 协议
-(void)updateCurrentFamilyProtocol{
    id<ThingFamilyProtocol> familyProtocol = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingFamilyProtocol)];
    [familyProtocol updateCurrentFamilyId:self.currentHome.homeId];
}

//ThingFamilyProtocol 协议
- (void)gotoFamilyManagement {
    id<ThingFamilyProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingFamilyProtocol)];
    [impl gotoFamilyManagement];
}


-(void)setUpUI{
    self.pageListView = [[JXPageListView alloc] initWithDelegate:self];
    //Tips:pinCategoryViewHeight要赋值
    self.pageListView.pinCategoryViewHeight = JXPageheightForHeaderInSection;
    //Tips:操作pinCategoryView进行配置
//    self.pageListView.pinCategoryView.titles = self.titles;
    self.pageListView.pinCategoryView.titleColor = UIColorFromRGBA(000000, 0.6);
    self.pageListView.pinCategoryView.averageCellSpacingEnabled = NO;
    self.pageListView.pinCategoryView.titleFont = [ATFontManager systemFontOfSize:12];
    self.pageListView.pinCategoryView.titleSelectedColor = mainColor;
    self.pageListView.pinCategoryView.titleSelectedFont = [ATFontManager boldFontWithSize:14];;
    self.pageListView.pinCategoryView.cellWidth = 85;
    self.pageListView.pinCategoryView.cellSpacing = 10;
    self.pageListView.pinCategoryView.titleLabelZoomScrollGradientEnabled = NO;
    //指示器
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.lineStyle = JXCategoryIndicatorLineStyle_Normal;
    lineView.scrollEnabled = NO;
    lineView.indicatorWidth = 20;
    lineView.indicatorColor = mainColor;
    self.pageListView.pinCategoryView.indicators = @[lineView];
    
    //Tips:成为mainTableView dataSource和delegate的代理，像普通UITableView一样使用它
    self.pageListView.mainTableView.dataSource = self;
    self.pageListView.mainTableView.delegate = self;
    self.pageListView.mainTableView.scrollsToTop = NO;
    self.pageListView.mainTableView.backgroundColor = self.view.backgroundColor;
    self.pageListView.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.pageListView.mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.pageListView.mainTableView.tableHeaderView = [self setupHeaderView];
    [self.pageListView.mainTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HomeNoDeviceCell class]) bundle:nil] forCellReuseIdentifier:@"HomeNoDeviceCell"];
    [self.pageListView.mainTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HomeDeviceCell class]) bundle:nil] forCellReuseIdentifier:@"HomeDeviceCell"];
    [self.pageListView.mainTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HomeToysCell class]) bundle:nil] forCellReuseIdentifier:@"HomeToysCell"];
    
    self.pageListView.mainTableView.mj_header = [RYFGifHeader headerWithRefreshingBlock:^{
        [self getData];
    }];
    
//    self.pageListView.mainTableView.tabAnimated = [TABTableAnimated animatedWithCellClass:[QATabAnimationCell class] cellHeight:116];
    self.pageListView.mainTableView.tabAnimated = [TABTableAnimated animatedWithCellClassArray:@[[QATabAnimationCell class], [QATabAnimationTwoCell class],[QATabAnimationThreeCell class]]
                                 cellHeightArray:@[@(160),@(150), @(150), @(750)]
                              animatedCountArray:@[@1,@1,@1,@1]];
    [self.pageListView.mainTableView.tabAnimated addHeaderViewClass:[LineTableViewHeaderFooterView class] viewHeight:50 toSection:0];
    [self.pageListView.mainTableView.tabAnimated addHeaderViewClass:[LineTableViewHeaderFooterView class] viewHeight:50 toSection:1];
    [self.pageListView.mainTableView.tabAnimated addHeaderViewClass:[LineTableViewHeaderFooterView class] viewHeight:50 toSection:2];
    
    [self.pageListView.mainTableView tab_startAnimationWithCompletion:^{
        [self getData];
    }];
    [self.containerView addSubview:self.pageListView];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.pageListView.frame = self.containerView.bounds;
    [PublicObj makeCornerToView:self.pageListView withFrame:self.pageListView.bounds withRadius:32 position:1];
}

//banner
- (UIView *)setupHeaderView {
    CGFloat cycleScrollH = (kScreenWidth-30) *151/343.0;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, cycleScrollH + 30)];
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(15, 15, kScreenWidth-30, cycleScrollH) delegate:self placeholderImage:nil];
    [headerView addSubview:self.cycleScrollView];
//    self.cycleScrollView.localizationImageNamesGroup = @[@"home_banner", @"home_banner", @"home_banner", @"home_banner"];
    self.cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleToFill;
    self.cycleScrollView.autoScrollTimeInterval = 3;
    self.cycleScrollView.layer.cornerRadius = 20;
    self.cycleScrollView.layer.masksToBounds = YES;
    self.cycleScrollView.backgroundColor = UIColor.whiteColor;
    self.cycleScrollView.currentPageDotColor = UIColor.whiteColor;
    self.cycleScrollView.pageDotColor = UIColorFromRGBA(0xD8D8D8, 0.6);
    WEAK_SELF
    self.cycleScrollView.clickItemOperationBlock = ^(NSInteger currentIndex) {
        [weakSelf bannerImgClick:weakSelf.bannerImgArray[currentIndex]];
    };
    return headerView;
}

//轮播图跳转
-(void)bannerImgClick:(BannerModel *)model{
    // 调试：打印点击时的埋点状态
    NSLog(@"[HomeViewController] Banner点击 - 准备上报埋点");
    [[AnalyticsManager sharedManager] debugPrintAnalyticsStatus];

    // 埋点上报：点击运营banner
    [[AnalyticsManager sharedManager] reportClickBannerWithId:model.Id ?: @""
                                                          name:model.title ?: @""];

    if (!strIsEmpty(model.linkUrl) ){
        MyWebViewController* VC  = [[ MyWebViewController alloc] init];
        VC.mainUrl = model.linkUrl;
        VC.title = model.title;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

//请求数据（优化版本）
- (void)getData{
    WEAK_SELF
    
    // 异步加载用户权限，不阻塞主要数据加载
    [[AnalyticsManager sharedManager] loadUserPermissionsWithCompletion:^(BOOL success) {
        if (success) {
            NSLog(@"[HomeViewController] 用户权限加载成功");
        } else {
            NSLog(@"[HomeViewController] 用户权限加载失败，使用默认设置");
        }
        [[AnalyticsManager sharedManager] debugPrintAnalyticsStatus];
    }];
    
    // 优化：分别处理每个请求，不等待所有完成
    [self loadBannerData];
    [self loadDiyDollData];
    [self loadExploreDollData];
    [self loadDisplayModeConfig];
    [self loadHomeAndDeviceData];
}

#pragma mark - 数据缓存管理（简化版本）

// 从缓存加载数据（仅首次加载时显示）
- (void)loadCachedDataIfNeeded {
    // 简化的缓存逻辑：只在首次进入时显示缓存数据，避免与网络数据冲突
    
    // 加载缓存的轮播图数据
    NSData *cachedBannersData = [[NSUserDefaults standardUserDefaults] dataForKey:@"CachedHomeBanners"];
    if (cachedBannersData && self.bannerImgArray.count == 0) {
        NSError *error = nil;
        NSArray *cachedBanners = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSArray class] fromData:cachedBannersData error:&error];
        if (cachedBanners.count > 0 && !error) {
            self.bannerImgArray = [NSMutableArray arrayWithArray:[BannerModel mj_objectArrayWithKeyValuesArray:cachedBanners]];
            [self updateBannerUI];
        }
    }
    
    // 加载缓存的探索公仔数据
    NSData *cachedExploreDollsData = [[NSUserDefaults standardUserDefaults] dataForKey:@"CachedExploreDolls"];
    if (cachedExploreDollsData && self.exploreDollList.count == 0) {
        NSError *error = nil;
        NSArray *cachedExploreDolls = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSArray class] fromData:cachedExploreDollsData error:&error];
        if (cachedExploreDolls.count > 0 && !error) {
            self.exploreDollList = [NSMutableArray arrayWithArray:[FindDollModel mj_objectArrayWithKeyValuesArray:cachedExploreDolls]];
            [self updateExploreDollUI];
        }
    }
    
    // 加载缓存的公仔数据
    NSString *currentHomeId = [CoreArchive strForKey:KCURRENT_HOME_ID];
    if (currentHomeId && self.diyDollList.count == 0) {
        NSData *cachedDiyDollsData = [[NSUserDefaults standardUserDefaults] dataForKey:[NSString stringWithFormat:@"CachedDiyDolls_%@", currentHomeId]];
        if (cachedDiyDollsData) {
            NSError *error = nil;
            NSArray *cachedDiyDolls = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSArray class] fromData:cachedDiyDollsData error:&error];
            if (cachedDiyDolls.count > 0 && !error) {
                self.diyDollList = [NSMutableArray arrayWithArray:[HomeDollModel mj_objectArrayWithKeyValuesArray:cachedDiyDolls]];
                [self updateDiyDollUI];
            }
        }
    }
}

// 缓存轮播图数据
- (void)cacheBannerData {
    if (self.bannerImgArray.count > 0) {
        // 将模型数组转换为字典数组，然后缓存
        NSMutableArray *dataToCache = [NSMutableArray array];
        for (BannerModel *model in self.bannerImgArray) {
            NSDictionary *dict = [model mj_keyValues];
            if (dict) {
                [dataToCache addObject:dict];
            }
        }
        NSError *error = nil;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dataToCache requiringSecureCoding:NO error:&error];
        if (data && !error) {
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"CachedHomeBanners"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

// 缓存探索公仔数据
- (void)cacheExploreDollData {
    if (self.exploreDollList.count > 0) {
        // 将模型数组转换为字典数组，然后缓存
        NSMutableArray *dataToCache = [NSMutableArray array];
        for (FindDollModel *model in self.exploreDollList) {
            NSDictionary *dict = [model mj_keyValues];
            if (dict) {
                [dataToCache addObject:dict];
            }
        }
        NSError *error = nil;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dataToCache requiringSecureCoding:NO error:&error];
        if (data && !error) {
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"CachedExploreDolls"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

// 缓存我的公仔数据
- (void)cacheDiyDollData {
    NSString *currentHomeId = [CoreArchive strForKey:KCURRENT_HOME_ID];
    if (currentHomeId && self.diyDollList.count > 0) {
        // 将模型数组转换为字典数组，然后缓存
        NSMutableArray *dataToCache = [NSMutableArray array];
        for (HomeDollModel *model in self.diyDollList) {
            NSDictionary *dict = [model mj_keyValues];
            if (dict) {
                [dataToCache addObject:dict];
            }
        }
        NSError *error = nil;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dataToCache requiringSecureCoding:NO error:&error];
        if (data && !error) {
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"CachedDiyDolls_%@", currentHomeId]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark - 分别处理各个数据请求

// 分别处理各个数据请求
- (void)loadBannerData {
    WEAK_SELF
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"sort" forKey:@"sortField"];
    [param setObject:@(1) forKey:@"sortAsc"];
    
    [[APIManager shared] GET:[APIPortConfiguration getHomeBannerListUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        NSLog(@"轮播图数据请求成功");
        [weakSelf.bannerImgArray removeAllObjects];
        [weakSelf.bannerImgArray addObjectsFromArray:[BannerModel mj_objectArrayWithKeyValuesArray:data]];
        
        // 缓存数据
        [weakSelf cacheBannerData];
        
        // 立即更新轮播图部分UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateBannerUI];
        });
        
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        NSLog(@"轮播图请求失败: %@", msg);
        // 使用默认数据
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.bannerImgArray removeAllObjects];
            [weakSelf.bannerImgArray addObjectsFromArray:[weakSelf createDefaultBannerData]];
            [weakSelf updateBannerUI];
        });
    }];
}

- (void)loadDiyDollData {
    WEAK_SELF
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@(1) forKey:@"pageNo"];
    [param setObject:@(100) forKey:@"pageSize"];
    NSString *currentHomeId = [CoreArchive strForKey:KCURRENT_HOME_ID];
    if(![PublicObj isEmptyObject:currentHomeId]){
        [param setObject:currentHomeId forKey:@"ownerId"];
    }
    [param setObject:@"creative,ip" forKey:@"dollModelType"];
    
    [[APIManager shared] GET:[APIPortConfiguration getHomeDoolListUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        NSLog(@"创意公仔数据请求成功");
        NSArray *dataArr = @[];
        if ([data isKindOfClass:NSDictionary.class]) {
            if ([data[@"list"] isKindOfClass:NSArray.class]) {
                dataArr = (NSArray *)data[@"list"];
                weakSelf.diyDollList = [NSMutableArray arrayWithArray:[HomeDollModel mj_objectArrayWithKeyValuesArray:dataArr]];
            }
        }
        
        // 缓存数据
        [weakSelf cacheDiyDollData];
        
        // 立即更新我的公仔部分UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateDiyDollUI];
        });
        
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        NSLog(@"创意公仔请求失败: %@", msg);
    }];
}

- (void)loadExploreDollData {
    WEAK_SELF
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"explore" forKey:@"types"];
    [param setObject:@"auto" forKey:@"sortField"];
    
    [[APIManager shared] GET:[APIPortConfiguration getHomeExploreListUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        NSLog(@"探索公仔数据请求成功");
        NSArray *dataArr = @[];
        if ([data isKindOfClass:NSArray.class]) {
            dataArr = (NSArray *)data;
            weakSelf.exploreDollList = [NSMutableArray arrayWithArray:[FindDollModel mj_objectArrayWithKeyValuesArray:dataArr]];
        }
        
        // 缓存数据
        [weakSelf cacheExploreDollData];
        
        // 立即更新探索公仔部分UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateExploreDollUI];
        });
        
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        NSLog(@"探索公仔请求失败: %@", msg);
        // 使用默认数据
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.exploreDollList removeAllObjects];
            [weakSelf.exploreDollList addObjectsFromArray:[weakSelf createDefaultExploreDollData]];
            [weakSelf updateExploreDollUI];
        });
    }];
}

- (void)loadDisplayModeConfig {
    WEAK_SELF
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"2" forKey:@"propKey"];
    
    [[APIManager shared] GET:[APIPortConfiguration getAppPropertyByKeyUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        if ([data isKindOfClass:NSDictionary.class]) {
            AppSettingModel *model = [AppSettingModel mj_objectWithKeyValues:data];
            weakSelf.homeDisplayMode = model.propValue ?: @"0";
            NSLog(@"首页显示模式配置: propValue = %@", weakSelf.homeDisplayMode);
        } else {
            weakSelf.homeDisplayMode = @"0";
            NSLog(@"首页显示模式配置获取失败，使用默认值: 0");
        }
        
        // 根据配置更新数据显示
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleDisplayModeUpdate];
        });
        
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        weakSelf.homeDisplayMode = @"0";
        NSLog(@"首页显示模式配置请求失败: %@，使用默认值: 0", msg);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleDisplayModeUpdate];
        });
    }];
}

- (void)loadHomeAndDeviceData {
    WEAK_SELF
    [self.homeManager getHomeListWithSuccess:^(NSArray<ThingSmartHomeModel *> *homes) {
        NSLog(@"家庭列表数据请求成功");
        weakSelf.homeList = [homes mutableCopy];
        if(weakSelf.homeList.count > 0){
            if(!weakSelf.currentHome){
                weakSelf.currentHome = [ThingSmartHome homeWithHomeId:weakSelf.homeList[0].homeId];
                [CoreArchive setStr:[NSString stringWithFormat:@"%lld",(long long)weakSelf.homeList[0].homeId] key:KCURRENT_HOME_ID];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SwitchHome" object:@(weakSelf.currentHome.homeId)];
                weakSelf.currentHome.delegate = weakSelf;
                [weakSelf updateCurrentFamilyProtocol];
            }
            [weakSelf.currentHome getHomeDataWithSuccess:^(ThingSmartHomeModel *homeModel) {
                NSLog(@"家庭设备数据请求成功");
                if(weakSelf.currentHome){
                    weakSelf.deviceArr = [weakSelf.currentHome.deviceList sortedArrayUsingComparator:^NSComparisonResult(ThingSmartDeviceModel *obj1, ThingSmartDeviceModel *obj2) {
                        return obj1.homeDisplayOrder - obj2.homeDisplayOrder;
                    }];
                    
                    // 立即更新设备部分UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf updateDeviceUI];
                        [weakSelf finalizeDataLoading];
                    });
                }
            } failure:^(NSError *error) {
                NSLog(@"获取家庭数据失败: %@", error.localizedDescription);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf finalizeDataLoading];
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf finalizeDataLoading];
            });
        }
        
    } failure:^(NSError *error) {
        NSLog(@"获取家庭列表失败: %@", error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf finalizeDataLoading];
        });
    }];
}

#pragma mark - 分别更新各部分UI的方法

// 分别更新各部分UI的方法
- (void)updateBannerUI {
    if(self.bannerImgArray.count > 0){
        if(!self.cycleScrollView){
            self.pageListView.mainTableView.tableHeaderView = [self setupHeaderView];
        }
        NSMutableArray *imgUrlArr = [NSMutableArray array];
        for (BannerModel *model in self.bannerImgArray) {
            [imgUrlArr addObject:model.mediaUrl];
        }
        self.cycleScrollView.imageURLStringsGroup = imgUrlArr;
    }else{
        self.pageListView.mainTableView.tableHeaderView = [UIView new];
    }
}

- (void)updateDiyDollUI {
    // 处理我的公仔模块数据
    if(![PublicObj isEmptyObject:[CoreArchive strForKey:KCURRENT_HOME_ID]]){
        NSArray *tempArr = [NSArray arrayWithArray:self.diyDollList];
        for (HomeDollModel *model in tempArr) {
            if(self.currentHome.homeId != [model.ownerId longLongValue]){
                [self.diyDollList removeObject:model];
            }
        }
    }
    
    // 刷新我的公仔section
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:1];
    [self.pageListView.mainTableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
}

- (void)updateDeviceUI {
    // 刷新设备section
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:0];
    [self.pageListView.mainTableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
}

- (void)updateExploreDollUI {
    [self.titles removeAllObjects];
    [self.imageURLs removeAllObjects];
    [self.listViewArray removeAllObjects];
    
    for (FindDollModel *item in self.exploreDollList) {
        NSString *toysName = item.name;
        if(toysName.length >12){
            toysName = [NSString stringWithFormat:@"%@...",[item.name substringToIndex:12]];
        }
        [self.titles addObject:toysName];
        [self.imageURLs addObject:[NSURL URLWithString:item.coverImg]];
    }
    
    for (FindDollModel *item in self.exploreDollList) {
        HomeExploreToysView *exploreView = [[HomeExploreToysView alloc] init];
        exploreView.model = item;
        [self.listViewArray addObject:exploreView];
    }
    
    self.pageListView.pinCategoryView.imageURLs = self.imageURLs;
    self.pageListView.pinCategoryView.selectedImageURLs = self.imageURLs;
    self.pageListView.pinCategoryView.loadImageCallback = ^(UIImageView *imageView, NSURL *imageURL) {
        [imageView sd_setImageWithURL:imageURL];
    };
    
    NSMutableArray *imageTypesArr = [NSMutableArray array];
    for (NSObject *obj in self.imageURLs) {
        [imageTypesArr addObject:@(JXCategoryTitleImageType_TopImage)];
    }
    
    self.pageListView.pinCategoryView.titles = self.titles;
    self.pageListView.pinCategoryView.imageTypes = imageTypesArr;
    self.pageListView.pinCategoryView.imageNeedLayer = YES;
    self.pageListView.pinCategoryView.imageSize = CGSizeMake(64, 64);
    
    [self.pageListView reloadData];
}

- (void)handleDisplayModeUpdate {
    if ([self.homeDisplayMode isEqualToString:@"0"]) {
        NSLog(@"使用默认数据结构 (propValue=0)");
        // 使用默认数据
        [self.bannerImgArray removeAllObjects];
        [self.bannerImgArray addObjectsFromArray:[self createDefaultBannerData]];
        [self updateBannerUI];
        
        [self.exploreDollList removeAllObjects];
        [self.exploreDollList addObjectsFromArray:[self createDefaultExploreDollData]];
        [self updateExploreDollUI];
    }
    
    // 处理启动图控制
    [self handleSplashScreenControl];
}

- (void)finalizeDataLoading {
    // 结束刷新状态，显示界面
    [self.pageListView.mainTableView.mj_header endRefreshing];
    self.topView.hidden = NO;
    [self.pageListView.mainTableView tab_endAnimation];
}

//刷新家庭列表
-(void)reloadHomeListData{
    //涂鸦平台 家庭列表信息
    [self.homeManager getHomeListWithSuccess:^(NSArray<ThingSmartHomeModel *> *homes) {
        self.homeList = [homes mutableCopy];
        
    } failure:^(NSError *error) {
        
    }];
}

//刷新设备列表
- (void)reloadDeviceData:(BOOL)showHud{
    WEAK_SELF
    if(showHud){
        [self showHud];
    }
    [self.currentHome getHomeDataWithSuccess:^(ThingSmartHomeModel *homeModel) {
        if(showHud){
            [weakSelf hiddenHud];
        }
        if(weakSelf.currentHome){
//            weakSelf.deviceArr = weakSelf.currentHome.deviceList;
            weakSelf.deviceArr = [weakSelf.currentHome.deviceList sortedArrayUsingComparator:^NSComparisonResult(ThingSmartDeviceModel *obj1, ThingSmartDeviceModel *obj2) {
                return obj1.homeDisplayOrder - obj2.homeDisplayOrder; // 或者使用 [obj1.age compare:obj2.age] 如果你想要更复杂的比较逻辑（比如字符串比较）
            }];
            
            for (ThingSmartDeviceModel *item in weakSelf.deviceArr){
                NSLog(@"排序后的序号===%ld，名称:%@，devId:%@",(long)item.homeDisplayOrder,item.name,item.devId);
            }
            [weakSelf.pageListView.mainTableView reloadData];
//            [weakSelf.pageListView.mainTableView reloadSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }
    } failure:^(NSError *error) {
        [weakSelf hiddenHud];
    }];
}

//刷新公仔列表
-(void)reloadDollData{
    WEAK_SELF
    //首页创意公仔列表
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@(1) forKey:@"pageNo"];
    [param setObject:@(100) forKey:@"pageSize"];
    [param setObject:@"creative,ip" forKey:@"dollModelType"];
    [param setObject:[NSString stringWithFormat:@"%lld",(long long)self.currentHome.homeId] forKey:@"ownerId"];
//    [param setObject:@"auto" forKey:@"sortField"];
    [[APIManager shared] GET:[APIPortConfiguration getHomeDoolListUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {

        NSArray *dataArr = @[];
        if ([data isKindOfClass:NSDictionary.class]) {
            if ([data[@"list"] isKindOfClass:NSArray.class]) {
                dataArr = (NSArray *)data[@"list"];
            }
        }
        weakSelf.diyDollList = [NSMutableArray arrayWithArray:[HomeDollModel mj_objectArrayWithKeyValuesArray:dataArr]];
        [weakSelf.pageListView.mainTableView reloadData];
//        [weakSelf.pageListView.mainTableView reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
        
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        
    }];
}

//导航栏右侧按钮
- (IBAction)operationBtnClick:(id)sender {
    WEAK_SELF
    if (!self.menu) {
        self.menu = [[JHCustomMenu alloc] initWithDataArr:@[LocalString(@"添加设备") , LocalString(@"切换家庭")] origin:CGPointMake( kScreenWidth  - 144, StatusBar_Height + 50) width:134 rowHeight:45];
        _menu.delegate = self;
        _menu.dismiss = ^() {
            weakSelf.menu = nil;
        };
//        _menu.arrImgName = @[@"share_pop.png", @"complain_pop.png"];
        [self.view addSubview:_menu];
    } else {
        [_menu dismissWithCompletion:^(JHCustomMenu *object) {
            weakSelf.menu = nil;
        }];
    }
}

- (void)jhCustomMenu:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if(self.homeList.count == 0){
            [SVProgressHUD showErrorWithStatus:@"请先创建家庭"];
            return;
        }
        FindDeviceViewController *VC = [FindDeviceViewController new];
        VC.homeId = self.currentHome.homeId;
        [self.navigationController pushViewController:VC animated:YES];
    }else
    {
        WEAK_SELF
        SwitchFamailyVC *VC = [SwitchFamailyVC new];
        VC.homeList = self.homeList;
        VC.currentHome = self.currentHome;
        VC.sureBlock = ^(ThingSmartHomeModel * _Nonnull model) {
            if(model.dealStatus == 1){
                [weakSelf homeInviteAlert:model];
            }else{
                if(model.homeId == weakSelf.currentHome.homeId){
                    return;
                }
                weakSelf.currentHome = [ThingSmartHome homeWithHomeId:model.homeId];
                NSLog(@"当前房间ID：%lld",(long long)model.homeId);
                [CoreArchive setStr:[NSString stringWithFormat:@"%lld",(long long)model.homeId] key:KCURRENT_HOME_ID];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SwitchHome" object:@(model.homeId)];
                weakSelf.currentHome.delegate = weakSelf;
                [weakSelf updateCurrentFamilyProtocol];
                weakSelf.lastHardwareCode = nil;
                [weakSelf reloadDeviceData:YES];
                [weakSelf reloadDollData];
            }
        };
        VC.managerBlock = ^{
            FamailyManageVC *VC = [FamailyManageVC new];
            [weakSelf.navigationController pushViewController:VC animated:YES];
        };
        VC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:VC animated:NO completion:nil];
        
    }
    
}

#pragma mark - JXPageViewDelegate
//Tips:实现代理方法
- (NSArray<UIView<JXPageListViewListDelegate> *> *)listViewsInPageListView:(JXPageListView *)pageListView {
    return self.listViewArray;
}

- (void)pinCategoryView:(JXCategoryBaseView *)pinCategoryView didSelectedItemAtIndex:(NSInteger)index {
    self.navigationController.interactivePopGestureRecognizer.enabled = (index == 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //Tips:需要传入mainTableView的scrollViewDidScroll事件
    [self.pageListView mainTableViewDidScroll:scrollView];
    if (scrollView.contentOffset.y > 32) {
        [PublicObj makeCornerToView:self.pageListView withFrame:self.pageListView.bounds withRadius:0 position:1];
    }else {
        [PublicObj makeCornerToView:self.pageListView withFrame:self.pageListView.bounds withRadius:32 position:1];
    }
}


#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2 + 1; //底部的分类滚动视图需要作为最后一个section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WEAK_SELF
    if (indexPath.section == 0) {
        if(self.deviceArr.count>0){
            HomeDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeDeviceCell" forIndexPath:indexPath];
            cell.deviceList = self.deviceArr;
            cell.itemClickBlock = ^(NSInteger index) {
                // 埋点上报：我的设备点击
                [[AnalyticsManager sharedManager] reportMyDeviceClickWithDeviceId:weakSelf.deviceArr[index].devId pid:weakSelf.deviceArr[index].productId];

                // 跳转小程序
                NSLog(@"deviceId:%@,token:%@",weakSelf.deviceArr[index].devId,kMyUser.accessToken);
                [[ThingMiniAppClient coreClient] openMiniAppByUrl:@"godzilla://ty7y8au1b7tamhvzij/pages/main/index" params:@{@"deviceId":weakSelf.deviceArr[index].devId,@"BearerId":(kMyUser.accessToken?:@""),@"langType":@"en"}];
            };
            cell.manageBlock = ^{
                HomeDeviceListVC *VC = [HomeDeviceListVC new];
                VC.home = weakSelf.currentHome;
//                VC.deviceArr = weakSelf.deviceArr;
                VC.isEdit = YES;
                [weakSelf.navigationController pushViewController:VC animated:YES];
            };
            return cell;
        }else{
            HomeNoDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeNoDeviceCell" forIndexPath:indexPath];
            cell.type = indexPath.section;
            cell.addBtnClickBlock = ^{
                FindDeviceViewController *VC = [FindDeviceViewController new];
                VC.homeId = weakSelf.currentHome.homeId;
                [weakSelf.navigationController pushViewController:VC animated:YES];
            };
            return cell;
        }
        
    }else if (indexPath.section == 1) {
        if(self.diyDollList.count == 0){
            HomeNoDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeNoDeviceCell" forIndexPath:indexPath];
            cell.type = indexPath.section;
            cell.addBtnClickBlock = ^{
                [weakSelf toysGuide];
            };
            return cell;
        }else{
            HomeToysCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeToysCell" forIndexPath:indexPath];
            cell.dataArr = self.diyDollList;
            cell.itemClickBlock = ^(NSInteger index) {
                // 埋点上报：我的公仔点击
                HomeDollModel *dollModel = weakSelf.diyDollList[index];
                [[AnalyticsManager sharedManager] reportMyDollClickWithId:dollModel.dollModelId ?: @""
                                                                     name:dollModel.dollModel.name ?: @""];
                

                NSLog(@"deviceId:%@,token:%@",weakSelf.diyDollList[index].Id,kMyUser.accessToken);
                // 跳转小程序
                NSString *currentHomeId = [CoreArchive strForKey:KCURRENT_HOME_ID];
                [[ThingMiniAppClient coreClient] openMiniAppByUrl:@"godzilla://ty7y8au1b7tamhvzij/pages/doll-detail/index" params:@{@"dollId":weakSelf.diyDollList[index].Id,@"BearerId":(kMyUser.accessToken?:@""),@"homeId":(currentHomeId?:@""),@"langType":@"en"}];
            };
            cell.manageBlock = ^{
                HomeToysListVC *VC = [HomeToysListVC new];
                VC.diyDollList = weakSelf.diyDollList;
                VC.isEdit = YES;
                [weakSelf.navigationController pushViewController:VC animated:YES];
            };
            return cell;
        }
        
    }else{
        return [self.pageListView listContainerCellForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.deviceArr.count > 0 ? 150 :270;
    }else if (indexPath.section == 1){
        return self.diyDollList.count > 0 ? 150 :270;
    }else{
        //Tips:最后一个section（即listContainerCell所在的section）返回listContainerCell的高度
//        return [self.pageListView listContainerCellHeight];
        return 470;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat headerH  = section==0? 50 : 40;
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, headerH)];
    headView.backgroundColor = tableBgColor;
    UILabel *titleLab = [UILabel new];
    titleLab.textColor = UIColorHex(131516);
    titleLab.font = [ATFontManager boldSystemFontOfSize:20];
    [headView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView).offset(15);
        make.centerY.equalTo(headView);
    }];
    if(section == 0){
        UIButton *addBtn= [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn setImage:QD_IMG(@"device_add") forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addDevice) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:addBtn];
        [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLab.mas_right).offset(0);
            make.top.bottom.equalTo(headView);
            make.width.mas_equalTo(40);
        }];
    }
    if(section == 1){
        UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [infoBtn setImage:QD_IMG(@"home_info") forState:UIControlStateNormal];
        [infoBtn addTarget:self action:@selector(toysGuide) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:infoBtn];
        [infoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLab.mas_right).offset(0);
            make.top.bottom.equalTo(headView);
            make.width.mas_equalTo(40);
        }];
    }
    
    if(section ==0 || section ==1){
        UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreBtn setTitle:NSLocalizedString(@"更多", @"")  forState:UIControlStateNormal];
        [moreBtn setImage:QD_IMG(@"home_section_more") forState:UIControlStateNormal];
        [moreBtn setTitleColor:UIColorHex(1DA9FF) forState:UIControlStateNormal];
        moreBtn.titleLabel.font = [ATFontManager systemFontOfSize:14];
        moreBtn.tag = section + 100;
        [moreBtn addTarget:self action:@selector(viewMore:) forControlEvents:UIControlEventTouchUpInside];
        [moreBtn layoutWithStyle:HKBtnImagePosition_Right space:15];
        [headView addSubview:moreBtn];
        [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(headView.mas_right).offset(-15);
            make.top.bottom.equalTo(headView);
            make.width.mas_equalTo(60);
        }];
        if(section ==0){
            moreBtn.hidden = self.deviceArr.count < 3;
        }else{
            moreBtn.hidden = self.diyDollList.count < 6;
        }
    }
    
    switch (section) {
        case 0:
            titleLab.text = NSLocalizedString(@"我的设备", @"");
            break;
        case 1:
            titleLab.text = NSLocalizedString(@"我的公仔", @"") ;
            break;
        case 2:
            titleLab.text = NSLocalizedString(@"探索公仔", @"") ;
            break;
        default:
            break;
    }
    
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section==0? 50 : 40;
}

//查看更多
-(void)viewMore:(UIButton *)btn{
    switch (btn.tag-100) {
        case 0:
        {
            HomeDeviceListVC *VC = [HomeDeviceListVC new];
            VC.home = self.currentHome;
//            VC.deviceArr = self.deviceArr;
            [self.navigationController pushViewController:VC animated:YES];
        }
           
            break;
        case 1:
        {
            HomeToysListVC *VC = [HomeToysListVC new];
            VC.diyDollList = self.diyDollList;
            [self.navigationController pushViewController:VC animated:YES];
        }
            
            break;
        default:
            break;
    }
}
//添加设备
-(void)addDevice{
    if(self.homeList.count == 0){
        [SVProgressHUD showErrorWithStatus:@"请先创建家庭"];
        return;
    }
    FindDeviceViewController *VC = [FindDeviceViewController new];
    VC.homeId = self.currentHome.homeId;
    [self.navigationController pushViewController:VC animated:YES];
}
//Toys引导
-(void)toysGuide{
    AddToysGuideVC *VC = [[AddToysGuideVC alloc] init];
    VC.sureBlock = ^{
        
    };
    VC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:VC animated:NO completion:nil];
    
}

//家庭邀请弹窗
-(void)homeInviteAlert:(ThingSmartHomeModel *)model{
    WEAK_SELF
    [LGBaseAlertView showAlertWithTitle:LocalString(@"加入家庭邀请") content:[NSString stringWithFormat:@"%@%@%@",LocalString(@"您有一个加入"),model.name,LocalString(@"家庭的邀请，是否同意加入？")] cancelBtnStr:LocalString(@"暂不加入") confirmBtnStr:LocalString(@"加入家庭") confirmBlock:^(BOOL isValue, id obj) {
        ThingSmartHome *home = [ThingSmartHome homeWithHomeId:model.homeId];
        if (isValue){
            [weakSelf showHud];
            ///接受邀请
            [home joinFamilyWithAccept:YES success:^(BOOL result) {
                [weakSelf hiddenHud];
                [SVProgressHUD showSuccessWithStatus:LocalString(@"已加入家庭")];
//                [weakSelf reloadHomeListData];
                [CoreArchive setStr:[NSString stringWithFormat:@"%lld",(long long)model.homeId] key:KCURRENT_HOME_ID];
                weakSelf.currentHome = home;
                weakSelf.currentHome.delegate = weakSelf;
                [weakSelf updateCurrentFamilyProtocol];
                [weakSelf reloadDeviceData:YES];
                [weakSelf reloadDollData];
                [weakSelf reloadHomeListData];
            } failure:^(NSError *error) {
                [weakSelf hiddenHud];
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }];
        }else{
            [home joinFamilyWithAccept:NO success:^(BOOL result) {
                
            } failure:^(NSError *error) {
                
            }];
        }
    }];
}

#pragma mark - ThingSmartHomeManagerDelegate

// 添加一个家庭
- (void)homeManager:(ThingSmartHomeManager *)manager didAddHome:(ThingSmartHomeModel *)homeModel {
    if(!kMyUser.accessToken){
        return;
    }
    if (homeModel.dealStatus <= ThingHomeStatusPending && homeModel.name.length > 0) {
        [self homeInviteAlert:homeModel];
    }else{
        [CoreArchive setStr:[NSString stringWithFormat:@"%lld",(long long)homeModel.homeId] key:KCURRENT_HOME_ID];
        self.currentHome = [ThingSmartHome homeWithHomeId:homeModel.homeId];
        self.currentHome.delegate = self;
        self.lastHardwareCode = nil;
        [self reloadDeviceData:YES];
        [self reloadDollData];
        [self reloadHomeListData];
    }
}

// 删除一个家庭
- (void)homeManager:(ThingSmartHomeManager *)manager didRemoveHome:(long long)homeId {
    if(!kMyUser.accessToken){
        return;
    }
    if(homeId == self.currentHome.homeId){
        if(self.homeList.count > 0){
            self.currentHome = [ThingSmartHome homeWithHomeId:self.homeList[0].homeId];
            self.currentHome.delegate = self;
            self.lastHardwareCode = nil;
            [CoreArchive setStr:[NSString stringWithFormat:@"%lld",(long long)self.currentHome.homeId] key:KCURRENT_HOME_ID];
            [self reloadDeviceData:YES];
            [self reloadDollData];
        }
        
    }
    [self reloadHomeListData];
}

// MQTT 连接成功
- (void)serviceConnectedSuccess {
    // 去云端查询当前家庭的详情，然后去刷新 UI
}

- (void)deviceSortChanged:(NSNotification *)notification {
    [self reloadDeviceData:YES];
}
-(void)auditionClick:(NSNotification *)notification{
    
    [self getDollDetailListWithId:notification.userInfo[@"DollId"]];
}
-(void)getDollDetailListWithId:(NSString * )Id{
    [SVProgressHUD showWithStatus:@"音频加载中...."];
    WEAK_SELF
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:Id forKey:@"dollModelId"];
    [[APIManager shared] GET:[APIPortConfiguration getdollListUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        [SVProgressHUD dismiss];
        if ([data isKindOfClass:NSArray.class]) {
//            contentUrl
            NSDictionary * dataDic = data[0];
            NSString *contentUrl = dataDic[@"contentUrl"];
            [weakSelf playNewAudioForAudioURL:contentUrl storyTitle:dataDic[@"contentText"] coverImageURL:dataDic[@"assetCoverImg"]];

        }
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        NSLog(@"%@",msg);
    }];
    
}
#pragma mark - ThingSmartHomeDelegate

// 家庭的信息更新，例如家庭 name 变化
- (void)homeDidUpdateInfo:(ThingSmartHome *)home {
    [self reloadHomeListData];
}



// 添加设备
- (void)home:(ThingSmartHome *)home didAddDeivice:(ThingSmartDeviceModel *)device {
    [self reloadDeviceData:NO];
}

// 删除设备
- (void)home:(ThingSmartHome *)home didRemoveDeivice:(NSString *)devId {
    [self reloadDeviceData:NO];
}

// 设备信息更新，例如设备 name 变化，在线状态变化
- (void)home:(ThingSmartHome *)home deviceInfoUpdate:(ThingSmartDeviceModel *)device {
    [self reloadDeviceData:NO];
}

// 家庭下设备的 dps 变化代理回调
- (void)home:(ThingSmartHome *)home device:(ThingSmartDeviceModel *)device dpsUpdate:(NSDictionary *)dps {
    if(!kMyUser.accessToken){
        return;
    }
    if (![PublicObj isEmptyObject:dps]) {
        //dp 4:充电状态 103：添加公仔
        if([[dps allKeys] containsObject:@"4"]){
            //刷新设备列表
            [self reloadDeviceData:NO];
        }
        NSString *hardwareCode = dps[@"103"];
        if(![PublicObj isEmptyObject:hardwareCode] && ![hardwareCode isEqualToString:self.lastHardwareCode] && [dps allKeys].count == 1){
            for (HomeDollModel *item in self.diyDollList) {
                if([item.hardwareCode isEqualToString:hardwareCode]){
                    return;
                }
            }
            self.lastHardwareCode = hardwareCode;
            WEAK_SELF
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:hardwareCode forKey:@"hardwareCode"];
            [[APIManager shared] GET:[APIPortConfiguration getDoolModelGetUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
                if ([data isKindOfClass:NSDictionary.class]) {
                    FindDollModel *model = [FindDollModel mj_objectWithKeyValues:data];
                    if([model.releaseStatus isEqualToString:@"released"]){
                        // 判断公仔ID第18位是否为"B"（创意公仔标识）
                        if (hardwareCode.length >= 18 && [hardwareCode characterAtIndex:17] == 'B') {
                            // 埋点上报：发现创意公仔
                            [[AnalyticsManager sharedManager] reportDiscoverCreativeDollWithId:model.Id ?: @""
                                                                                          name:model.name ?: @""];
                        }

                        // 显示公仔发现弹窗
                        ToysGuideFindVC *VC = [ToysGuideFindVC new];
                        VC.model = model;
                        VC.modalPresentationStyle = UIModalPresentationOverFullScreen;
                        [weakSelf presentViewController:VC animated:NO completion:nil];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            // 需要延迟执行的代码
                            [weakSelf reloadDollData];
                        });

                    }

                }
            } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {

            }];
        }
    }
}

#pragma mark - 摇晃手机
- (BOOL)canBecomeFirstResponder {
    return YES; // 必须重写此方法
}

//摇晃手机开始
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"摇动开始");
        // 触发单次震动
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

//摇晃手机结束
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        SwitchConfigViewController *VC = [SwitchConfigViewController new];
        [self.navigationController pushViewController:VC animated:YES];
//        //打开扫描二维码页面
//        WCQRCodeScanningVC *WBVC = [[WCQRCodeScanningVC alloc] init];
//        WBVC.scanResultBlock = ^(NSString *result) {
//            // 通过二维码打开小程序
//            [[ThingMiniAppClient coreClient] openMiniAppByQrcode:result params:@{@"BearerId":(kMyUser.accessToken?:@""),@"langType":@"en"}];
//        };
//        [self QRCodeScanVC:WBVC];
    }
}

- (void)QRCodeScanVC:(UIViewController *)scanVC {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.navigationController pushViewController:scanVC animated:YES];
                        });
                        NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                    } else {
                        NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                    }
                }];
                break;
            }
            case AVAuthorizationStatusAuthorized: {
                [self.navigationController pushViewController:scanVC animated:YES];
                break;
            }
            case AVAuthorizationStatusDenied: {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {

                }];

                [alertC addAction:alertA];
                [self presentViewController:alertC animated:YES completion:nil];
                break;
            }
            case AVAuthorizationStatusRestricted: {
                NSLog(@"因为系统原因, 无法访问相册");
                break;
            }

            default:
                break;
        }
        return;
    }

    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {

    }];

    [alertC addAction:alertA];
    [self presentViewController:alertC animated:YES completion:nil];
}


- (ThingSmartHomeManager *)homeManager {
    if (!_homeManager) {
        _homeManager = [[ThingSmartHomeManager alloc] init];
        _homeManager.delegate = self;
    }
    return _homeManager;
}

- (NSMutableArray<ThingSmartHomeModel *> *)homeList {
    if (!_homeList) {
        _homeList = [[NSMutableArray alloc] init];
    }
    return _homeList;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent; // 或UIStatusBarStyleDefault
}

#pragma mark - 默认数据创建方法

// 创建默认banner数据
- (NSArray<BannerModel *> *)createDefaultBannerData {
    BannerModel *defaultBanner = [[BannerModel alloc] init];
    defaultBanner.Id = @"15";
    defaultBanner.title = @"banner1";
    defaultBanner.positionCode = @"HOME_BANNER";
    defaultBanner.mediaUrl = @"https://app.talenpalussaastest.com/admin-api/infra/file/29/get/banner/20250829/8291755569649_.pic_副本_1756467884805.jpg";
    defaultBanner.linkUrl = @"";
    defaultBanner.linkParams = nil;

    return @[defaultBanner];
}

// 创建默认启动图数据
- (NSArray<BannerModel *> *)createDefaultSplashScreenData {
    BannerModel *defaultSplash = [[BannerModel alloc] init];
    defaultSplash.Id = @"21";
    defaultSplash.imageUrl = @"https://app.talenpalussaastest.com/admin-api/infra/file/29/get/splash-screen/20250905/20250905224021_5387_1757083264312.png";

    return @[defaultSplash];
}

// 创建默认探索公仔数据
- (NSArray<FindDollModel *> *)createDefaultExploreDollData {
    FindDollModel *defaultDoll = [[FindDollModel alloc] init];
    defaultDoll.Id = @"C008";
    defaultDoll.name = @"Little Lion";
    defaultDoll.type = @"explore";
    defaultDoll.family = @"狮子家族";
    defaultDoll.model = @"Lion001";
    defaultDoll.desc = @"He is cheerful and lively, and is the \"happy fruit\" in the lion group. He is full of energy every day, and uses his cheerful \"aow\" to convey happiness and is positive and optimistic.";
    defaultDoll.coverImg = @"https://app.talenpalussaastest.com/admin-api/infra/file/29/get/doll/20250829/WechatIMG937_1756486719169.png";
    defaultDoll.backgroundImg = @"https://app.talenpalussaastest.com/admin-api/infra/file/29/get/doll/20250829/WechatIMG931_1756486724296.png";
    defaultDoll.preview3d = nil;
    defaultDoll.releaseStatus = @"released";
    defaultDoll.grayConfig = @"";
    defaultDoll.createTime = @"1754124647000";
    defaultDoll.totalStoryNum = 1;
    defaultDoll.totalStoryDuration = 41;

    return @[defaultDoll];
}

// 处理启动图显示控制
- (void)handleSplashScreenControl {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"loading.png"];
    NSString *modelPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"adModel"];

    if ([self.homeDisplayMode isEqualToString:@"0"]) {
        NSLog(@"配置为使用默认启动图，更新缓存为默认启动图");
        // 使用默认启动图数据，更新缓存为默认启动图
        NSArray *defaultSplashData = [self createDefaultSplashScreenData];
        if (defaultSplashData.count > 0) {
            BannerModel *defaultSplash = defaultSplashData.firstObject;

            // 更新缓存模型文件
            NSError *error = nil;
            NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:defaultSplash requiringSecureCoding:NO error:&error];
            if (modelData && !error) {
                [modelData writeToFile:modelPath atomically:YES];
            }

            // 异步下载并缓存默认启动图，替换当前缓存
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (defaultSplash.imageUrl.length > 0) {
                    NSLog(@"🔄 开始下载默认启动图: %@", defaultSplash.imageUrl);
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:defaultSplash.imageUrl]];
                    if (data) {
                        UIImage *image = [UIImage imageWithData:data];
                        if (image) {
                            BOOL success = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
                            if (success) {
                                NSLog(@"✅ 默认启动图下载并缓存成功！");
                                NSLog(@"📁 缓存路径: %@", filePath);
                                NSLog(@"📏 图片尺寸: %.0f x %.0f", image.size.width, image.size.height);
                                NSLog(@"💾 文件大小: %.2f KB", (double)data.length / 1024.0);
                                NSLog(@"🎯 下次启动将显示默认启动图");
                            } else {
                                NSLog(@"❌ 默认启动图缓存写入失败");
                            }
                        } else {
                            NSLog(@"❌ 默认启动图数据转换为UIImage失败");
                        }
                    } else {
                        NSLog(@"❌ 默认启动图下载失败: %@", defaultSplash.imageUrl);
                    }
                } else {
                    NSLog(@"⚠️ 默认启动图URL为空，跳过下载");
                }
            });
        }
    } else {
        NSLog(@"配置为使用网络启动图 (propValue=%@)，更新缓存为网络启动图", self.homeDisplayMode);
        // 使用网络启动图，确保缓存为最新的网络启动图数据
        // 重新请求网络启动图数据并更新缓存
        NSLog(@"🌐 开始请求网络启动图数据...");
        WEAK_SELF
        [[APIManager shared] GET:[APIPortConfiguration getSplashScreenUrl] parameter:nil success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg)  {
            NSArray *dataArr = @[];
            if ([data isKindOfClass:NSArray.class]){
                dataArr = (NSArray *)data;
            }

            NSLog(@"📡 网络启动图API请求成功，返回数据数量: %lu", (unsigned long)dataArr.count);

            if (dataArr.count) {
                BannerModel *adModel = [BannerModel mj_objectWithKeyValues:[dataArr firstObject]];
                NSLog(@"📋 解析到网络启动图模型:");
                NSLog(@"   ID: %@", adModel.Id);
                NSLog(@"   图片URL: %@", adModel.imageUrl);
                NSLog(@"   跳转URL: %@", adModel.linkUrl ?: @"无");

                // 更新缓存模型文件
                NSError *modelError = nil;
                NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:adModel requiringSecureCoding:NO error:&modelError];
                BOOL modelSaved = NO;
                if (modelData && !modelError) {
                    modelSaved = [modelData writeToFile:modelPath atomically:YES];
                }
                NSLog(@"💾 网络启动图模型缓存%@: %@", modelSaved ? @"成功" : @"失败", modelPath);

                //异步下载并缓存网络启动图，替换当前缓存
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    if (adModel.imageUrl.length > 0) {
                        NSLog(@"🔄 开始下载网络启动图: %@", adModel.imageUrl);
                        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:adModel.imageUrl]];
                        if (data) {
                            UIImage *image = [UIImage imageWithData:data];
                            if (image) {
                                BOOL success = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
                                if (success) {
                                    NSLog(@"✅ 网络启动图下载并缓存成功！");
                                    NSLog(@"📁 缓存路径: %@", filePath);
                                    NSLog(@"📏 图片尺寸: %.0f x %.0f", image.size.width, image.size.height);
                                    NSLog(@"💾 文件大小: %.2f KB", (double)data.length / 1024.0);
                                    NSLog(@"🎯 下次启动将显示网络启动图");
                                } else {
                                    NSLog(@"❌ 网络启动图缓存写入失败");
                                }
                            } else {
                                NSLog(@"❌ 网络启动图数据转换为UIImage失败");
                            }
                        } else {
                            NSLog(@"❌ 网络启动图下载失败: %@", adModel.imageUrl);
                        }
                    } else {
                        NSLog(@"⚠️ 网络启动图URL为空，跳过下载");
                    }
                });
            } else {
                NSLog(@"⚠️ 网络启动图数据为空，保持当前缓存");
            }
        } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg){
            NSLog(@"❌ 网络启动图API请求失败: %@ (错误码: %ld)", msg, (long)error.code);
            NSLog(@"🔄 保持当前缓存不变");
        }];
    }
}

// 播放新的音频
- (void)playNewAudioForAudioURL:(NSString *)Url storyTitle:(NSString *)title coverImageURL:(NSString *)coverImageURL{
    NSLog(@"🎵 尝试播放音频 - 故事: %@, audioUrl: %@", title, Url);
    
    // 检查音频URL
    if (!Url || Url.length == 0) {
        NSLog(@"⚠️ 音频URL为空，无法播放");
        
        return;
    }
    if (self.currentAudioPlayer) {
        [self.currentAudioPlayer removeFromSuperview];
        [self.currentAudioPlayer  stop];
        self.currentAudioPlayer = nil;
    }
    // 创建新的音频播放器
    self.currentAudioPlayer = [[AudioPlayerView alloc] initWithAudioURL:Url storyTitle:title coverImageURL:coverImageURL];
    self.currentAudioPlayer.delegate = self;
    
    // 显示播放器并开始播放
    [self.currentAudioPlayer showInView:self.view];
    [self.currentAudioPlayer play];
    
    NSLog(@"✅ 开始播放音频: %@", Url);
}
- (void)audioPlayerDidStartPlaying {
    NSLog(@"▶️ 音频播放开始");
}

- (void)audioPlayerDidPause {
    NSLog(@"⏸️ 音频播放暂停");
    
}

- (void)audioPlayerDidFinish {
    NSLog(@"✅ 音频播放完成");
    [self.currentAudioPlayer removeFromSuperview];
    self.currentAudioPlayer = nil;
}

- (void)audioPlayerDidUpdateProgress:(CGFloat)progress currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    // 可以用来更新UI进度等
}

- (void)audioPlayerDidClose {
    NSLog(@"❌ 音频播放器关闭");

    self.currentAudioPlayer = nil;
}
@end
