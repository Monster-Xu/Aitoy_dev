//
//  CreationViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/1.
//  Updated: 2025/10/16 - 集成骨架屏加载效果
//

#import "CreationViewController.h"
#import "VoiceStoryTableViewCell.h"
#import "VoiceManagementViewController.h"
#import "VoiceStoryModel.h"
#import "AFStoryAPIManager.h"
#import "APIRequestModel.h"
#import "APIResponseModel.h"
#import "CreateStoryViewController.h"
#import "SkeletonTableViewCell.h"
#import "CreateStoryWithVoiceViewController.h"
#import "AudioPlayerView.h"

static NSString *const kNormalCellIdentifier = @"NormalCell";
static NSString *const kSkeletonCellIdentifier = @"SkeletonCell";

@interface CreationViewController ()<UITableViewDelegate, UITableViewDataSource, AudioPlayerViewDelegate>

@property (nonatomic, strong) UIView *customNavBarView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<VoiceStoryModel *> *dataSource;
@property (nonatomic, strong) UIView *emptyStateView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSURLSessionDataTask *currentLoadTask;
@property (nonatomic, strong) NSMutableArray<NSURLSessionDataTask *> *activeTasks;
@property (nonatomic, assign) BOOL isLoading; // ✅ 加载状态
@property (nonatomic, assign) NSInteger skeletonRowCount; // ✅ 骨架屏行数
// ⭐️ 明确标记：是否处于批量编辑模式
@property (nonatomic, assign) BOOL isBatchEditingMode;

@property (nonatomic, strong) UIView *editingToolbar;
@property (nonatomic, strong) UIButton *deleteSelectedButton;

// 音频播放器
@property (nonatomic, strong) AudioPlayerView *currentAudioPlayer;
@property (nonatomic, assign) NSInteger currentPlayingIndex; // 记录当前播放的故事索引

@end

@implementation CreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置整体背景色为 #F6F7FB
    self.view.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.activeTasks = [NSMutableArray array];
    self.dataSource = [NSMutableArray array];
    
    // 初始化为非批量编辑模式
    self.isBatchEditingMode = NO;
    
    // 初始化播放状态
    self.currentPlayingIndex = -1; // -1 表示没有正在播放的音频
    
    // ✅ 初始化骨架屏相关属性
    self.isLoading = NO;
    self.skeletonRowCount = 5;  // 显示5行骨架屏
    
    [self setupNavigationBar];
    [self setupUI];
    [self setupTableViewConstraints];
    [self loadDataWithSkeleton];
}

- (void)dealloc {
    // 清理音频播放器
    if (self.currentAudioPlayer) {
        [self.currentAudioPlayer hide];
        self.currentAudioPlayer = nil;
    }
    
    if (self.editingToolbar.superview) {
        [self.editingToolbar removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    // 确保 TabBar 正常显示
    if (self.tabBarController && !self.isBatchEditingMode) {
        self.tabBarController.tabBar.hidden = NO;
        self.tabBarController.tabBar.alpha = 1.0;
        self.tabBarController.tabBar.userInteractionEnabled = YES;
    }
    
    // 页面将要出现时刷新数据（考虑条件刷新以优化性能）
    static BOOL firstTimeAppear = YES;
    if (firstTimeAppear || self.dataSource.count == 0) {
        // 首次出现或数据为空时才刷新
        [self loadDataWithSkeleton];
        firstTimeAppear = NO;
    } else {
        // 非首次出现，进行轻量级刷新（不显示骨架屏）
        [self refreshDataWithoutSkeleton];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isBatchEditingMode) {
        [self cancelBatchEditingMode];
    }
    
    // 清理音频播放器
    if (self.currentAudioPlayer) {
        [self.currentAudioPlayer hide];
    }
    
    // ✅ 停止所有骨架屏动画
    for (SkeletonTableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[SkeletonTableViewCell class]]) {
            [cell stopSkeletonAnimation];
        }
    }
}

- (void)setupNavigationBar {
    self.title = @"";
    
    self.customNavBarView = [[UIView alloc] init];
    self.customNavBarView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.customNavBarView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Story Creation";
    titleLabel.font = [UIFont fontWithName:@"SFRounded-Bold" size:24] ?: [UIFont boldSystemFontOfSize:24];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.customNavBarView addSubview:titleLabel];
    
    UIButton *soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [soundButton setImage:[UIImage imageNamed:@"create_voice"] forState:UIControlStateNormal];
    soundButton.tintColor = [UIColor systemGrayColor];
    [soundButton addTarget:self action:@selector(soundButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addSubview:soundButton];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:[UIImage imageNamed:@"create_add"] forState:UIControlStateNormal];
    addButton.tintColor = [UIColor systemGrayColor];
    [addButton addTarget:self action:@selector(addButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addSubview:addButton];
    
    [self.customNavBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.height.mas_equalTo(44);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.customNavBarView).offset(16);
        make.centerY.equalTo(self.customNavBarView);
    }];
    
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.customNavBarView).offset(-16);
        make.centerY.equalTo(self.customNavBarView);
        make.width.height.mas_equalTo(28);
    }];
    
    [soundButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(addButton.mas_left).offset(-21);
        make.centerY.equalTo(self.customNavBarView);
        make.width.height.mas_equalTo(28);
    }];
}

- (void)setupUI {
    // TableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 设置 tableView 背景色为透明，显示父视图的背景色
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.hidden = YES;
    
    // 配置多选编辑
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    [self.tableView registerClass:[VoiceStoryTableViewCell class] forCellReuseIdentifier:@"VoiceStoryTableViewCell"];
    // ✅ 注册骨架屏 Cell
    [self.tableView registerClass:[SkeletonTableViewCell class] forCellReuseIdentifier:kSkeletonCellIdentifier];
    
    // 长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:longPress];
    self.tableView.mj_header = [RYFGifHeader headerWithRefreshingBlock:^{
        [self refreshDataWithSkeleton];
    }];
    
    [self.view addSubview:self.tableView];
    
    [self setupEditingToolbar];
    [self setupEmptyStateView];
}

- (void)setupTableViewConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.customNavBarView.mas_bottom).offset(10);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
}

- (void)setupEmptyStateView {
    self.emptyStateView = [[UIView alloc] init];
    // 设置空状态视图背景色与整体背景色一致
    self.emptyStateView.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    self.emptyStateView.hidden = YES;
    [self.view addSubview:self.emptyStateView];
    
    UIImageView *emptyImageView = [[UIImageView alloc] init];
    emptyImageView.contentMode = UIViewContentModeScaleAspectFit;
    emptyImageView.tintColor = [UIColor colorWithWhite:0.85 alpha:1];
    emptyImageView.image = [UIImage imageNamed:@"create_empty"];
    [self.emptyStateView addSubview:emptyImageView];
    
    UILabel *emptyLabel = [[UILabel alloc] init];
    emptyLabel.text = @"暂无故事，请先创建";
    emptyLabel.font = [UIFont systemFontOfSize:16];
    emptyLabel.textColor = [UIColor systemGrayColor];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self.emptyStateView addSubview:emptyLabel];
    
    UIButton *guideButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [guideButton setTitle:@"View the Guide" forState:UIControlStateNormal];
    // 链接样式：更小的字体，下划线效果
    guideButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [guideButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [guideButton setTitleColor:[UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:0.6] forState:UIControlStateHighlighted];
    
    // 添加下划线效果，让它看起来更像链接
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] 
        initWithString:@"View the Guide" 
        attributes:@{
            NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
            NSForegroundColorAttributeName: [UIColor systemBlueColor],
            NSFontAttributeName: [UIFont systemFontOfSize:14]
        }];
    [guideButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    
    // 高亮状态的下划线效果
    NSAttributedString *highlightedTitle = [[NSAttributedString alloc] 
        initWithString:@"View the Guide" 
        attributes:@{
            NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
            NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:0.6],
            NSFontAttributeName: [UIFont systemFontOfSize:14]
        }];
    [guideButton setAttributedTitle:highlightedTitle forState:UIControlStateHighlighted];
    
    [guideButton addTarget:self action:@selector(viewGuideButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.emptyStateView addSubview:guideButton];
    
    UIButton *emptyMyVoiceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [emptyMyVoiceButton setTitle:@"My Voice" forState:UIControlStateNormal];
    [emptyMyVoiceButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    emptyMyVoiceButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    emptyMyVoiceButton.layer.borderColor = [UIColor systemBlueColor].CGColor;
    emptyMyVoiceButton.layer.borderWidth = 1.5;
    emptyMyVoiceButton.layer.cornerRadius = 18;
    emptyMyVoiceButton.backgroundColor = [UIColor whiteColor];
    [emptyMyVoiceButton addTarget:self action:@selector(myVoiceButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.emptyStateView addSubview:emptyMyVoiceButton];
    
    UIButton *emptyCreateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [emptyCreateButton setTitle:@"Create Story" forState:UIControlStateNormal];
    [emptyCreateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    emptyCreateButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    emptyCreateButton.backgroundColor = [UIColor systemBlueColor];
    emptyCreateButton.layer.cornerRadius = 18;
    [emptyCreateButton addTarget:self action:@selector(createButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.emptyStateView addSubview:emptyCreateButton];
    
    [self.emptyStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.customNavBarView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    
    [emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.emptyStateView);
        make.centerY.equalTo(self.emptyStateView).offset(-80);
        make.width.height.mas_equalTo(120);
    }];
    
    [emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(emptyImageView.mas_bottom).offset(24);
        make.centerX.equalTo(self.emptyStateView);
        make.left.greaterThanOrEqualTo(self.emptyStateView).offset(16);
        make.right.lessThanOrEqualTo(self.emptyStateView).offset(-16);
    }];
    
    [guideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(emptyLabel.mas_bottom).offset(16);
        make.centerX.equalTo(self.emptyStateView);
    }];
    
    [emptyMyVoiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.emptyStateView).multipliedBy(0.7);
        make.top.equalTo(guideButton.mas_bottom).offset(32);
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat myVoiceWidth = screenWidth <= 320 ? 70 : (screenWidth <= 375 ? 80 : (screenWidth <= 390 ? 85 : (screenWidth <= 414 ? 88 : 90)));
        make.width.mas_equalTo(myVoiceWidth);
        make.height.mas_equalTo(36);
    }];
    
    [emptyCreateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.emptyStateView).multipliedBy(1.3);
        make.top.equalTo(guideButton.mas_bottom).offset(32);
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat createStoryWidth = screenWidth <= 320 ? 100 : (screenWidth <= 375 ? 110 : (screenWidth <= 390 ? 115 : (screenWidth <= 414 ? 120 : 122)));
        make.width.mas_equalTo(createStoryWidth);
        make.height.mas_equalTo(36);
    }];
}

- (void)setupEditingToolbar {
    // 创建工具栏但不添加到视图
    self.editingToolbar = [[UIView alloc] init];
    self.editingToolbar.backgroundColor = [UIColor whiteColor];
    self.editingToolbar.hidden = YES;
    self.editingToolbar.userInteractionEnabled = YES;
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    topLine.translatesAutoresizingMaskIntoConstraints = NO;
    [self.editingToolbar addSubview:topLine];
    
    self.deleteSelectedButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.deleteSelectedButton setTitle:@"删除故事" forState:UIControlStateNormal];
    [self.deleteSelectedButton setTitle:@"删除故事" forState:UIControlStateDisabled];
    
    [self.deleteSelectedButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    [self.deleteSelectedButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateDisabled];
    
    self.deleteSelectedButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.deleteSelectedButton.layer.cornerRadius = 25;
    self.deleteSelectedButton.backgroundColor = [UIColor whiteColor];
    self.deleteSelectedButton.clipsToBounds = YES;
    self.deleteSelectedButton.enabled = NO;
    self.deleteSelectedButton.userInteractionEnabled = YES;
    
    [self.deleteSelectedButton addTarget:self action:@selector(deleteSelectedItems) forControlEvents:UIControlEventTouchUpInside];
    self.deleteSelectedButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.editingToolbar addSubview:self.deleteSelectedButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [topLine.topAnchor constraintEqualToAnchor:self.editingToolbar.topAnchor],
        [topLine.leadingAnchor constraintEqualToAnchor:self.editingToolbar.leadingAnchor],
        [topLine.trailingAnchor constraintEqualToAnchor:self.editingToolbar.trailingAnchor],
        [topLine.heightAnchor constraintEqualToConstant:0.5],
        
        [self.deleteSelectedButton.leadingAnchor constraintEqualToAnchor:self.editingToolbar.leadingAnchor constant:20],
        [self.deleteSelectedButton.trailingAnchor constraintEqualToAnchor:self.editingToolbar.trailingAnchor constant:-20],
        [self.deleteSelectedButton.topAnchor constraintEqualToAnchor:self.editingToolbar.topAnchor constant:15],
        [self.deleteSelectedButton.heightAnchor constraintEqualToConstant:50]
    ]];
    
    [self updateDeleteButtonState];
}

- (CGFloat)bottomSafeAreaInset {
    if (@available(iOS 11.0, *)) {
        UIView *parentView = self.tabBarController ? self.tabBarController.view : self.view;
        return parentView.safeAreaInsets.bottom;
    }
    return 0;
}

- (void)updateEmptyState {
    BOOL isEmpty = self.dataSource.count == 0;
    
    // 只有在不是加载状态时才更新空状态
    if (!self.isLoading) {
        self.emptyStateView.hidden = !isEmpty;
        self.tableView.hidden = isEmpty;
        
        if (isEmpty) {
            // 确保空状态视图在最前面
            [self.view bringSubviewToFront:self.emptyStateView];
        }
    }
    
    // ✅ 更新导航栏按钮状态
    [self updateNavigationButtonsState];
}

/// ✅ 更新导航栏按钮状态，当达到限制时显示不同状态
- (void)updateNavigationButtonsState {
    BOOL isAtLimit = self.dataSource.count >= 10;
    
    // 更新导航栏中的添加按钮状态
    for (UIView *subview in self.customNavBarView.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            
            // 检查是否是添加按钮（通过图片名称或目标动作判断）
            NSArray *targets = [button allTargets].allObjects;
            for (id target in targets) {
                if (target == self) {
                    NSArray *actions = [button actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];
                    if ([actions containsObject:@"addButtonTapped"]) {
                        // 这是添加按钮
                        if (isAtLimit) {
                            // 达到限制：半透明显示
                            button.alpha = 0.5;
                            button.tintColor = [UIColor systemGray3Color];
                        } else {
                            // 未达到限制：正常显示
                            button.alpha = 1.0;
                            button.tintColor = [UIColor systemGrayColor];
                        }
                        break;
                    }
                }
            }
        }
    }
    
    NSLog(@"📊 更新导航按钮状态 - 故事数量: %ld/10, 达到限制: %@", 
          (long)self.dataSource.count, isAtLimit ? @"是" : @"否");
}

#pragma mark - ✅ 数据加载（带骨架屏）

/// 加载故事列表，显示骨架屏加载效果
- (void)loadDataWithSkeleton {
    NSLog(@"[CreationVC] 开始加载数据，显示骨架屏...");
    
    // ✅ 显示骨架屏
    self.isLoading = YES;
    self.tableView.hidden = NO;
    self.emptyStateView.hidden = YES;
    [self.tableView reloadData];
    
    // 创建分页请求参数
    PageRequestModel *pageRequest = [[PageRequestModel alloc] initWithPageNum:1 pageSize:20];
    pageRequest.familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    
    // 发起网络请求
    __weak typeof(self) weakSelf = self;
    
    [[AFStoryAPIManager sharedManager] getStoriesWithPage:pageRequest success:^(StoryListResponseModel *response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"[CreationVC] 数据加载成功，共 %ld 条", (long)response.total);
        
        // ✅ 隐藏骨架屏
        strongSelf.isLoading = NO;
        
        // 更新数据源
        [strongSelf.dataSource removeAllObjects];
        [strongSelf.dataSource addObjectsFromArray:response.list];
        
        // 刷新 TableView，显示真实数据
        [strongSelf.tableView reloadData];
        [strongSelf updateEmptyState];
        
        NSLog(@"[CreationVC] TableView 已刷新，显示真实数据");
        
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"[CreationVC] 加载数据失败: %@", error.localizedDescription);
        
        // ✅ 隐藏骨架屏
        strongSelf.isLoading = NO;
        
        // 显示错误提示
        [strongSelf showErrorAlert:error.localizedDescription];
        
        strongSelf.currentLoadTask = nil;
        
        // 如果没有数据，显示空状态
        [strongSelf updateEmptyState];
    }];
}

/// 下拉刷新，显示骨架屏加载效果
- (void)refreshDataWithSkeleton {
    NSLog(@"[CreationVC] 开始下拉刷新...");
    
    // ✅ 显示骨架屏
    self.isLoading = YES;
    [self.tableView reloadData];
    
    // 创建分页请求参数
    PageRequestModel *pageRequest = [[PageRequestModel alloc] initWithPageNum:1 pageSize:20];
    
    // 发起网络请求
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] getStoriesWithPage:pageRequest success:^(StoryListResponseModel *response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"[CreationVC] 刷新数据成功，共 %ld 条", (long)response.total);
        
        // ✅ 隐藏骨架屏
        strongSelf.isLoading = NO;
        
        // 更新数据源
        [strongSelf.dataSource removeAllObjects];
        [strongSelf.dataSource addObjectsFromArray:response.list];
        
        // 刷新 TableView，显示真实数据
        [strongSelf.tableView reloadData];
        [strongSelf updateEmptyState];
        
        // 结束刷新动画
        [strongSelf endRefreshingWithSuccess];
        
        strongSelf.currentLoadTask = nil;
        
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"[CreationVC] 刷新数据失败: %@", error.localizedDescription);
        
        // ✅ 隐藏骨架屏
        strongSelf.isLoading = NO;
        
        // 结束刷新动画
        [strongSelf endRefreshingWithSuccess];
        
        // 显示错误提示
        [strongSelf showErrorAlert:error.localizedDescription];
        
        // 如果没有数据，显示空状态
        [strongSelf updateEmptyState];
        
        strongSelf.currentLoadTask = nil;
    }];
}

/// 轻量级刷新，不显示骨架屏
- (void)refreshDataWithoutSkeleton {
    NSLog(@"[CreationVC] 开始轻量级刷新...");
    
    // 创建分页请求参数
    PageRequestModel *pageRequest = [[PageRequestModel alloc] initWithPageNum:1 pageSize:20];
    pageRequest.familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    
    // 发起网络请求
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] getStoriesWithPage:pageRequest success:^(StoryListResponseModel *response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"[CreationVC] 轻量级刷新数据成功，共 %ld 条", (long)response.total);
        
        // 更新数据源
        [strongSelf.dataSource removeAllObjects];
        [strongSelf.dataSource addObjectsFromArray:response.list];
        
        // 刷新 TableView，显示真实数据
        [strongSelf.tableView reloadData];
        [strongSelf updateEmptyState];
        
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"[CreationVC] 轻量级刷新数据失败: %@", error.localizedDescription);
        
        // 静默处理错误，不显示提示
        // 如果没有数据，显示空状态
        [strongSelf updateEmptyState];
    }];
}

- (void)endRefreshingWithSuccess {
    if (self.tableView.mj_header.isRefreshing) {
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"下拉刷新"
                                                                    attributes:@{
            NSForegroundColorAttributeName: [UIColor systemGrayColor],
            NSFontAttributeName: [UIFont systemFontOfSize:14]
        }];
//        self.tableView.mj_header.lastUpdatedTimeLabel. = title;
        
        [self.tableView.mj_header endRefreshing];
    }
}

#pragma mark - UITableView DataSource

/// ✅ 加载中显示骨架屏行数，加载完成显示真实数据行数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isLoading) {
        return self.skeletonRowCount;
    }
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // ✅ 加载中返回骨架屏 Cell
    if (self.isLoading) {
        SkeletonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSkeletonCellIdentifier forIndexPath:indexPath];
        
        // 配置骨架屏样式（带头像样式）
        [cell configureWithStyle:SkeletonCellStyleWithAvatar];
        
        // 开始骨架屏动画
        [cell startSkeletonAnimation];
        
        return cell;
    }
    
    // ✅ 数据加载完成返回真实 Cell
    VoiceStoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoiceStoryTableViewCell" forIndexPath:indexPath];
    
    // ⭐️ 关键：设置 cell 的批量编辑标记
    cell.isBatchEditingMode = self.isBatchEditingMode;
    
    // ✅ 使用 section 而不是 row
    cell.model = self.dataSource[indexPath.section];
    
    __weak typeof(self) weakSelf = self;
    
    // 编辑按钮点击事件 - 根据 storyStatus 跳转到不同的控制器
    cell.settingsButtonTapped = ^{
        [weakSelf handleEditButtonTappedAtIndex:indexPath.section];
    };
    
    cell.playButtonTapped = ^{
        [weakSelf playStoryAtIndex:indexPath.section];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isLoading) {
        // 骨架屏的高度可以根据样式调整
        return 76;
    } else {
        // ✅ 使用 section 而不是 row
        VoiceStoryModel *model = self.dataSource[indexPath.section];
        
        // 如果是生成中、音频生成中或失败状态，需要额外的空间显示状态提示
        if (model.storyStatus == 1 || model.storyStatus == 3 || model.storyStatus == 4) {
            return 108; // 卡片内容高度，无上下边距
        }
        
        // 正常状态
        return 88; // 卡片内容高度，无上下边距
    }
}

// ✅ 添加：section 之间的间距（通过 footer 实现）
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 10 : 5; // 第一个 section 顶部间距大一些
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.isLoading) {
        return; // 加载期间不响应点击
    }
    
    if (self.isBatchEditingMode) {
        [self updateDeleteButtonState];
    } else {
        // 根据 storyStatus 跳转到不同的控制器
        [self handleCellTappedAtIndex:indexPath.section];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isBatchEditingMode) {
        [self updateDeleteButtonState];
    }
}

#pragma mark - UITableView Editing Style

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isBatchEditingMode) {
        // 批量编辑模式：返回 None，显示多选框
        return UITableViewCellEditingStyleNone;
    } else {
        // 左滑删除：显示删除按钮
        return UITableViewCellEditingStyleDelete;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - UITableView Swipe to Delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // ✅ 加载中不允许编辑
    if (self.isLoading) {
        return NO;
    }
    return YES;
}

// 左滑删除时阻止批量编辑模式
- (BOOL)tableView:(UITableView *)tableView shouldBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    // 在批量编辑模式下，不允许左滑删除
    if (self.isBatchEditingMode) {
        return NO;
    }
    return YES;
}

// 自定义左滑删除按钮（iOS 11+）
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 加载中不显示删除操作
    if (self.isLoading) {
        return nil;
    }
    
    // 创建删除操作
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                               title:nil
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self deleteStoryAtIndex:indexPath.section];
        completionHandler(YES);
    }];
    
    // 设置自定义图片 create_delete
    deleteAction.image = [UIImage imageNamed:@"create_delete"];
    
    // 设置背景色为 #EA0000，透明度 10%
    deleteAction.backgroundColor = [UIColor colorWithRed:0xEA/255.0
                                                   green:0x00/255.0
                                                    blue:0x00/255.0
                                                   alpha:0.1];
    
    // 创建配置
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    
    // 设置是否需要完全滑动才能触发（YES = 完全滑动才能触发）
    configuration.performsFirstActionWithFullSwipe = YES;
    
    return configuration;
}

// 保留此方法作为iOS 11以下的兼容
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteStoryAtIndex:indexPath.section];
    }
}

#pragma mark - Batch Editing Mode

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        // 检查是否有 cell 正在左滑删除状态，如果有则阻止进入批量编辑
        if ([self isAnyRowInSwipeDeleteState]) {
            NSLog(@"⚠️ 检测到左滑删除状态，阻止进入批量编辑模式");
            return;
        }
        
        // 加载中不允许长按进入编辑模式
        if (self.isLoading) {
            NSLog(@"⚠️ 正在加载数据，不允许进入编辑模式");
            return;
        }
        
        // 如果数据源为空，不允许进入编辑模式
        if (self.dataSource.count == 0) {
            NSLog(@"⚠️ 数据源为空，不允许进入编辑模式");
            return;
        }
        
        CGPoint location = [gesture locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        
        if (indexPath && !self.isBatchEditingMode) {
            NSLog(@"✅ 长按触发批量编辑模式，索引: %ld", (long)indexPath.section);
            
            // 提供触觉反馈
            if (@available(iOS 10.0, *)) {
                UIImpactFeedbackGenerator *feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
                [feedbackGenerator prepare];
                [feedbackGenerator impactOccurred];
            }
            
            // 进入批量编辑模式
            [self enterBatchEditingMode];
            
            // 自动选中长按的项目
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self updateDeleteButtonState];
            
            NSLog(@"✅ 批量编辑模式已激活，已选中第 %ld 个项目", (long)indexPath.section);
        }
    }
}

// 检查是否有 cell 在左滑删除状态
- (BOOL)isAnyRowInSwipeDeleteState {
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        VoiceStoryTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if ([cell isKindOfClass:[VoiceStoryTableViewCell class]]) {
            // 如果 cell 正在编辑状态，但不是批量编辑模式，说明是左滑删除
            if (cell.isEditing && !cell.isBatchEditingMode) {
                return YES;
            }
        }
    }
    
    return NO;
}

// 进入批量编辑模式
- (void)enterBatchEditingMode {
    NSLog(@"🔵 === 进入批量编辑模式 ===");
    
    // 停止当前音频播放
    if (self.currentAudioPlayer) {
        [self.currentAudioPlayer hide];
        [self updatePlayingStateForStory:self.currentPlayingIndex isPlaying:NO];
        self.currentPlayingIndex = -1;
        self.currentAudioPlayer = nil;
    }
    
    // 1. 设置标记
    self.isBatchEditingMode = YES;
    
    // 2. TableView 进入编辑模式
    [self.tableView setEditing:YES animated:YES];
    
    // 3. 隐藏 TabBar
    if (self.tabBarController) {
        [UIView animateWithDuration:0.25 animations:^{
            self.tabBarController.tabBar.alpha = 0;
        } completion:^(BOOL finished) {
            self.tabBarController.tabBar.hidden = YES;
            self.tabBarController.tabBar.userInteractionEnabled = NO;
        }];
    }
    
    // 4. 更新导航栏
    [self updateCustomNavBarForEditingMode:YES];
    
    // 5. 添加并显示工具栏
    [self showEditingToolbar];
    
    // 6. 刷新所有可见 cells，确保它们知道当前是批量编辑模式
    [self reloadVisibleCellsEditingState];
    
    NSLog(@"✅ 批量编辑模式激活完成");
}

// 显示编辑工具栏
- (void)showEditingToolbar {
    UIView *parentView = self.tabBarController ? self.tabBarController.view : self.view;
    
    if (self.editingToolbar.superview == nil) {
        [parentView addSubview:self.editingToolbar];
        
        self.editingToolbar.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.editingToolbar.leadingAnchor constraintEqualToAnchor:parentView.leadingAnchor],
            [self.editingToolbar.trailingAnchor constraintEqualToAnchor:parentView.trailingAnchor],
            [self.editingToolbar.bottomAnchor constraintEqualToAnchor:parentView.bottomAnchor],
            [self.editingToolbar.heightAnchor constraintEqualToConstant:80 + [self bottomSafeAreaInset]]
        ]];
    }
    
    self.editingToolbar.hidden = NO;
    self.editingToolbar.alpha = 0;
    self.editingToolbar.userInteractionEnabled = YES;
    
    // 强制布局
    [self.editingToolbar setNeedsLayout];
    [self.editingToolbar layoutIfNeeded];
    [parentView setNeedsLayout];
    [parentView layoutIfNeeded];
    
    // 更新 TableView 约束
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-80 - [self bottomSafeAreaInset]);
    }];
    
    // 动画显示
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.editingToolbar.alpha = 1.0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.editingToolbar.userInteractionEnabled = YES;
        self.deleteSelectedButton.userInteractionEnabled = YES;
    }];
}

// 退出批量编辑模式
- (void)cancelBatchEditingMode {
    NSLog(@"🔴 === 退出批量编辑模式 ===");
    
    // 1. 清除标记
    self.isBatchEditingMode = NO;
    
    // 2. TableView 退出编辑模式
    [self.tableView setEditing:NO animated:YES];
    
    // 3. 更新导航栏
    [self updateCustomNavBarForEditingMode:NO];
    
    // 4. 恢复 TableView 约束
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    
    // 5. 隐藏工具栏
    [self hideEditingToolbar];
    
    // 6. 重置按钮状态
    self.deleteSelectedButton.enabled = NO;
    [self updateDeleteButtonState];
    
    // 7. 刷新所有可见 cells，确保它们知道已退出批量编辑模式
    [self reloadVisibleCellsEditingState];
    
    NSLog(@"✅ 批量编辑模式退出完成");
}

// 隐藏编辑工具栏
- (void)hideEditingToolbar {
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.editingToolbar.alpha = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.editingToolbar.hidden = YES;
        
        // 从视图移除
        [self.editingToolbar removeFromSuperview];
        
        // 恢复 TabBar
        if (self.tabBarController) {
            self.tabBarController.tabBar.hidden = NO;
            self.tabBarController.tabBar.userInteractionEnabled = YES;
            [UIView animateWithDuration:0.25 animations:^{
                self.tabBarController.tabBar.alpha = 1.0;
            }];
        }
    }];
}

// 刷新可见 cells 的编辑状态
- (void)reloadVisibleCellsEditingState {
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        VoiceStoryTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[VoiceStoryTableViewCell class]]) {
            // 更新 cell 的批量编辑标记
            cell.isBatchEditingMode = self.isBatchEditingMode;
            
            // 触发 setEditing 方法更新按钮状态
            [cell setEditing:cell.isEditing animated:YES];
        }
    }
}

- (void)updateCustomNavBarForEditingMode:(BOOL)isEditing {
    for (UIView *subview in self.customNavBarView.subviews) {
        [subview removeFromSuperview];
    }
    
    if (isEditing) {
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [cancelButton addTarget:self action:@selector(cancelBatchEditingMode) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBarView addSubview:cancelButton];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"故事删除";
        titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.customNavBarView addSubview:titleLabel];
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [doneButton addTarget:self action:@selector(cancelBatchEditingMode) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBarView addSubview:doneButton];
        
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.customNavBarView).offset(16);
            make.centerY.equalTo(self.customNavBarView);
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self.customNavBarView);
        }];
        
        [doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.customNavBarView).offset(-16);
            make.centerY.equalTo(self.customNavBarView);
        }];
        
    } else {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"Story Creation";
        titleLabel.font = [UIFont fontWithName:@"SFRounded-Bold" size:20] ?: [UIFont boldSystemFontOfSize:20];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.customNavBarView addSubview:titleLabel];
        
        UIButton *soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [soundButton setImage:[UIImage systemImageNamed:@"speaker.wave.2.fill"] forState:UIControlStateNormal];
        soundButton.tintColor = [UIColor systemGrayColor];
        [soundButton addTarget:self action:@selector(soundButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBarView addSubview:soundButton];
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setImage:[UIImage systemImageNamed:@"plus.circle.fill"] forState:UIControlStateNormal];
        addButton.tintColor = [UIColor systemGrayColor];
        [addButton addTarget:self action:@selector(addButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBarView addSubview:addButton];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.customNavBarView).offset(16);
            make.centerY.equalTo(self.customNavBarView);
        }];
        
        [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.customNavBarView).offset(-16);
            make.centerY.equalTo(self.customNavBarView);
            make.width.height.mas_equalTo(28);
        }];
        
        [soundButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(addButton.mas_left).offset(-21);
            make.centerY.equalTo(self.customNavBarView);
            make.width.height.mas_equalTo(28);
        }];
    }
}

- (void)updateDeleteButtonState {
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSInteger selectedCount = selectedRows.count;
    
    self.deleteSelectedButton.enabled = selectedCount > 0;
    
    if (selectedCount > 0) {
        NSString *buttonTitle = selectedCount == 1 ? @"删除故事" : [NSString stringWithFormat:@"删除 %ld 个故事", (long)selectedCount];
        [self.deleteSelectedButton setTitle:buttonTitle forState:UIControlStateNormal];
        [self.deleteSelectedButton setTitle:buttonTitle forState:UIControlStateDisabled];
        
        self.deleteSelectedButton.layer.borderColor = [UIColor systemRedColor].CGColor;
        self.deleteSelectedButton.layer.borderWidth = 1.5;
        self.deleteSelectedButton.backgroundColor = [UIColor whiteColor];
    } else {
        [self.deleteSelectedButton setTitle:@"删除故事" forState:UIControlStateNormal];
        [self.deleteSelectedButton setTitle:@"删除故事" forState:UIControlStateDisabled];
        
        self.deleteSelectedButton.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1].CGColor;
        self.deleteSelectedButton.layer.borderWidth = 1.5;
        self.deleteSelectedButton.backgroundColor = [UIColor whiteColor];
    }
}

- (void)deleteSelectedItems {
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    if (selectedIndexPaths.count == 0) {
        return;
    }
    
    NSString *message;
    if (selectedIndexPaths.count == 1) {
        NSIndexPath *indexPath = selectedIndexPaths.firstObject;
        VoiceStoryModel *model = self.dataSource[indexPath.section];
        message = [NSString stringWithFormat:@"确定要删除故事「%@」吗？", model.storyName ?: @"未命名故事"];
    } else {
        message = [NSString stringWithFormat:@"确定要删除选中的 %ld 个故事吗？", (long)selectedIndexPaths.count];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"删除"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self performBatchDelete:selectedIndexPaths];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)performBatchDelete:(NSArray<NSIndexPath *> *)indexPaths {
    NSLog(@"🗑️ 开始批量删除 %ld 个故事", (long)indexPaths.count);
    
    // 使用 section 排序，从大到小删除
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1, NSIndexPath *obj2) {
        return obj2.section - obj1.section;
    }];
    
    // 收集要删除的故事模型和ID
    NSMutableArray<VoiceStoryModel *> *modelsToDelete = [NSMutableArray array];
    NSMutableArray<NSNumber *> *idsToDelete = [NSMutableArray array];
    
    for (NSIndexPath *indexPath in sortedIndexPaths) {
        if (indexPath.section < self.dataSource.count) {
            VoiceStoryModel *model = self.dataSource[indexPath.section];
            [modelsToDelete addObject:model];
            [idsToDelete addObject:@(model.storyId)];
        }
    }
    
    // 如果有正在播放的音频，且要删除的项目中包含正在播放的，则停止播放
    if (self.currentPlayingIndex >= 0) {
        for (NSIndexPath *indexPath in indexPaths) {
            if (indexPath.section == self.currentPlayingIndex) {
                [self.currentAudioPlayer hide];
                self.currentPlayingIndex = -1;
                self.currentAudioPlayer = nil;
                break;
            }
        }
    }
    
    // 先从 UI 中移除
    for (NSIndexPath *indexPath in sortedIndexPaths) {
        if (indexPath.section < self.dataSource.count) {
            [self.dataSource removeObjectAtIndex:indexPath.section];
        }
    }
    
    // 删除 sections
    NSMutableIndexSet *sectionsToDelete = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in indexPaths) {
        [sectionsToDelete addIndex:indexPath.section];
    }
    [self.tableView deleteSections:sectionsToDelete withRowAnimation:UITableViewRowAnimationFade];
    
    // 退出批量编辑模式
    [self cancelBatchEditingMode];
    
    // 更新空状态
    [self updateEmptyState];
    
    // TODO: 这里应该调用后台删除 API
    // 可以考虑实现批量删除 API 或者逐个删除
    /*
    dispatch_group_t group = dispatch_group_create();
    __block NSInteger successCount = 0;
    __block NSInteger failureCount = 0;
    
    for (NSNumber *storyId in idsToDelete) {
        dispatch_group_enter(group);
        [[AFStoryAPIManager sharedManager] deleteStoryWithId:storyId.integerValue success:^(APIResponseModel * _Nonnull response) {
            successCount++;
            dispatch_group_leave(group);
        } failure:^(NSError * _Nonnull error) {
            failureCount++;
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (failureCount > 0) {
            NSString *message = [NSString stringWithFormat:@"删除完成，成功 %ld 个，失败 %ld 个", (long)successCount, (long)failureCount];
            [self showErrorAlert:message];
            // 如果有删除失败的，重新加载数据以确保数据一致性
            [self loadDataWithSkeleton];
        }
    });
    */
    
    NSLog(@"✅ 批量删除完成，共删除 %ld 个故事", (long)indexPaths.count);
}

#pragma mark - Story Navigation Methods

/// 处理编辑按钮点击事件 - 根据 storyStatus 跳转到不同的控制器
- (void)handleEditButtonTappedAtIndex:(NSInteger)index {
    if (index >= self.dataSource.count) {
        return;
    }
    
    VoiceStoryModel *model = self.dataSource[index];
    NSLog(@"编辑按钮点击 - 故事: %@, status: %ld", model.storyName, (long)model.storyStatus);
    
    [self navigateToEditControllerWithModel:model];
}

/// 处理 cell 点击事件 - 根据 storyStatus 跳转到不同的控制器
- (void)handleCellTappedAtIndex:(NSInteger)index {
    if (index >= self.dataSource.count) {
        return;
    }
    
    VoiceStoryModel *model = self.dataSource[index];
    NSLog(@"Cell 点击 - 故事: %@, status: %ld", model.storyName, (long)model.storyStatus);
    
    [self navigateToEditControllerWithModel:model];
}

/// 根据模型状态导航到对应的编辑控制器
- (void)navigateToEditControllerWithModel:(VoiceStoryModel *)model {
    switch (model.storyStatus) {
        case 2: // 跳转到 CreateStoryWithVoiceVC
        {
            CreateStoryWithVoiceViewController *voiceVC = [[CreateStoryWithVoiceViewController alloc] init];
            voiceVC.storyId = model.storyId;
            [self.navigationController pushViewController:voiceVC animated:YES];
            NSLog(@"✅ 跳转到 CreateStoryWithVoiceViewController，storyId: %ld", (long)model.storyId);
            break;
        }
        case 5: // 跳转到 CreateStoryWithVoiceVC（播放按钮可用）
        case 6: // 跳转到 CreateStoryWithVoiceVC（播放按钮不可用）
        {
            CreateStoryWithVoiceViewController *voiceVC = [[CreateStoryWithVoiceViewController alloc] init];
            voiceVC.storyId = model.storyId;
            voiceVC.isEditMode = YES;
            [self.navigationController pushViewController:voiceVC animated:YES];
            NSLog(@"✅ 跳转到 CreateStoryWithVoiceViewController，storyId: %ld", (long)model.storyId);
            break;
        }
        case 3: // 跳转到 CreateStoryVC，传递故事数据用于编辑
        {
            CreateStoryViewController *createVC = [[CreateStoryViewController alloc] init];
            // ✅ 传递故事模型数据，用于预填充表单
            createVC.storyModel = model;
            [self.navigationController pushViewController:createVC animated:YES];
            NSLog(@"✅ 跳转到 CreateStoryViewController（生成失败重新编辑），storyId: %ld", (long)model.storyId);
            break;
        }
        default:
            // 其他状态下编辑按钮不显示，理论上不会到这里
            NSLog(@"⚠️ 故事状态 %ld 不支持编辑", (long)model.storyStatus);
            break;
    }
}

#pragma mark - Actions

- (void)soundButtonTapped {
    NSLog(@"点击了声音按钮");
    VoiceManagementViewController *voiceVC = [[VoiceManagementViewController alloc] init];
    [self.navigationController pushViewController:voiceVC animated:YES];
}

- (void)addButtonTapped {
    NSLog(@"点击了添加按钮");
    [self createButtonTapped];
}

- (void)viewGuideButtonTapped {
    NSLog(@"点击了查看指南按钮");
    // TODO: 实现查看指南功能
    // 可以跳转到教程页面或显示使用说明
}

- (void)myVoiceButtonTapped {
    NSLog(@"点击了 My Voice 按钮");
    VoiceManagementViewController *voiceVC = [[VoiceManagementViewController alloc] init];
    [self.navigationController pushViewController:voiceVC animated:YES];
}

- (void)createButtonTapped {
    NSLog(@"点击了 Create Story 按钮");
    
    // 检查故事数量是否超过限制
    if (self.dataSource.count >= 10) {
        [self showStoryLimitAlert];
        return;
    }
    
    // 正常创建流程
    CreateStoryViewController *createStoryVC = [[CreateStoryViewController alloc] init];
    [self.navigationController pushViewController:createStoryVC animated:YES];
}

- (void)deleteStoryAtIndex:(NSInteger)index {
    if (index >= self.dataSource.count) {
        return;
    }
    
    VoiceStoryModel *model = self.dataSource[index];
    NSLog(@"点击删除第 %ld 个故事: %@", (long)index, model.storyName);
    
    NSString *message = [NSString stringWithFormat:@"确定要删除故事 %@ 吗？", model.storyName];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"删除"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self performSingleDelete:index];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)performSingleDelete:(NSInteger)index {
    VoiceStoryModel *model = self.dataSource[index];
    
    [[AFStoryAPIManager sharedManager] deleteStoryWithId:model.storyId success:^(APIResponseModel * _Nonnull response) {
        [self refreshDataWithSkeleton];
    } failure:^(NSError * _Nonnull error) {
        [self showErrorAlert:error.localizedDescription];
    }];
}

- (void)playStoryAtIndex:(NSInteger)index {
    VoiceStoryModel *model = self.dataSource[index];
    
    // 只有 status = 5 时播放按钮才可用
    if (model.storyStatus == 5) {
        NSLog(@"点击播放第 %ld 个故事: %@", (long)index, model.storyName);
        
        // 如果已有播放器在播放其他音频，先停止
        if (self.currentAudioPlayer && self.currentPlayingIndex != index) {
            [self.currentAudioPlayer hide];
            [self updatePlayingStateForStory:self.currentPlayingIndex isPlaying:NO];
        }
        
        // 如果点击的是当前正在播放的故事
        if (self.currentPlayingIndex == index && self.currentAudioPlayer) {
            if ([self.currentAudioPlayer isPlaying]) {
                // 当前正在播放，暂停
                [self.currentAudioPlayer pause];
                model.isPlaying = NO;
            } else {
                // 当前暂停，继续播放
                [self.currentAudioPlayer play];
                model.isPlaying = YES;
            }
        } else {
            // 播放新的音频
            [self playNewAudioForModel:model atIndex:index];
        }
        
        // 刷新对应的 cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    } else {
        NSLog(@"⚠️ 故事状态 %ld 不支持播放", (long)model.storyStatus);
    }
}

/// 播放新的音频
- (void)playNewAudioForModel:(VoiceStoryModel *)model atIndex:(NSInteger)index {
    NSLog(@"🎵 尝试播放音频 - 故事: %@, audioUrl: %@", model.storyName, model.audioUrl);
    
    // 检查音频URL
    if (!model.audioUrl || model.audioUrl.length == 0) {
        NSLog(@"⚠️ 音频URL为空，无法播放");
        
        return;
    }
    
    // 创建新的音频播放器
    self.currentAudioPlayer = [[AudioPlayerView alloc] initWithAudioURL:model.audioUrl storyTitle:model.storyName coverImageURL:model.illustrationUrl];
    self.currentAudioPlayer.delegate = self;
    
    // 显示播放器并开始播放
    [self.currentAudioPlayer showInView:self.view];
    [self.currentAudioPlayer play];
    
    // 更新状态
    self.currentPlayingIndex = index;
    model.isPlaying = YES;
    
    NSLog(@"✅ 开始播放音频: %@", model.audioUrl);
}

/// 更新指定故事的播放状态
- (void)updatePlayingStateForStory:(NSInteger)index isPlaying:(BOOL)isPlaying {
    if (index >= 0 && index < self.dataSource.count) {
        VoiceStoryModel *model = self.dataSource[index];
        model.isPlaying = isPlaying;
        
        // 刷新对应的 cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - AudioPlayerViewDelegate

- (void)audioPlayerDidStartPlaying {
    NSLog(@"🎵 音频开始播放");
    [self updatePlayingStateForStory:self.currentPlayingIndex isPlaying:YES];
}

- (void)audioPlayerDidPause {
    NSLog(@"⏸️ 音频暂停");
    [self updatePlayingStateForStory:self.currentPlayingIndex isPlaying:NO];
}

- (void)audioPlayerDidFinish {
    NSLog(@"🏁 音频播放完成");
    [self updatePlayingStateForStory:self.currentPlayingIndex isPlaying:NO];
    self.currentPlayingIndex = -1;
}

- (void)audioPlayerDidClose {
    NSLog(@"❌ 音频播放器关闭");
    [self updatePlayingStateForStory:self.currentPlayingIndex isPlaying:NO];
    self.currentPlayingIndex = -1;
    self.currentAudioPlayer = nil;
}

- (void)audioPlayerDidUpdateProgress:(CGFloat)progress currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    // 可以在这里更新其他UI，如通知栏进度等
    NSLog(@"🔄 播放进度: %.2f%%, 当前时间: %.1fs/%.1fs", progress * 100, currentTime, totalTime);
}

#pragma mark - Helper Methods

- (void)showStoryLimitAlert {
    NSString *title = @"故事数量已达上限";
    NSString *message = @"您最多只能创建10个故事。\n\n如需创建新故事，请先删除一些现有故事。";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"⚠️ 故事数量已达上限 (%ld/10)，显示限制提示", (long)self.dataSource.count);
}

- (void)showErrorAlert:(NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:errorMessage ?: @"网络请求失败，请稍后重试"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    });
}

@end
