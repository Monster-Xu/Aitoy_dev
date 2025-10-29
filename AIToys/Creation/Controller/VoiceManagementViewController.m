//
//  VoiceManagementViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//  Updated: 2025/10/16 - 集成骨架屏加载效果
//

#import "VoiceManagementViewController.h"
#import "VoiceManagementTableViewCell.h"
#import "SkeletonTableViewCell.h"
#import "CreateVoiceViewController.h"
#import "AFStoryAPIManager.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import <AVFoundation/AVFoundation.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface VoiceManagementViewController ()<UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIButton *createVoiceBtn;
@property (weak, nonatomic) IBOutlet UITableView *voiceListTabelView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
// 音频播放器（简单版本，不显示UI控件）
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) NSInteger currentPlayingIndex; // 记录当前播放的故事索引
@property (nonatomic, strong) VoiceModel *currentPlayingVoice; // 记录当前播放的音色

// ✅ 编辑模式相关属性
@property (nonatomic, assign) BOOL isEditingMode; // 是否处于编辑模式
@property (nonatomic, strong) NSMutableSet<NSNumber *> *selectedIndexes; // 选中的索引集合
@property (nonatomic, strong) UIBarButtonItem *editDoneButton; // 完成按钮
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture; // 长按手势

// ✅ 左滑删除状态
@property (nonatomic, assign) BOOL isSwipeDeleting; // 是否正在左滑删除
@property (nonatomic, assign) BOOL isRefresh; // 是否是下拉刷新

@end

@implementation VoiceManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ✅ 重要：禁用BaseViewController的导航栏颜色变更，避免冲突
    self.changeNavColor = NO;  // 我们自己管理导航栏样式
    
    // ✅ 配置导航栏 - 在BaseViewController基础上进行自定义
    [self setupNavigationBar];
    
    // ✅ 配置界面
    [self setupUI];
    
    // ✅ 配置表格
    [self setupTableView];
    
    // ✅ 配置手势 - 使用FD库的配置方式
    [self setupGestures];
    
    // ✅ 初始化数据
    [self initializeData];
    
    // ✅ 加载声音列表（显示骨架屏）
    [self loadVoiceListWithSkeleton];
}

#pragma mark - ✅ Setup Methods

/// 配置导航栏
- (void)setupNavigationBar {
    self.title = @"音色管理";
    
    // ✅ 重要：不要直接设置导航栏颜色，避免与BaseViewController冲突
    // BaseViewController会在viewWillAppear中设置基础的导航栏样式
    
    // ✅ 通过重写BaseViewController的配置来统一设置导航栏样式
    [self configureNavigationBarAppearance];
    
    // ✅ 如果需要自定义返回按钮样式，可以在这里做额外配置
    [self customizeBackButtonIfNeeded];
    
    NSLog(@"✅ 导航栏配置完成，继承自BaseViewController");
}

/// 配置导航栏外观，避免蓝色闪屏
- (void)configureNavigationBarAppearance {
    // ✅ 设置目标背景色
    UIColor *backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    
    // ✅ 使用iOS 13+的现代API统一设置外观
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = backgroundColor;
        appearance.shadowColor = [UIColor clearColor];
        
        // ✅ 设置标题样式
        appearance.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor blackColor]
        };
        
        // ✅ 重要：设置返回按钮样式，避免蓝色tintColor
        appearance.buttonAppearance.normal.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor blackColor]
        };
        
        // ✅ 重要：确保所有状态下的外观一致，避免闪屏
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.compactAppearance = appearance;
        
        if (@available(iOS 15.0, *)) {
            self.navigationController.navigationBar.compactScrollEdgeAppearance = appearance;
        }
        
        // ✅ 确保导航栏不透明，避免颜色混合
        self.navigationController.navigationBar.translucent = NO;
        
        // ✅ 重要：设置tintColor为非蓝色，避免闪屏
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        
    } else {
        // ✅ iOS 13以下的兼容处理
        [self.navigationController.navigationBar setBarTintColor:backgroundColor];
        [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
        [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
        self.navigationController.navigationBar.translucent = NO;
    }
    
    NSLog(@"✅ 导航栏外观已配置: %@", backgroundColor);
}

/// 如果需要，自定义返回按钮样式
- (void)customizeBackButtonIfNeeded {
    // ✅ 检查BaseViewController是否已经设置了返回按钮
    if (self.leftBarButton) {
        // BaseViewController已经设置了返回按钮，我们只需要确保图片正确
        UIImage *backImage = [[UIImage imageNamed:@"icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        if (backImage && [self.leftBarButton respondsToSelector:@selector(setImage:forState:)]) {
            [(UIButton *)self.leftBarButton setImage:backImage forState:UIControlStateNormal];
            
            // ✅ 确保按钮的tintColor不会影响图片显示
            if ([self.leftBarButton respondsToSelector:@selector(setTintColor:)]) {
                [(UIButton *)self.leftBarButton setTintColor:[UIColor clearColor]];
            }
        }
        NSLog(@"✅ 使用BaseViewController的返回按钮配置");
    } else {
        // ✅ 如果BaseViewController没有设置返回按钮，我们创建一个
        [self createCustomBackButton];
    }
}

/// 创建自定义返回按钮
- (void)createCustomBackButton {
    if (self.navigationController.viewControllers.count <= 1) {
        return; // 根控制器不需要返回按钮
    }
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [[UIImage imageNamed:@"icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    if (backImage) {
        [backButton setImage:backImage forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(customBackButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        // ✅ 设置按钮大小和内容模式
        backButton.frame = CGRectMake(0, 0, 44, 44);
        backButton.contentMode = UIViewContentModeCenter;
        
        // ✅ 确保按钮样式不受全局tintColor影响
        backButton.tintColor = [UIColor clearColor];
        
        // ✅ 创建UIBarButtonItem
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
        
        NSLog(@"✅ 自定义返回按钮创建成功");
    } else {
        NSLog(@"❌ 返回按钮图片 'icon_back' 不存在");
    }
}

/// 自定义返回按钮点击事件
- (void)customBackButtonTapped {
    NSLog(@"🔙 自定义返回按钮被点击");
    [self.navigationController popViewControllerAnimated:YES];
}

/// 配置界面
- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    [self.createVoiceBtn addTarget:self action:@selector(createVoiceBtnClick) forControlEvents:UIControlEventTouchDown];
    self.emptyView.hidden = YES;
}

/// 配置表格
- (void)setupTableView {
    self.voiceListTabelView.backgroundColor = [UIColor clearColor];
    self.voiceListTabelView.delegate = self;
    self.voiceListTabelView.dataSource = self;
    self.voiceListTabelView.mj_header = [RYFGifHeader headerWithRefreshingBlock:^{
        self.isRefresh = YES;
        [self loadVoiceListWithSkeleton];
    }];
    
    // ✅ 支持多选模式
    self.voiceListTabelView.allowsMultipleSelectionDuringEditing = YES;
    self.voiceListTabelView.allowsSelectionDuringEditing = YES;
    
    if (@available(iOS 15.0, *)) {
        self.voiceListTabelView.sectionHeaderTopPadding = 0;
    }
    
    // ✅ 注册真实数据Cell
    UINib *VoiceManagementTableViewCell = [UINib nibWithNibName:@"VoiceManagementTableViewCell" bundle:nil];
    [self.voiceListTabelView registerNib:VoiceManagementTableViewCell forCellReuseIdentifier:@"VoiceManagementTableViewCell"];
    
    // ✅ 注册骨架屏Cell
    [self.voiceListTabelView registerClass:[SkeletonTableViewCell class] forCellReuseIdentifier:@"SkeletonTableViewCell"];
    
    // ✅ 添加长按手势
    [self setupLongPressGesture];
}

/// 配置手势 - 使用FD库的方式
- (void)setupGestures {
    // ✅ 使用FD库来管理返回手势，避免冲突
    // 默认情况下FD库已经处理了全屏返回手势
    // 我们不需要自定义手势，只需要在特定情况下禁用即可
    self.fd_interactivePopDisabled = NO;
}

/// 初始化数据
- (void)initializeData {
    self.voiceList = [NSMutableArray array];
    self.isLoading = NO;
    self.skeletonRowCount = 5;  // 默认显示5行骨架屏
    self.currentPlayingIndex = -1; // 初始化为-1表示没有播放中的音色
    
    // ✅ 初始化编辑模式相关属性
    self.isEditingMode = NO;
    self.selectedIndexes = [NSMutableSet set];
    
    // ✅ 初始化左滑删除状态
    self.isSwipeDeleting = NO;
    
    // ✅ 初始化创建按钮状态
    [self updateCreateButtonState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // ✅ 重要：在viewWillAppear中确保导航栏样式正确
    // 这样可以防止从其他页面返回时出现闪屏
    [self configureNavigationBarAppearance];
    
    // ✅ 确保返回按钮配置正确
    [self customizeBackButtonIfNeeded];
    
    // 每次显示页面时刷新数据
    [self loadVoiceListWithSkeleton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // ✅ 页面完全显示后，确保手势状态正确
    [self updateGestureState];
    
    // ✅ 页面完全显示后，再次确认导航栏样式正确
    // 这是最后一道防线，确保不会有蓝色闪屏
    [self configureNavigationBarAppearance];
    
    // ✅ 检查返回按钮状态（防止BaseViewController配置被覆盖）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkBackButtonState];
    });
}

/// 更新手势状态
- (void)updateGestureState {
    // ✅ 检查是否在自定义编辑模式，如果是则暂时禁用返回手势
    if (self.isEditingMode) {
        self.fd_interactivePopDisabled = YES;
    } else {
        self.fd_interactivePopDisabled = NO;
    }
}


/// 检查返回按钮状态
- (void)checkBackButtonState {
    // ✅ 检查BaseViewController是否正确设置了返回按钮
    if (self.leftBarButton && self.navigationItem.leftBarButtonItem) {
        NSLog(@"✅ 返回按钮状态正常 (BaseViewController)");
        
        // ✅ 再次确认按钮图片是否正确
        if ([self.leftBarButton isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)self.leftBarButton;
            UIImage *currentImage = [button imageForState:UIControlStateNormal];
            if (!currentImage) {
                NSLog(@"⚠️ 返回按钮图片丢失，重新设置图片");
                UIImage *backImage = [[UIImage imageNamed:@"icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                [button setImage:backImage forState:UIControlStateNormal];
            }
        }
        
    } else {
        NSLog(@"⚠️ BaseViewController返回按钮有问题，尝试重新设置");
        
        // 先尝试BaseViewController的方法
        [self setupNavBackBtn];
        
        // 延迟检查，如果还是没有，使用备用方案
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.navigationItem.leftBarButtonItem) {
                NSLog(@"⚠️ BaseViewController方案失效，使用备用方案");
                [self setupFallbackBackButton];
            }
        });
    }
}

#pragma mark - ✅ 加载数据（带骨架屏效果）

/// 加载声音列表，显示骨架屏加载效果
- (void)loadVoiceListWithSkeleton {
    // 设置加载状态
    if (self.isRefresh) {
        self.isLoading = NO;
    }else{
        self.isLoading = YES;
    }
    
    self.emptyView.hidden = YES;
    
    // 刷新TableView，显示骨架屏
    [self.voiceListTabelView reloadData];
    
    NSLog(@"[VoiceManagement] 开始加载数据，显示骨架屏...");
    
    // 调用API获取声音列表
    [[AFStoryAPIManager sharedManager] getVoicesWithStatus:0 success:^(VoiceListResponseModel *response) {
        
        NSLog(@"[VoiceManagement] 数据加载成功，共 %ld 个音色", response.list.count);
        
        // 更新数据源
        if (response && response.list.count > 0) {
            self.voiceList = [NSMutableArray arrayWithArray:response.list];
            self.emptyView.hidden = YES;
        } else {
            self.voiceList = [NSMutableArray array];
            self.emptyView.hidden = NO;
        }
        
        // 结束加载状态
        self.isLoading = NO;
        [self.voiceListTabelView.mj_header endRefreshing];
        // 刷新TableView，显示真实数据
        [self.voiceListTabelView reloadData];
        
        // ✅ 如果处于编辑模式，需要重新更新所有cell的编辑模式状态
        if (self.isEditingMode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateAllVisibleCellsEditingMode];
            });
        }
        
        // ✅ 更新创建按钮状态
        [self updateCreateButtonState];
        
        NSLog(@"[VoiceManagement] TableView 已刷新，显示真实数据");
        
    } failure:^(NSError *error) {
        
        NSLog(@"[VoiceManagement] 加载数据失败: %@", error.localizedDescription);
        
        // 结束加载状态
        self.isLoading = NO;
        
        // 显示错误提示
        [self showErrorAlert:@"加载失败" message:error.localizedDescription];
        
        self.emptyView.hidden = NO;
        
        // ✅ 更新创建按钮状态
        [self updateCreateButtonState];
        
        // 刷新TableView
        [self.voiceListTabelView reloadData];
    }];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // ✅ 加载中时显示骨架屏行数，加载完成时显示真实数据行数
    if (self.isLoading) {
        return self.skeletonRowCount;
    }
    return MAX(1, self.voiceList.count);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // ✅ 加载中时返回骨架屏Cell
    if (self.isLoading) {
        SkeletonTableViewCell *skeletonCell = [tableView dequeueReusableCellWithIdentifier:@"SkeletonTableViewCell" forIndexPath:indexPath];
        
        // 配置骨架屏样式（带头像样式）
        [skeletonCell configureWithStyle:SkeletonCellStyleWithAvatar];
        
        // 开始骨架屏动画
        [skeletonCell startSkeletonAnimation];
        
        return skeletonCell;
    }
    
    // ✅ 数据加载完成后返回真实数据Cell
    VoiceManagementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoiceManagementTableViewCell" forIndexPath:indexPath];
    cell.playButtonTapped = ^(VoiceModel * _Nonnull voice) {
        [self handlePlayButtonTappedForVoice:voice atIndex:indexPath.section];
    };
    cell.editButtonTapped = ^(VoiceModel * _Nonnull voice) {
        [self handleEditVoice:voice];
    };
    
    // 绑定数据
    if (indexPath.section < self.voiceList.count) {
        VoiceModel *voice = self.voiceList[indexPath.section];
        [cell configureWithVoiceModel:voice];
        
        // ✅ 更新cell的编辑模式状态
        BOOL isSelected = [self.selectedIndexes containsObject:@(indexPath.section)];
        [cell updateEditingMode:self.isEditingMode isSelected:isSelected];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // ✅ 加载中时使用固定高度
    if (self.isLoading) {
        return 76;
    }
    
    // ✅ 根据音色状态动态调整高度
    if (indexPath.section < self.voiceList.count) {
        VoiceModel *voice = self.voiceList[indexPath.section];
        
        // 如果需要显示statusView，则高度增加35px
        if ([VoiceManagementTableViewCell needsStatusViewForVoice:voice]) {
            return 76 + 35; // 111px
        }
    }
    
    // 默认高度
    return 76;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 10 : 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 9;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"🖱️ Cell点击事件被触发 - section: %ld", (long)indexPath.section);
    
    // ✅ 加载中时不响应点击
    if (self.isLoading) {
        NSLog(@"⚠️ 加载中，忽略cell点击");
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    // ✅ 编辑模式下的选择逻辑
    if (self.isEditingMode) {
        // ✅ 检查当前项目是否已经被选中
        if ([self.selectedIndexes containsObject:@(indexPath.section)]) {
            // 如果已选中，则取消选中
            [self.selectedIndexes removeObject:@(indexPath.section)];
            [self updateNavigationTitle];
            [self updateDeleteButtonState];
            
            // ✅ 更新cell的选中状态
            VoiceManagementTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[VoiceManagementTableViewCell class]]) {
                [cell updateEditingMode:YES isSelected:NO];
            }
            
            NSLog(@"❌ 取消选中项目 - section: %ld, 总选中: %ld", (long)indexPath.section, (long)self.selectedIndexes.count);
        } else {
            // 如果未选中，则选中
            [self.selectedIndexes addObject:@(indexPath.section)];
            [self updateNavigationTitle];
            [self updateDeleteButtonState];
            
            // ✅ 更新cell的选中状态
            VoiceManagementTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[VoiceManagementTableViewCell class]]) {
                [cell updateEditingMode:YES isSelected:YES];
            }
            
            NSLog(@"✅ 选中项目 - section: %ld, 总选中: %ld", (long)indexPath.section, (long)self.selectedIndexes.count);
        }
        
        // ✅ 在自定义编辑模式下，总是取消系统的选中状态
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    // ✅ 正常模式下取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // ✅ 正常模式下的编辑逻辑
    if (indexPath.section < self.voiceList.count) {
        VoiceModel *voice = self.voiceList[indexPath.section];
        NSLog(@"🖊️ 准备编辑音色: %@", voice.voiceName);
        if (voice.cloneStatus != 1) {
            [self handleEditVoice:voice];
        }
    }
}

/// 处理编辑音色（cell点击和编辑按钮共用）
- (void)handleEditVoice:(VoiceModel *)voice {
    CreateVoiceViewController *vc = [[CreateVoiceViewController alloc] init];
    vc.isEditMode = YES;
    vc.editingVoice = voice;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate - 左滑删除

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // ✅ 加载中不允许删除
    if (self.isLoading) {
        return NO;
    }
    
    // ✅ 自定义编辑模式下不允许左滑删除
    if (self.isEditingMode) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteVoiceAtIndexPath:indexPath];
    }
}

/// 处理左滑删除操作
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    
    // ✅ 加载中不显示删除操作
    if (self.isLoading) {
        return nil;
    }
    
    // ✅ 自定义编辑模式下不显示左滑删除操作
    if (self.isEditingMode) {
        return nil;
    }
    
    // 自定义删除按钮
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                               title:nil
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self deleteVoiceAtIndexPath:indexPath];
        completionHandler(YES);
    }];
    
    deleteAction.backgroundColor = [UIColor colorWithRed:0xEA/255.0 green:0x00/255.0 blue:0x00/255.0 alpha:0.1];
    deleteAction.image = [UIImage imageNamed:@"create_delete"];
    
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    configuration.performsFirstActionWithFullSwipe = NO;
    
    return configuration;
}

/// 开始编辑时禁用返回手势
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"🔄 开始左滑删除编辑 - section: %ld", (long)indexPath.section);
    
    // ✅ 标记为正在左滑删除，禁用长按手势
    self.isSwipeDeleting = YES;
    
    // ✅ 开始编辑时禁用返回手势
    self.fd_interactivePopDisabled = YES;
}

/// 结束编辑时恢复返回手势
- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath {
    NSLog(@"✅ 结束左滑删除编辑 - section: %ld", indexPath ? (long)indexPath.section : -1);
    
    // ✅ 恢复左滑删除状态，允许长按手势
    self.isSwipeDeleting = NO;
    
    // ✅ 结束编辑时恢复返回手势（但要检查是否在自定义编辑模式）
    if (!self.isEditingMode) {
        self.fd_interactivePopDisabled = NO;
    }
}

#pragma mark - 音频播放处理

/// 处理播放按钮点击事件
- (void)handlePlayButtonTappedForVoice:(VoiceModel *)voice atIndex:(NSInteger)index {
    // 检查音频URL
    if (!voice.sampleAudioUrl || voice.sampleAudioUrl.length == 0) {
        NSLog(@"⚠️ 音频URL为空，无法播放");
        [self showErrorAlert:@"播放失败" message:@"该音色没有可播放的音频"];
        return;
    }
    
    // 如果当前音色正在播放，则暂停
    if (self.currentPlayingIndex == index && voice.isPlaying) {
        [self pauseCurrentAudio];
        return;
    }
    
    // 如果有其他音色在播放，先停止
    if (self.currentPlayingIndex != -1 && self.currentPlayingIndex != index) {
        [self stopCurrentAudio];
    }
    
    // 开始播放新的音频
    [self playAudioForVoice:voice atIndex:index];
}

/// 播放指定音色的音频
- (void)playAudioForVoice:(VoiceModel *)voice atIndex:(NSInteger)index {
    NSLog(@"🎵 开始播放音色: %@", voice.voiceName);
    
    // 显示音频加载进度弹窗
    [SVProgressHUD showWithStatus:@"音频加载中..."];
    
    // 从网络URL创建音频播放器
    NSURL *audioURL = [NSURL URLWithString:voice.sampleAudioUrl];
    
    // 异步加载音频数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        
        // 创建下载任务来显示进度
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:audioURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"❌ 音频下载失败: %@", error.localizedDescription);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [self showErrorAlert:@"播放失败" message:@"音频下载失败"];
                });
                return;
            }
            
            if (location) {
                NSData *audioData = [NSData dataWithContentsOfURL:location];
                
                if (audioData) {
                    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
                    
                    if (error) {
                        NSLog(@"❌ 音频播放器初始化失败: %@", error.localizedDescription);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                            [self showErrorAlert:@"播放失败" message:@"音频文件格式不支持"];
                        });
                        return;
                    }
                    
                    self.audioPlayer.delegate = self;
                    [self.audioPlayer prepareToPlay];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 隐藏加载进度
                        [SVProgressHUD dismiss];
                        
                        // 配置音频会话
                        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                        [[AVAudioSession sharedInstance] setActive:YES error:nil];
                        
                        // 开始播放
                        if ([self.audioPlayer play]) {
                            // 更新状态
                            self.currentPlayingIndex = index;
                            self.currentPlayingVoice = voice;
                            voice.isPlaying = YES;
                            
                            // 刷新cell显示
                            [self updatePlayingStateForVoice:voice atIndex:index isPlaying:YES];
                            
                            NSLog(@"✅ 音频开始播放成功");
                            
                            // 显示播放成功提示
                            [SVProgressHUD showSuccessWithStatus:@"开始播放"];
                            [SVProgressHUD dismissWithDelay:1.0];
                        } else {
                            NSLog(@"❌ 音频播放失败");
                            [self showErrorAlert:@"播放失败" message:@"无法播放该音频文件"];
                        }
                    });
                } else {
                    NSLog(@"❌ 音频数据读取失败");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        [self showErrorAlert:@"播放失败" message:@"音频数据读取失败"];
                    });
                }
            }
        }];
        
        [downloadTask resume];
    });
}

/// 暂停当前播放的音频
- (void)pauseCurrentAudio {
    if (self.audioPlayer && self.audioPlayer.isPlaying) {
        [self.audioPlayer pause];
        
        if (self.currentPlayingVoice) {
            self.currentPlayingVoice.isPlaying = NO;
            [self updatePlayingStateForVoice:self.currentPlayingVoice atIndex:self.currentPlayingIndex isPlaying:NO];
        }
        
        NSLog(@"⏸️ 音频已暂停");
    }
    
    // 确保隐藏任何显示中的进度条
    [SVProgressHUD dismiss];
}

/// 停止当前播放的音频
- (void)stopCurrentAudio {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        
        if (self.currentPlayingVoice) {
            self.currentPlayingVoice.isPlaying = NO;
            [self updatePlayingStateForVoice:self.currentPlayingVoice atIndex:self.currentPlayingIndex isPlaying:NO];
        }
        
        self.currentPlayingIndex = -1;
        self.currentPlayingVoice = nil;
        self.audioPlayer = nil;
        
        NSLog(@"⏹️ 音频已停止");
    }
    
    // 确保隐藏任何显示中的进度条
    [SVProgressHUD dismiss];
}

/// 更新指定音色的播放状态并刷新cell
- (void)updatePlayingStateForVoice:(VoiceModel *)voice atIndex:(NSInteger)index isPlaying:(BOOL)isPlaying {
    voice.isPlaying = isPlaying;
    
    // 直接更新可见cell的播放按钮状态，避免重新加载整个cell
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    if (indexPath.section < [self.voiceListTabelView numberOfSections]) {
        VoiceManagementTableViewCell *cell = [self.voiceListTabelView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[VoiceManagementTableViewCell class]]) {
            // ✅ 直接更新播放按钮的selected状态
            cell.playButton.selected = isPlaying;
            NSLog(@"🎵 播放按钮状态已更新: %@", isPlaying ? @"播放中" : @"已暂停");
        }
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"🏁 音频播放完成");
    
    // 隐藏进度条
    [SVProgressHUD dismiss];
    
    if (self.currentPlayingVoice) {
        self.currentPlayingVoice.isPlaying = NO;
        [self updatePlayingStateForVoice:self.currentPlayingVoice atIndex:self.currentPlayingIndex isPlaying:NO];
    }
    
    self.currentPlayingIndex = -1;
    self.currentPlayingVoice = nil;
    self.audioPlayer = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"❌ 音频解码错误: %@", error.localizedDescription);
    
    // 隐藏进度条
    [SVProgressHUD dismiss];
    
    if (self.currentPlayingVoice) {
        self.currentPlayingVoice.isPlaying = NO;
        [self updatePlayingStateForVoice:self.currentPlayingVoice atIndex:self.currentPlayingIndex isPlaying:NO];
    }
    
    self.currentPlayingIndex = -1;
    self.currentPlayingVoice = nil;
    self.audioPlayer = nil;
    
    [self showErrorAlert:@"播放出错" message:@"音频文件损坏或格式不支持"];
}

#pragma mark - 删除声音

/// 删除指定位置的声音
- (void)deleteVoiceAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.voiceList.count) {
        return;
    }
    
    VoiceModel *voice = self.voiceList[indexPath.section];
    
    // 检查是否可以删除
    if (!voice.canDelete) {
        [self showErrorAlert:@"删除失败" message:@"该音色已关联故事，无法删除"];
        return;
    }
    
    // 确认删除
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除音色"
                                                                             message:[NSString stringWithFormat:@"确定要删除音色 \"%@\" 吗？", voice.voiceName]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // 取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
        // 关闭左滑菜单
        [self.voiceListTabelView setEditing:NO animated:YES];
    }];
    
    // 删除按钮
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
        // 调用删除API
        [self performDeleteVoiceWithId:voice.voiceId atIndexPath:indexPath];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/// 执行API删除操作
- (void)performDeleteVoiceWithId:(NSInteger)voiceId atIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"[VoiceManagement] 删除音色 ID: %ld", (long)voiceId);
    
    [[AFStoryAPIManager sharedManager] deleteVoiceWithId:voiceId success:^(APIResponseModel *response) {
        
        NSLog(@"[VoiceManagement] 删除成功");
        
        // 从本地列表删除
        if (indexPath.section < self.voiceList.count) {
            [self.voiceList removeObjectAtIndex:indexPath.section];
        }
        
        // 刷新表格
        [self.voiceListTabelView beginUpdates];
        [self.voiceListTabelView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                              withRowAnimation:UITableViewRowAnimationFade];
        [self.voiceListTabelView endUpdates];
        
        // 如果没有数据了，显示空状态
        if (self.voiceList.count == 0) {
            self.emptyView.hidden = NO;
        }
        
        // ✅ 更新创建按钮状态
        [self updateCreateButtonState];
        
        // 显示成功提示
        [self showSuccessAlert:@"删除成功"];
        
    } failure:^(NSError *error) {
        
        NSLog(@"[VoiceManagement] 删除失败: %@", error.localizedDescription);
        
        // 显示错误提示
        [self showErrorAlert:@"删除失败" message:error.localizedDescription];
    }];
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // ✅ 重要：在离开页面时，恢复导航栏的默认样式
    // 这样其他页面就不会受到影响
    [self restoreDefaultNavigationBarAppearance];
    
    // 停止当前播放的音频
    [self stopCurrentAudio];
    
    // ✅ 重置左滑删除状态
    self.isSwipeDeleting = NO;
    
    // ✅ 停止所有骨架屏动画
    for (SkeletonTableViewCell *cell in self.voiceListTabelView.visibleCells) {
        if ([cell isKindOfClass:[SkeletonTableViewCell class]]) {
            [cell stopSkeletonAnimation];
        }
    }
    
    // ✅ 确保返回手势可用（用于下一个页面）
    self.fd_interactivePopDisabled = NO;
    self.isRefresh = NO;
}

/// 恢复默认的导航栏外观
- (void)restoreDefaultNavigationBarAppearance {
    // ✅ 恢复为默认的白色背景，避免影响其他页面
    UIColor *defaultBackgroundColor = [UIColor whiteColor];
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = defaultBackgroundColor;
        appearance.shadowColor = [UIColor clearColor];
        
        // ✅ 设置默认标题样式
        appearance.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor blackColor]
        };
        
        // ✅ 恢复默认的返回按钮样式
        appearance.buttonAppearance.normal.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor blackColor]
        };
        
        // ✅ 应用默认外观
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.compactAppearance = appearance;
        
        if (@available(iOS 15.0, *)) {
            self.navigationController.navigationBar.compactScrollEdgeAppearance = appearance;
        }
        
        // ✅ 恢复默认tintColor
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        
    } else {
        [self.navigationController.navigationBar setBarTintColor:defaultBackgroundColor];
        [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    }
    
    NSLog(@"✅ 导航栏外观已恢复为默认样式");
}

#pragma mark - 按钮事件

/// 更新创建按钮状态
- (void)updateCreateButtonState {
    NSInteger maxVoiceCount = 4;
    NSInteger currentCount = self.voiceList.count;
    
    if (currentCount >= maxVoiceCount) {
        // ✅ 达到最大数量时禁用按钮并改变样式
        self.createVoiceBtn.enabled = NO;
        self.createVoiceBtn.alpha = 0.5;
        [self.createVoiceBtn setTitle:[NSString stringWithFormat:@"已达上限 (%ld/%ld)", (long)currentCount, (long)maxVoiceCount] forState:UIControlStateNormal];
    } else {
        // ✅ 未达到最大数量时启用按钮
        self.createVoiceBtn.enabled = YES;
        self.createVoiceBtn.alpha = 1.0;
        [self.createVoiceBtn setTitle:[NSString stringWithFormat:@"创建音色 (%ld/%ld)", (long)currentCount, (long)maxVoiceCount] forState:UIControlStateNormal];
    }
    
    NSLog(@"[VoiceManagement] 创建按钮状态已更新: %ld/%ld", (long)currentCount, (long)maxVoiceCount);
}

-(void)createVoiceBtnClick{
    // ✅ 检查声音数量是否已达到最大限制
    NSInteger maxVoiceCount = 4;
    if (self.voiceList.count >= maxVoiceCount) {
        [self showErrorAlert:@"创建失败" message:[NSString stringWithFormat:@"最多只能创建%ld个音色，请删除一些音色后再试", (long)maxVoiceCount]];
        return;
    }
    
    CreateVoiceViewController *vc = [[CreateVoiceViewController alloc]init];
    vc.isEditMode = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 提示框

/// 显示成功提示
- (void)showSuccessAlert:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"成功"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/// 显示错误提示
- (void)showErrorAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 返回按钮备用方案

/// 备用返回按钮显示方案（当BaseViewController方案失效时使用）
- (void)setupFallbackBackButton {
    NSLog(@"🔧 启用备用返回按钮方案");
    
    // ✅ 只有当不是根控制器时才设置返回按钮
    if (self.navigationController.viewControllers.count <= 1) {
        return;
    }
    
    // ✅ 创建备用返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [[UIImage imageNamed:@"icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    if (backImage) {
        [backButton setImage:backImage forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(fallbackBackButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        // ✅ 设置按钮frame，确保点击区域足够
        backButton.frame = CGRectMake(0, 0, 44, 44);
        backButton.contentMode = UIViewContentModeCenter;
        
        // ✅ 使用UIBarButtonItem包装按钮
        UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        // ✅ 设置左侧导航项
        self.navigationItem.leftBarButtonItem = backBarButton;
        
        NSLog(@"✅ 备用返回按钮已设置");
    } else {
        NSLog(@"❌ 备用方案：返回按钮图片不存在，使用文字按钮");
        
        // ✅ 如果图片不存在，创建文字返回按钮
        UIBarButtonItem *textBackButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" 
                                                                           style:UIBarButtonItemStylePlain 
                                                                          target:self 
                                                                          action:@selector(fallbackBackButtonTapped)];
        self.navigationItem.leftBarButtonItem = textBackButton;
    }
}

/// 备用返回按钮点击事件
- (void)fallbackBackButtonTapped {
    NSLog(@"🔙 备用返回按钮被点击");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ✅ 长按手势设置

/// 设置长按手势
- (void)setupLongPressGesture {
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    self.longPressGesture.minimumPressDuration = 0.8; // 长按0.8秒触发
    [self.voiceListTabelView addGestureRecognizer:self.longPressGesture];
}

/// 处理长按手势
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // ✅ 加载中、已经在编辑模式或正在左滑删除时不响应长按
        if (self.isLoading || self.isEditingMode || self.isSwipeDeleting) {
            NSLog(@"⚠️ 长按被禁用 - 加载中: %@, 编辑模式: %@, 左滑删除: %@", 
                  self.isLoading ? @"是" : @"否",
                  self.isEditingMode ? @"是" : @"否", 
                  self.isSwipeDeleting ? @"是" : @"否");
            return;
        }
        
        // ✅ 获取长按位置
        CGPoint location = [gesture locationInView:self.voiceListTabelView];
        NSIndexPath *indexPath = [self.voiceListTabelView indexPathForRowAtPoint:location];
        
        if (indexPath && indexPath.section < self.voiceList.count) {
            NSLog(@"🖱️ 长按触发 - section: %ld", (long)indexPath.section);
            
            // ✅ 进入编辑模式
            [self enterEditingMode];
            
            // ✅ 自动选中长按的cell
            [self selectCellAtSection:indexPath.section];
            
            // ✅ 震动反馈
            if (@available(iOS 10.0, *)) {
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
                [generator impactOccurred];
            }
        }
    }
}

#pragma mark - ✅ 编辑模式管理

/// 进入编辑模式
- (void)enterEditingMode {
    if (self.isEditingMode) {
        return;
    }
    
    NSLog(@"📝 进入编辑模式");
    
    self.isEditingMode = YES;
    [self.selectedIndexes removeAllObjects];
    
    // ✅ 不使用系统的编辑模式，使用自定义编辑模式
    // [self.voiceListTabelView setEditing:YES animated:YES]; // 注释掉系统编辑模式
    
    // ✅ 更新所有可见cell的编辑模式状态
    [self updateAllVisibleCellsEditingMode];
    
    // ✅ 更新导航栏 - 添加完成按钮
    [self setupEditingNavigationBar];
    
    // ✅ 更新底部按钮为删除按钮
    [self updateBottomButtonForEditingMode];
    
    // ✅ 禁用返回手势
    self.fd_interactivePopDisabled = YES;
    
    // ✅ 停止当前播放
    [self stopCurrentAudio];
}

/// 退出编辑模式
- (void)exitEditingMode {
    if (!self.isEditingMode) {
        return;
    }
    
    NSLog(@"✅ 退出编辑模式");
    
    self.isEditingMode = NO;
    [self.selectedIndexes removeAllObjects];
    
    // ✅ 不使用系统的编辑模式，使用自定义编辑模式
    // [self.voiceListTabelView setEditing:NO animated:YES]; // 注释掉系统编辑模式
    
    // ✅ 更新所有可见cell的编辑模式状态
    [self updateAllVisibleCellsEditingMode];
    
    // ✅ 恢复导航栏
    [self restoreNormalNavigationBar];
    
    // ✅ 恢复底部按钮为创建按钮
    [self updateBottomButtonForNormalMode];
    
    // ✅ 恢复返回手势
    self.fd_interactivePopDisabled = NO;
}

/// 设置编辑模式的导航栏
- (void)setupEditingNavigationBar {
    // ✅ 创建完成按钮
    self.editDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" 
                                                           style:UIBarButtonItemStyleDone 
                                                          target:self 
                                                          action:@selector(doneButtonTapped)];
    self.editDoneButton.tintColor = [UIColor blackColor];
    
    // ✅ 设置右侧导航按钮
    self.navigationItem.rightBarButtonItem = self.editDoneButton;
    
    // ✅ 更新标题显示选中数量
    [self updateNavigationTitle];
}

/// 恢复正常模式的导航栏
- (void)restoreNormalNavigationBar {
    // ✅ 移除右侧按钮
    self.navigationItem.rightBarButtonItem = nil;
    
    // ✅ 恢复标题
    self.title = @"音色管理";
}

/// 完成按钮点击事件
- (void)doneButtonTapped {
    NSLog(@"✅ 完成按钮被点击");
    [self exitEditingMode];
}

/// 更新导航栏标题显示选中数量
- (void)updateNavigationTitle {
    if (self.isEditingMode) {
        NSInteger selectedCount = self.selectedIndexes.count;
        if (selectedCount > 0) {
            self.title = [NSString stringWithFormat:@"已选择 %ld 项", (long)selectedCount];
        } else {
            self.title = @"选择项目";
        }
    } else {
        self.title = @"音色管理";
    }
}

/// 选中指定section的cell
- (void)selectCellAtSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    // ✅ 在自定义编辑模式下，不使用系统的选中方法
    // [self.voiceListTabelView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self.selectedIndexes addObject:@(section)];
    [self updateNavigationTitle];
    [self updateDeleteButtonState];
    
    // ✅ 更新cell的选中状态
    VoiceManagementTableViewCell *cell = [self.voiceListTabelView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[VoiceManagementTableViewCell class]]) {
        [cell updateEditingMode:YES isSelected:YES];
    }
}

/// 取消选中指定section的cell
- (void)deselectCellAtSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    [self.voiceListTabelView deselectRowAtIndexPath:indexPath animated:YES];
    [self.selectedIndexes removeObject:@(section)];
    [self updateNavigationTitle];
    [self updateDeleteButtonState];
    
    // ✅ 更新cell的选中状态
    VoiceManagementTableViewCell *cell = [self.voiceListTabelView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[VoiceManagementTableViewCell class]]) {
        [cell updateEditingMode:YES isSelected:NO];
    }
}

/// ✅ 更新所有可见cell的编辑模式状态
- (void)updateAllVisibleCellsEditingMode {
    for (NSIndexPath *indexPath in self.voiceListTabelView.indexPathsForVisibleRows) {
        VoiceManagementTableViewCell *cell = [self.voiceListTabelView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[VoiceManagementTableViewCell class]]) {
            BOOL isSelected = [self.selectedIndexes containsObject:@(indexPath.section)];
            [cell updateEditingMode:self.isEditingMode isSelected:isSelected];
        }
    }
}

#pragma mark - ✅ 底部按钮管理

/// 更新底部按钮为编辑模式（删除按钮）
- (void)updateBottomButtonForEditingMode {
    [self.createVoiceBtn setTitle:@"删除选中项目" forState:UIControlStateNormal];
    [self.createVoiceBtn setBackgroundColor:[UIColor colorWithRed:0xEA/255.0 green:0x00/255.0 blue:0x00/255.0 alpha:1.0]];
    [self.createVoiceBtn removeTarget:self action:@selector(createVoiceBtnClick) forControlEvents:UIControlEventTouchDown];
    [self.createVoiceBtn addTarget:self action:@selector(deleteSelectedItems) forControlEvents:UIControlEventTouchUpInside];
    
    // ✅ 初始状态禁用删除按钮
    [self updateDeleteButtonState];
}

/// 更新底部按钮为正常模式（创建按钮）
- (void)updateBottomButtonForNormalMode {
    [self.createVoiceBtn removeTarget:self action:@selector(deleteSelectedItems) forControlEvents:UIControlEventTouchUpInside];
    [self.createVoiceBtn addTarget:self action:@selector(createVoiceBtnClick) forControlEvents:UIControlEventTouchDown];
    [self.createVoiceBtn setBackgroundColor:[UIColor colorWithRed:0x00/255.0 green:0x7A/255.0 blue:0xFF/255.0 alpha:1.0]];
    
    // ✅ 恢复创建按钮状态
    [self updateCreateButtonState];
}

/// 更新删除按钮状态
- (void)updateDeleteButtonState {
    if (!self.isEditingMode) {
        return;
    }
    
    BOOL hasSelection = self.selectedIndexes.count > 0;
    self.createVoiceBtn.enabled = hasSelection;
    self.createVoiceBtn.alpha = hasSelection ? 1.0 : 0.5;
    
    if (hasSelection) {
        [self.createVoiceBtn setTitle:[NSString stringWithFormat:@"删除选中项目 (%ld)", (long)self.selectedIndexes.count] forState:UIControlStateNormal];
    } else {
        [self.createVoiceBtn setTitle:@"删除选中项目" forState:UIControlStateNormal];
    }
}

/// 删除选中的项目
- (void)deleteSelectedItems {
    if (self.selectedIndexes.count == 0) {
        return;
    }
    
    NSLog(@"🗑️ 删除选中项目，数量: %ld", (long)self.selectedIndexes.count);
    
    // ✅ 检查选中的音色是否都可以删除
    NSMutableArray *cannotDeleteVoices = [NSMutableArray array];
    NSMutableArray *selectedVoices = [NSMutableArray array];
    
    for (NSNumber *sectionNumber in self.selectedIndexes) {
        NSInteger section = sectionNumber.integerValue;
        if (section < self.voiceList.count) {
            VoiceModel *voice = self.voiceList[section];
            [selectedVoices addObject:voice];
            
            if (!voice.canDelete) {
                [cannotDeleteVoices addObject:voice];
            }
        }
    }
    
    // ✅ 如果有不能删除的音色，显示提示
    if (cannotDeleteVoices.count > 0) {
        NSMutableString *message = [NSMutableString stringWithString:@"以下音色已关联故事，无法删除：\n"];
        for (VoiceModel *voice in cannotDeleteVoices) {
            [message appendFormat:@"• %@\n", voice.voiceName];
        }
        [message appendString:@"\n请先解除关联后再试"];
        
        [self showErrorAlert:@"删除失败" message:message];
        return;
    }
    
    // ✅ 显示确认删除对话框
    NSString *title = [NSString stringWithFormat:@"删除 %ld 个音色", (long)selectedVoices.count];
    NSString *message = @"确定要删除选中的音色吗？此操作无法撤销";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
        [self performBatchDelete:selectedVoices];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/// 执行批量删除
- (void)performBatchDelete:(NSArray<VoiceModel *> *)voicesToDelete {
    NSLog(@"[VoiceManagement] 开始批量删除 %ld 个音色", (long)voicesToDelete.count);
    
    // ✅ 显示删除进度
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"删除中 (0/%ld)", (long)voicesToDelete.count]];
    
    __block NSInteger completedCount = 0;
    __block NSInteger successCount = 0;
    __block NSMutableArray *failedVoices = [NSMutableArray array];
    
    // ✅ 逐个删除（可以改为并发删除以提高效率）
    for (VoiceModel *voice in voicesToDelete) {
        [[AFStoryAPIManager sharedManager] deleteVoiceWithId:voice.voiceId success:^(APIResponseModel *response) {
            
            completedCount++;
            successCount++;
            
            // ✅ 更新进度
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"删除中 (%ld/%ld)", (long)completedCount, (long)voicesToDelete.count]];
                
                // ✅ 所有删除操作完成
                if (completedCount == voicesToDelete.count) {
                    [self handleBatchDeleteCompletion:voicesToDelete successCount:successCount failedVoices:failedVoices];
                }
            });
            
        } failure:^(NSError *error) {
            
            completedCount++;
            [failedVoices addObject:voice];
            
            NSLog(@"[VoiceManagement] 删除音色失败: %@ - %@", voice.voiceName, error.localizedDescription);
            
            // ✅ 更新进度
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"删除中 (%ld/%ld)", (long)completedCount, (long)voicesToDelete.count]];
                
                // ✅ 所有删除操作完成
                if (completedCount == voicesToDelete.count) {
                    [self handleBatchDeleteCompletion:voicesToDelete successCount:successCount failedVoices:failedVoices];
                }
            });
        }];
    }
}

/// 处理批量删除完成
- (void)handleBatchDeleteCompletion:(NSArray<VoiceModel *> *)originalVoices 
                       successCount:(NSInteger)successCount 
                       failedVoices:(NSArray<VoiceModel *> *)failedVoices {
    
    [SVProgressHUD dismiss];
    
    // ✅ 从数据源中移除成功删除的音色
    NSMutableIndexSet *sectionsToDelete = [NSMutableIndexSet indexSet];
    
    for (VoiceModel *voice in originalVoices) {
        if (![failedVoices containsObject:voice]) {
            // 成功删除的音色，从数据源移除
            NSInteger index = [self.voiceList indexOfObject:voice];
            if (index != NSNotFound) {
                [sectionsToDelete addIndex:index];
            }
        }
    }
    
    // ✅ 按降序删除，避免索引混乱
    [sectionsToDelete enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [self.voiceList removeObjectAtIndex:idx];
    }];
    
    // ✅ 刷新表格
    if (sectionsToDelete.count > 0) {
        [self.voiceListTabelView beginUpdates];
        [self.voiceListTabelView deleteSections:sectionsToDelete withRowAnimation:UITableViewRowAnimationFade];
        [self.voiceListTabelView endUpdates];
    }
    
    // ✅ 退出编辑模式
    [self exitEditingMode];
    
    // ✅ 更新空状态
    if (self.voiceList.count == 0) {
        self.emptyView.hidden = NO;
    }
    
    // ✅ 更新创建按钮状态
    [self updateCreateButtonState];
    
    // ✅ 显示结果提示
    NSString *resultMessage;
    if (failedVoices.count == 0) {
        resultMessage = [NSString stringWithFormat:@"成功删除 %ld 个音色", (long)successCount];
        [SVProgressHUD showSuccessWithStatus:resultMessage];
        [SVProgressHUD dismissWithDelay:2.0];
    } else {
        resultMessage = [NSString stringWithFormat:@"删除完成\n成功：%ld 个\n失败：%ld 个", (long)successCount, (long)failedVoices.count];
        [self showErrorAlert:@"删除结果" message:resultMessage];
    }
    
    NSLog(@"[VoiceManagement] 批量删除完成 - 成功：%ld，失败：%ld", (long)successCount, (long)failedVoices.count);
}

@end
