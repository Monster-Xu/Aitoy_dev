//
//  CreateStoryWithVoiceViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import "CreateStoryWithVoiceViewController.h"
#import "CreateStoryWithVoiceTableViewCell.h"
#import "AudioPlayerView.h"
#import "AFStoryAPIManager.h"
#import "CreateVoiceViewController.h"
#import "SelectIllustrationVC.h"

@interface CreateStoryWithVoiceViewController ()<UITableViewDelegate, UITableViewDataSource, AudioPlayerViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *createImageView;
@property (weak, nonatomic) IBOutlet UILabel *storyStautsLabel;
@property (weak, nonatomic) IBOutlet UITextView *storyTextField;
@property (weak, nonatomic) IBOutlet UILabel *chooseVoiceLabel;
@property (weak, nonatomic) IBOutlet UIButton *addNewVoiceBtn;
@property (weak, nonatomic) IBOutlet UITableView *voiceTabelView;
@property (weak, nonatomic) IBOutlet UIButton *saveStoryBtn;
@property (weak, nonatomic) IBOutlet UITextField *stroryThemeTextView;
@property (weak, nonatomic) IBOutlet UIButton *voiceHeaderImageBtn;
@property (weak, nonatomic) IBOutlet UIButton *deletHeaderBtn;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIView *storyThemeView;
@property (weak, nonatomic) IBOutlet UIView *voiceHeaderView;
@property (weak, nonatomic) IBOutlet UIView *storyView;
@property (weak, nonatomic) IBOutlet UIView *chooseVoiceView;
@property (weak, nonatomic) IBOutlet UIButton *deletBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storyViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceListViewHeight;
// 数据源
@property (nonatomic, strong) NSMutableArray *voiceListArray;  // 音色列表数据
@property (nonatomic, strong) VoiceStoryModel *currentStory;   // 当前故事模型
@property (nonatomic, assign) NSInteger selectedVoiceIndex;    // 选中的音色索引

// 音频播放相关
@property (nonatomic, strong) AudioPlayerView *audioPlayerView;
@property (nonatomic, assign) NSInteger currentPlayingIndex; // 当前正在播放的语音索引
@property (nonatomic, copy) NSString *currentPlayingAudioURL; // 当前播放的音频URL
//选择的图片
@property (nonatomic, copy) NSString *selectedIllustrationUrl;

// ✅ 编辑状态变更追踪 - 记录原始值用于比较
@property (nonatomic, copy) NSString *originalStoryName;      // 原始故事名称
@property (nonatomic, copy) NSString *originalStoryContent;   // 原始故事内容
@property (nonatomic, copy) NSString *originalIllustrationUrl; // 原始插画URL
@property (nonatomic, assign) NSInteger originalVoiceId;      // 原始音色ID
@property (nonatomic, assign) BOOL hasUnsavedChanges;        // 是否有未保存的更改
//所有音色数量
@property(nonatomic,assign)NSInteger voiceCount;

// ✅ 滚动视图属性
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation CreateStoryWithVoiceViewController

#pragma mark - Lifecycle

- (instancetype)initWithEditMode:(BOOL)editMode {
    self = [super init];
    if (self) {
        _isEditMode = editMode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 根据编辑模式设置标题
//    self.title = self.isEditMode ? @"Edit Story" : @"Create Story";
    self.title = @"Edit Story";
    
    self.view.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0]];
    
    // ✅ 设置滚动视图
    [self setupScrollView];
    
    // ✅ 添加键盘通知监听
    [self setupKeyboardNotifications];
    
    self.voiceTabelView.delegate = self;
    self.voiceTabelView.dataSource = self;
    self.addNewVoiceBtn.borderWidth = 1;
    self.addNewVoiceBtn.borderColor = HexOf(0x1EAAFD);
    
    // 配置故事文本框
    [self configureStoryTextView];
    
    // 根据编辑模式设置文本框的可编辑状态
//    [self updateTextFieldsEditability];
    
    // 初始化数据源
    self.voiceListArray = [NSMutableArray array];
    self.selectedVoiceIndex = -1; // 默认未选中
    self.currentPlayingIndex = -1; // 没有正在播放的
    self.hasUnsavedChanges = NO; // 初始没有未保存的更改
    
    UINib *CreateStoryWithVoiceTableViewCell = [UINib nibWithNibName:@"CreateStoryWithVoiceTableViewCell" bundle:nil];
    [self.voiceTabelView registerNib:CreateStoryWithVoiceTableViewCell forCellReuseIdentifier:@"CreateStoryWithVoiceTableViewCell"];
    
    // 隐藏所有控件，显示加载状态
    [self hideAllContentViews];
    [self showLoadingState];
    
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // ✅ 离开页面时停止音频播放
    if (self.audioPlayerView && self.audioPlayerView.isPlaying) {
        [self.audioPlayerView pause];
        NSLog(@"⏸️ 离开页面，暂停音频播放");
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // ✅ 页面显示完成后再次更新滚动视图内容大小
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateScrollViewContentSize];
    });
}

/// ✅ 页面即将显示时刷新数据（从其他页面返回时）
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 如果已经加载过数据，检查是否需要刷新音色列表（可能添加了新音色）
    if (self.voiceListArray.count > 0) {
        [self refreshVoiceListIfNeeded];
    }
}



- (void)setStoryId:(NSInteger)storyId{
    _storyId = storyId;
}

#pragma mark - Loading State Management

/// 隐藏所有内容视图
- (void)hideAllContentViews {
    NSLog(@"🙈 隐藏所有内容控件");
    
    // 隐藏主要内容区域
    self.storyThemeView.hidden = YES;
    self.voiceHeaderView.hidden = YES;
    self.storyView.hidden = YES;
    self.chooseVoiceView.hidden = YES;
    self.saveStoryBtn.hidden = YES;
    self.deletBtn.hidden = YES;
}

/// 显示加载状态
- (void)showLoadingState {
    NSLog(@"⏳ 显示加载状态");
    
    // 可以在这里添加一个加载指示器
    [SVProgressHUD showWithStatus:@"加载中..."];
}

/// 显示所有内容视图（带动画）
- (void)showAllContentViewsWithAnimation {
    NSLog(@"✨ 显示所有内容控件");
    
    // 隐藏加载指示器
    [SVProgressHUD dismiss];
    
    // 设置初始状态（透明）
    self.storyThemeView.alpha = 0.0;
    self.voiceHeaderView.alpha = 0.0;
    self.storyView.alpha = 0.0;
    self.chooseVoiceView.alpha = 0.0;
    self.saveStoryBtn.alpha = 0.0;
    self.deletBtn.alpha = 0.0;
    
    // 显示控件
    self.storyThemeView.hidden = NO;
    self.voiceHeaderView.hidden = NO;
    self.storyView.hidden = NO;
    self.chooseVoiceView.hidden = NO;
    self.saveStoryBtn.hidden = NO;
    self.deletBtn.hidden = NO;
    
    // 添加渐显动画
    [UIView animateWithDuration:0.5 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.storyThemeView.alpha = 1.0;
        self.voiceHeaderView.alpha = 1.0;
        self.storyView.alpha = 1.0;
        self.chooseVoiceView.alpha = 1.0;
        self.saveStoryBtn.alpha = 1.0;
        self.deletBtn.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"🎉 内容显示动画完成");
            // ✅ 动画完成后更新滚动视图内容大小
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self updateScrollViewContentSize];
            });
        }
    }];
}

-(void)loadData{
    // 发起网络请求
    __weak typeof(self) weakSelf = self;
    
    // 创建请求组来同步两个网络请求
    dispatch_group_t group = dispatch_group_create();
    
    // 请求1：获取故事详情
    dispatch_group_enter(group);
    [[AFStoryAPIManager sharedManager]getStoryDetailWithId:self.storyId success:^(VoiceStoryModel * _Nonnull story) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            dispatch_group_leave(group);
            return;
        }
        
        // 保存故事模型
        strongSelf.currentStory = story;
        strongSelf.selectedIllustrationUrl = story.illustrationUrl;
        
        // ✅ 记录原始数据用于变更追踪（仅编辑模式）
        if (strongSelf.isEditMode) {
            [strongSelf recordOriginalStoryData:story];
        }
        
        // 更新UI（在主线程）
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.stroryThemeTextView.text = story.storyName;
            [strongSelf.voiceHeaderImageBtn sd_setImageWithURL:[NSURL URLWithString:story.illustrationUrl] forState:UIControlStateNormal];
            strongSelf.storyTextField.text = story.storyContent;
            
            // ✅ 故事内容加载完成后，动态调整高度
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf adjustStoryViewHeight];
            });
            
            // ✅ 编辑模式下设置文本变化监听
            if (strongSelf.isEditMode) {
                [strongSelf setupEditModeTextObservers];
            }
            
            // 确保文本充满整个视图并滚动到顶部
            [strongSelf.storyTextField scrollRangeToVisible:NSMakeRange(0, 0)];
            
            // 根据编辑模式设置不同的状态文本
            if (strongSelf.isEditMode) {
                strongSelf.storyStautsLabel.text = @"Edit your story content and voice!";
            } else {
                strongSelf.storyStautsLabel.text = @"The story has been created!";
            }
        });
        
        dispatch_group_leave(group);
        
    } failure:^(NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            dispatch_group_leave(group);
            return;
        }
        
        NSLog(@"❌ 获取故事列表失败: %@", error.localizedDescription);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 显示错误提示
            [strongSelf showErrorAlert:error.localizedDescription];
        });
        
        dispatch_group_leave(group);
    }];
    
    // 请求2：获取音色列表
    dispatch_group_enter(group);
    [[AFStoryAPIManager sharedManager]getVoicesWithStatus:0 success:^(VoiceListResponseModel * _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            dispatch_group_leave(group);
            return;
        }
        
        // 保存音色列表数据
        if (response.list && response.list.count > 0) {
            [strongSelf.voiceListArray removeAllObjects];
            strongSelf.voiceCount  = response.list.count;
            for (VoiceModel * model in response.list) {
                if (model.cloneStatus==2) {
                    [strongSelf.voiceListArray addObject:model];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.emptyView.hidden = YES;
                
                // ✅ 编辑模式下设置当前选中的音色（如果有）
                if (strongSelf.isEditMode && strongSelf.currentStory.voiceId > 0) {
                    NSLog(@"🎯 编辑模式：准备匹配音色ID: %ld", (long)strongSelf.currentStory.voiceId);
                    NSLog(@"🎯 当前过滤后的音色数量: %ld", (long)strongSelf.voiceListArray.count);
                    
                    // ✅ 延迟执行匹配，确保数据加载完成
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf selectVoiceWithId:strongSelf.currentStory.voiceId];
                        
                        // ✅ 匹配完成后检查结果
                        if (strongSelf.selectedVoiceIndex >= 0) {
                            NSLog(@"✅ 音色匹配成功，选中索引: %ld", (long)strongSelf.selectedVoiceIndex);
                        } else {
                            NSLog(@"❌ 音色匹配失败，可能原因:");
                            NSLog(@"   1. 音色ID %ld 不在可用列表中", (long)strongSelf.currentStory.voiceId);
                            NSLog(@"   2. 音色的 cloneStatus 不等于 2");
                            NSLog(@"   3. 数据同步问题");
                            
                            // ✅ 尝试备用匹配策略
                            [strongSelf tryFallbackVoiceSelection];
                        }
                    });
                }
                
                // 刷新TableView
                [strongSelf.voiceTabelView reloadData];
                
                // ✅ TableView数据变化后，动态调整高度（包括音色区域）
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf updateScrollViewContentSizeWithVoiceHeightRecalc:YES];
                });
                
                // ✅ 确保选中状态正确显示
                if (strongSelf.selectedVoiceIndex >= 0) {
                    NSLog(@"✅ 已选中音色索引: %ld", (long)strongSelf.selectedVoiceIndex);
                    [strongSelf debugCurrentSelectionState];
                } else if (strongSelf.isEditMode) {
                    NSLog(@"⚠️ 编辑模式但未找到匹配的音色ID: %ld", (long)strongSelf.currentStory.voiceId);
                    [strongSelf debugCurrentSelectionState];
                }
            });
            
            NSLog(@"✅ 成功加载 %ld 个音色", (long)strongSelf.voiceListArray.count);
        } else {
            NSLog(@"⚠️ 音色列表为空");
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.emptyView.hidden = NO;
                // ✅ 空数据时也要调整高度（包括音色区域）
                [strongSelf updateScrollViewContentSizeWithVoiceHeightRecalc:YES];
            });
        }
        
        dispatch_group_leave(group);
        
    } failure:^(NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            dispatch_group_leave(group);
            return;
        }
        
        NSLog(@"❌ 获取音色列表失败: %@", error.localizedDescription);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 显示错误提示
            [strongSelf showErrorAlert:error.localizedDescription];
        });
        
        dispatch_group_leave(group);
    }];
    
    // 当两个请求都完成后，显示内容
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        // ✅ 在显示内容前，确保编辑模式下的选中状态正确
        if (strongSelf.isEditMode && strongSelf.selectedVoiceIndex >= 0) {
            NSLog(@"🔄 确保音色选中状态在UI显示前正确设置，索引: %ld", (long)strongSelf.selectedVoiceIndex);
            // 再次刷新 TableView 确保选中状态显示
            [strongSelf.voiceTabelView reloadData];
        }
        
        // 延迟一点时间，让用户感受加载完成
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf showAllContentViewsWithAnimation];
            
            // ✅ 在动画完成后再次确保选中状态
            if (strongSelf.isEditMode && strongSelf.selectedVoiceIndex >= 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf.voiceTabelView reloadData];
                    NSLog(@"✅ 最终确认音色选中状态显示完成");
                });
            }
        });
    });
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.voiceListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 显示真实数据
    CreateStoryWithVoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreateStoryWithVoiceTableViewCell" forIndexPath:indexPath];
    
    // 获取当前音色数据
    if (indexPath.row < self.voiceListArray.count) {
        VoiceModel *voiceModel = self.voiceListArray[indexPath.row];
        BOOL isSelected = (indexPath.row == self.selectedVoiceIndex);
        
        // ✅ 添加调试日志
        // ✅ 添加调试日志
        if (self.isEditMode && isSelected) {
            NSLog(@"🎯 配置选中的音色cell: %@ (索引: %ld)", voiceModel.voiceName, (long)indexPath.row);
            NSLog(@"🎯 配置选中的音色cell: %@ (索引: %ld)", voiceModel.voiceName, (long)indexPath.row);
        }
        
        // 使用配置方法设置cell数据
        [cell configureWithVoiceModel:voiceModel isSelected:isSelected];
        
        // ✅ 设置播放按钮的状态（根据是否正在播放）
        cell.playBtn.selected = (indexPath.row == self.currentPlayingIndex);
        
        // ✅ 使用block回调 - 播放按钮
        __weak typeof(self) weakSelf = self;
        cell.onPlayButtonTapped = ^(VoiceModel *voiceModel, BOOL isPlaying) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (isPlaying) {
                // 开始播放
                [strongSelf playVoice:voiceModel atIndex:indexPath.row];
            } else {
                // 暂停播放
                [strongSelf pauseCurrentPlaying];
            }
        };
        
        // ✅ 使用block回调 - 选择按钮
        cell.onSelectButtonTapped = ^(VoiceModel *voiceModel, BOOL isSelected) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (isSelected) {
                // 选中该音色
                strongSelf.selectedVoiceIndex = indexPath.row;
                
                // ✅ 编辑模式下检测音色变化
                if (strongSelf.isEditMode && voiceModel.voiceId != strongSelf.originalVoiceId) {
                    strongSelf.hasUnsavedChanges = YES;
                    NSLog(@"🔄 音色发生变更: %ld → %ld", (long)strongSelf.originalVoiceId, (long)voiceModel.voiceId);
                }
                
                NSLog(@"✅ 选中音色索引: %ld", (long)indexPath.row);
            } else {
                // 取消选中
                strongSelf.selectedVoiceIndex = -1;
                
                // ✅ 编辑模式下检测音色变化
                if (strongSelf.isEditMode && strongSelf.originalVoiceId > 0) {
                    strongSelf.hasUnsavedChanges = YES;
                    NSLog(@"🔄 音色被取消选中，原音色ID: %ld", (long)strongSelf.originalVoiceId);
                }
                
                NSLog(@"❌ 取消选中音色索引: %ld", (long)indexPath.row);
            }
            
            // 刷新TableView更新其他cell的状态
            [strongSelf.voiceTabelView reloadData];
            
            // ✅ 注释掉：选择音色时不需要调整ScrollView高度，因为内容数量没有变化
            // dispatch_async(dispatch_get_main_queue(), ^{
            //     [strongSelf updateScrollViewContentSize];
            // });
        };
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 获取选中的音色模型
    VoiceModel *voiceModel = self.voiceListArray[indexPath.row];
    
    // ✅ 如果点击的是已选中的行，则取消选择
    if (self.selectedVoiceIndex == indexPath.row) {
        self.selectedVoiceIndex = -1;
        
        // ✅ 编辑模式下检测音色变化
        if (self.isEditMode && self.originalVoiceId > 0) {
            self.hasUnsavedChanges = YES;
            NSLog(@"🔄 音色被取消选中，原音色ID: %ld", (long)self.originalVoiceId);
        }
        
        NSLog(@"❌ 取消选中音色索引: %ld", (long)indexPath.row);
    } else {
        self.selectedVoiceIndex = indexPath.row;
        
        // ✅ 编辑模式下检测音色变化
        if (self.isEditMode && voiceModel.voiceId != self.originalVoiceId) {
            self.hasUnsavedChanges = YES;
            NSLog(@"🔄 音色发生变更: %ld → %ld", (long)self.originalVoiceId, (long)voiceModel.voiceId);
        }
        
        NSLog(@"✅ 选中音色索引: %ld", (long)indexPath.row);
    }
    
    // 刷新tableView显示选中状态
    [tableView reloadData];
    
    // ✅ 注释掉：选择音色时不需要调整ScrollView高度，因为内容数量没有变化
    // dispatch_async(dispatch_get_main_queue(), ^{
    //     [self updateScrollViewContentSize];
    // });
}

#pragma mark - Audio Control Methods

/**
 播放指定音色
 */
- (void)playVoice:(VoiceModel *)voiceModel atIndex:(NSInteger)index {
    NSLog(@"🎵 开始播放音色: %@", voiceModel.voiceName);
    
    // 如果点击的是正在播放的音色，则暂停
    if (self.currentPlayingIndex == index && self.audioPlayerView && self.audioPlayerView.isPlaying) {
        [self.audioPlayerView pause];
        return;
    }
    
    // 停止之前的播放
    if (self.currentPlayingIndex >= 0 && self.currentPlayingIndex != index) {
        // 重置之前播放的cell的按钮状态
        [self resetPlayButtonAtIndex:self.currentPlayingIndex];
    }
    
    // 更新当前播放索引
    self.currentPlayingIndex = index;
    
    // 获取音频信息
    NSString *audioURL = voiceModel.sampleAudioUrl;
    NSString *coverImageURL = voiceModel.avatarUrl;
    NSString *title = voiceModel.voiceName;
    
    if (!audioURL || audioURL.length == 0) {
        NSLog(@"❌ 音频URL为空");
        [self showErrorAlert:@"获取音频URL失败"];
        [self resetPlayButtonAtIndex:index];
        return;
    }
    
    NSLog(@"🎵 加载音频: %@", audioURL);
    
    // 创建或更新AudioPlayerView
    if (!self.audioPlayerView) {
        self.audioPlayerView = [[AudioPlayerView alloc] initWithAudioURL:audioURL
                                                              storyTitle:title
                                                          coverImageURL:coverImageURL ?: @""];
        self.audioPlayerView.delegate = self;
    }
    
    // ✅ 显示播放器 - 现在在根视图上显示，不在滚动视图中
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [self.audioPlayerView showInView:self.view withFrame:CGRectMake(16, screenHeight-290, screenWidth-32, 70)];
    
    // 开始播放
    [self.audioPlayerView play];
}

/**
 暂停当前播放
 */
- (void)pauseCurrentPlaying {
    NSLog(@"⏸️ 暂停播放");
    
    if (self.audioPlayerView && self.audioPlayerView.isPlaying) {
        [self.audioPlayerView pause];
    }
}

/**
 重置指定索引cell的播放按钮
 */
- (void)resetPlayButtonAtIndex:(NSInteger)index {
    if (index >= 0 && index < self.voiceListArray.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        CreateStoryWithVoiceTableViewCell *cell = (CreateStoryWithVoiceTableViewCell *)[self.voiceTabelView cellForRowAtIndexPath:indexPath];
        if (cell) {
            cell.playBtn.selected = NO;
        }
    }
}

#pragma mark - CreateStoryWithVoiceTableViewCellDelegate (已删除)

// 已删除delegate方法，改用block回调

#pragma mark - AudioPlayerViewDelegate

- (void)audioPlayerDidStartPlaying {
    NSLog(@"▶️ 音频播放开始");
}

- (void)audioPlayerDidPause {
    NSLog(@"⏸️ 音频播放暂停");
    [self resetPlayButtonAtIndex:self.currentPlayingIndex];
}

- (void)audioPlayerDidFinish {
    NSLog(@"✅ 音频播放完成");
    [self resetPlayButtonAtIndex:self.currentPlayingIndex];
}

- (void)audioPlayerDidUpdateProgress:(CGFloat)progress currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    // 可以用来更新UI进度等
}

- (void)audioPlayerDidClose {
    NSLog(@"❌ 音频播放器关闭");
    [self resetPlayButtonAtIndex:self.currentPlayingIndex];
    
    self.currentPlayingIndex = -1;
    self.audioPlayerView = nil;
}

#pragma mark - ScrollView Setup

/// ✅ 设置主滚动视图 - 将整个view包装到ScrollView中
- (void)setupScrollView {
    // 获取当前view的父视图
    UIView *parentView = self.view.superview;
    
    // 创建主滚动视图
    self.mainScrollView = [[UIScrollView alloc] init];
    self.mainScrollView.frame = self.view.frame;
    self.mainScrollView.backgroundColor = self.view.backgroundColor;
    self.mainScrollView.showsVerticalScrollIndicator = YES;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.bounces = YES;
    self.mainScrollView.alwaysBounceVertical = YES;
    self.mainScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag; // 拖动时隐藏键盘
    
    // 保存原有view作为内容视图
    self.contentView = self.view;
    
    // 创建新的根视图
    UIView *newRootView = [[UIView alloc] initWithFrame:self.view.frame];
    newRootView.backgroundColor = self.view.backgroundColor;
    
    // 将ScrollView添加到新的根视图中
    [newRootView addSubview:self.mainScrollView];
    
    // 将原有的view添加到ScrollView中
    [self.mainScrollView addSubview:self.contentView];
    
    // 替换视图控制器的view
    self.view = newRootView;
    
    // 设置ScrollView的frame填满新的根视图
    self.mainScrollView.frame = newRootView.bounds;
    self.mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // ✅ 延迟计算内容大小，让布局完成后再设置
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateScrollViewContentSize];
    });
    
    NSLog(@"✅ 滚动视图设置完成 - 保持原有XIB约束");
}


- (void)updateScrollViewContentSize {
    [self updateScrollViewContentSizeWithVoiceHeightRecalc:YES];
}

/// ✅ 更新滚动视图内容大小 - 控制是否重新计算音色区域高度
- (void)updateScrollViewContentSizeWithVoiceHeightRecalc:(BOOL)shouldRecalcVoiceHeight {
    if (!self.contentView) {
        return;
    }
    
    // 强制布局更新
    [self.contentView layoutIfNeeded];
    
    // ✅ 动态调整故事内容区域的高度
    [self adjustStoryViewHeight];
    
    // ✅ 只有在必要时才重新计算音色选择区域的高度
    if (shouldRecalcVoiceHeight) {
        [self adjustVoiceSelectionViewHeight];
    }
    
    // 再次强制布局更新，确保约束变化生效
    [self.contentView layoutIfNeeded];
    
    // 计算所有子视图的最大底部位置
    CGFloat maxY = 0;
    for (UIView *subview in self.contentView.subviews) {
        if (!subview.hidden && subview.alpha > 0) {
            CGFloat bottom = CGRectGetMaxY(subview.frame);
            if (bottom > maxY) {
                maxY = bottom;
            }
        }
    }
    
    // 添加一些底部边距，确保有足够的滚动空间
    maxY += 100;
    
    // 确保内容高度至少比屏幕高度大一些，这样才能滚动
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat contentHeight = MAX(maxY, screenHeight + 50);
    
    // 设置内容视图的frame大小
    CGRect contentFrame = self.contentView.frame;
    contentFrame.size.height = contentHeight;
    self.contentView.frame = contentFrame;
    
    // 设置ScrollView的内容大小
    self.mainScrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, contentHeight);
    
    NSLog(@"📏 滚动视图内容大小设置为: %.1f x %.1f (计算最大Y: %.1f, 屏幕高度: %.1f)", 
          self.mainScrollView.contentSize.width, self.mainScrollView.contentSize.height, maxY, screenHeight);
}

/// ✅ 动态调整故事内容区域的高度 - 使用约束
- (void)adjustStoryViewHeight {
    if (!self.storyViewHeight) {
        NSLog(@"⚠️ storyViewHeight约束未绑定");
        return;
    }
    
    // 获取故事内容
    NSString *storyContent = self.storyTextField.text ?: @"";
    if (storyContent.length == 0) {
        NSLog(@"📖 故事内容为空，使用默认高度");
        return;
    }
    
    // 计算文本所需的高度
    CGFloat textViewWidth = self.storyTextField.frame.size.width;
    if (textViewWidth <= 0) {
        textViewWidth = [UIScreen mainScreen].bounds.size.width - 32; // 默认宽度
    }
    
    // 减去内边距
    CGFloat contentWidth = textViewWidth - self.storyTextField.textContainerInset.left - self.storyTextField.textContainerInset.right;
    
    // 计算文本高度
    UIFont *font = self.storyTextField.font ?: [UIFont systemFontOfSize:16.0];
    CGRect textRect = [storyContent boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                              attributes:@{NSFontAttributeName: font}
                                                 context:nil];
    
    // 添加内边距和一些额外空间
    CGFloat requiredTextHeight = ceil(textRect.size.height);
    CGFloat topBottomPadding = self.storyTextField.textContainerInset.top + self.storyTextField.textContainerInset.bottom;
    CGFloat totalTextHeight = requiredTextHeight + topBottomPadding + 20; // 额外20pt空间
    
    // 设置最小和最大高度
    CGFloat minHeight = 120.0; // 最小高度
    CGFloat maxHeight = 400.0; // 最大高度，避免过高
    
    CGFloat newHeight = MAX(minHeight, MIN(totalTextHeight, maxHeight));
    
    // 更新约束常量
    self.storyViewHeight.constant = newHeight;
    
    // 动画更新布局
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentView layoutIfNeeded];
    }];
    
    NSLog(@"📖 动态调整故事内容区域完成:");
    NSLog(@"   故事内容长度: %ld", (long)storyContent.length);
    NSLog(@"   计算文本高度: %.1f", requiredTextHeight);
    NSLog(@"   storyViewHeight约束: %.1f", newHeight);
}

/// ✅ 动态调整音色选择区域的高度 - 使用约束
- (void)adjustVoiceSelectionViewHeight {
    if (!self.voiceListViewHeight) {
        NSLog(@"⚠️ voiceListViewHeight约束未绑定");
        return;
    }
    
    // 计算TableView需要的高度
    NSInteger cellCount = self.voiceListArray.count;
    CGFloat cellHeight = 64.0; // 每个cell的高度
    CGFloat newHeight = 0;
    
    if (cellCount > 0) {
        // 有数据时按cell数量计算高度
        newHeight = cellCount * cellHeight;
        
        // 设置一个最大高度限制，避免TableView过高
        CGFloat maxHeight = 5 * cellHeight; // 最多显示5个cell的高度
        newHeight = MIN(newHeight, maxHeight);
        
        // 添加一些内边距
        newHeight += 60.0; // 顶部和底部各20pt的边距
        
        self.emptyView.hidden = YES;
        NSLog(@"📊 有音色数据，计算高度: %.1f", newHeight);
    } else {
        // 没有数据时显示空视图，设置最小高度
        newHeight = 160.0; // 空状态的最小高度
        self.emptyView.hidden = NO;
        NSLog(@"📊 无音色数据，显示空视图，设置高度: %.1f", newHeight);
    }
    
    // 更新约束常量
    self.voiceListViewHeight.constant = newHeight;
    
    // 动画更新布局
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentView layoutIfNeeded];
    }];
    
    NSLog(@"📊 动态调整音色选择区域完成:");
    NSLog(@"   Cell数量: %ld", (long)cellCount);
    NSLog(@"   voiceListViewHeight约束: %.1f", newHeight);
}


#pragma mark - Keyboard Handling

/// ✅ 设置键盘通知监听
- (void)setupKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

/// ✅ 键盘将要显示
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSValue *keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    // 调整滚动视图的底部内边距
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:(UIViewAnimationOptions)animationCurve
                     animations:^{
        self.mainScrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        self.mainScrollView.scrollIndicatorInsets = self.mainScrollView.contentInset;
    } completion:nil];
    
    NSLog(@"⌨️ 键盘显示，高度: %.1f", keyboardHeight);
}

/// ✅ 键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    // 恢复滚动视图的内边距
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:(UIViewAnimationOptions)animationCurve
                     animations:^{
        self.mainScrollView.contentInset = UIEdgeInsetsZero;
        self.mainScrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    } completion:nil];
    
    NSLog(@"⌨️ 键盘隐藏");
}

/// ✅ 刷新音色列表（从其他页面返回时可能有新音色） - 改进版
- (void)refreshVoiceListIfNeeded {
    NSLog(@"🔄 检查是否需要刷新音色列表");
    
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] getVoicesWithStatus:0 success:^(VoiceListResponseModel * _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (response.list && response.list.count > 0) {
            // 过滤出已克隆成功的音色
            NSMutableArray *newVoiceList = [NSMutableArray array];
            strongSelf.voiceCount = response.list.count;
            
            for (VoiceModel *model in response.list) {
                if (model.cloneStatus == 2) {
                    [newVoiceList addObject:model];
                }
            }
            
            // ✅ 更详细的变化检测
            BOOL shouldUpdate = NO;
            NSString *changeReason = @"";
            
            if (newVoiceList.count != strongSelf.voiceListArray.count) {
                shouldUpdate = YES;
                changeReason = [NSString stringWithFormat:@"数量变化: %ld → %ld", 
                               (long)strongSelf.voiceListArray.count, (long)newVoiceList.count];
            } else {
                // 检查音色ID是否有变化
                for (NSInteger i = 0; i < newVoiceList.count; i++) {
                    VoiceModel *newVoice = newVoiceList[i];
                    if (i < strongSelf.voiceListArray.count) {
                        VoiceModel *oldVoice = strongSelf.voiceListArray[i];
                        if (newVoice.voiceId != oldVoice.voiceId) {
                            shouldUpdate = YES;
                            changeReason = [NSString stringWithFormat:@"音色ID变化在位置%ld: %ld → %ld", 
                                           (long)i, (long)oldVoice.voiceId, (long)newVoice.voiceId];
                            break;
                        }
                    }
                }
            }
            
            if (shouldUpdate) {
                NSLog(@"🆕 检测到音色列表变化: %@", changeReason);
                
                // ✅ 记录当前选中的音色ID (如果有)
                NSInteger currentSelectedVoiceId = 0;
                if (strongSelf.selectedVoiceIndex >= 0 && strongSelf.selectedVoiceIndex < strongSelf.voiceListArray.count) {
                    VoiceModel *currentSelected = strongSelf.voiceListArray[strongSelf.selectedVoiceIndex];
                    currentSelectedVoiceId = currentSelected.voiceId;
                }
                
                // 更新数据源
                [strongSelf.voiceListArray removeAllObjects];
                [strongSelf.voiceListArray addObjectsFromArray:newVoiceList];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 刷新UI
                    [strongSelf.voiceTabelView reloadData];
                    strongSelf.emptyView.hidden = (newVoiceList.count > 0);
                    
                    // ✅ 重新匹配音色选择
                    if (strongSelf.isEditMode && strongSelf.currentStory.voiceId > 0) {
                        NSLog(@"🔄 音色列表更新后，重新匹配编辑模式的音色");
                        [strongSelf selectVoiceWithId:strongSelf.currentStory.voiceId];
                        [strongSelf.voiceTabelView reloadData];
                    } else if (currentSelectedVoiceId > 0) {
                        // 尝试恢复之前选中的音色
                        NSLog(@"🔄 尝试恢复之前选中的音色ID: %ld", (long)currentSelectedVoiceId);
                        [strongSelf selectVoiceWithId:currentSelectedVoiceId];
                        [strongSelf.voiceTabelView reloadData];
                    }
                    
                    // 动态调整高度（音色列表有变化，需要重新计算）
                    [strongSelf updateScrollViewContentSizeWithVoiceHeightRecalc:YES];
                });
            } else {
                NSLog(@"✅ 音色列表无变化");
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"❌ 刷新音色列表失败: %@", error.localizedDescription);
    }];
}

#pragma mark - Helper Methods

- (void)configureStoryTextView {
    // 基础文字配置
    self.storyTextField.font = [UIFont systemFontOfSize:16.0];
    self.storyTextField.textColor = [UIColor blackColor];
    
    // 设置内边距，让文字充满背景
    self.storyTextField.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
    self.storyTextField.textContainer.lineFragmentPadding = 0; // 去除默认的左右边距
    
    // ✅ 修改滚动配置，避免与主滚动视图冲突
    self.storyTextField.scrollEnabled = NO; // 禁用内部滚动，使用主滚动视图
    self.storyTextField.showsVerticalScrollIndicator = NO;
    self.storyTextField.showsHorizontalScrollIndicator = NO;
    self.storyTextField.bounces = NO;
    
    // 键盘和输入配置
    self.storyTextField.returnKeyType = UIReturnKeyDefault;
    self.storyTextField.autocorrectionType = UITextAutocorrectionTypeDefault;
    self.storyTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.storyTextField.spellCheckingType = UITextSpellCheckingTypeDefault;
    
    // 文本布局配置
    self.storyTextField.textAlignment = NSTextAlignmentLeft;
    
    // 圆角和边框（可选）
    self.storyTextField.layer.cornerRadius = 8.0;
    self.storyTextField.layer.masksToBounds = YES;
    
    // 确保文本容器充满整个视图
    self.storyTextField.textContainer.widthTracksTextView = YES;
    self.storyTextField.textContainer.heightTracksTextView = YES; // 让高度自动适应内容
    self.storyTextField.textContainer.maximumNumberOfLines = 0; // 无限行数
    
    // 设置键盘外观
    if (@available(iOS 13.0, *)) {
        self.storyTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    }
}

/// ✅ 更新滚动视图内容大小 - 只调整故事内容高度（用于文本内容变化时）
- (void)updateScrollViewContentSizeForStoryOnly {
    if (!self.contentView) {
        return;
    }
    
    // 强制布局更新
    [self.contentView layoutIfNeeded];
    
    // ✅ 只调整故事内容区域的高度，不重新计算音色区域
    [self adjustStoryViewHeight];
    
    // 再次强制布局更新，确保约束变化生效
    [self.contentView layoutIfNeeded];
    
    // 计算所有子视图的最大底部位置
    CGFloat maxY = 0;
    for (UIView *subview in self.contentView.subviews) {
        if (!subview.hidden && subview.alpha > 0) {
            CGFloat bottom = CGRectGetMaxY(subview.frame);
            if (bottom > maxY) {
                maxY = bottom;
            }
        }
    }
    
    // 添加一些底部边距，确保有足够的滚动空间
    maxY += 100;
    
    // 确保内容高度至少比屏幕高度大一些，这样才能滚动
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat contentHeight = MAX(maxY, screenHeight + 100);
    
    // 设置内容视图的frame大小
    CGRect contentFrame = self.contentView.frame;
    contentFrame.size.height = contentHeight;
    self.contentView.frame = contentFrame;
    
    // 设置ScrollView的内容大小
    self.mainScrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, contentHeight);
    
    NSLog(@"📏 滚动视图内容大小已更新（仅故事内容）: %.1f x %.1f", 
          self.mainScrollView.contentSize.width, self.mainScrollView.contentSize.height);
}

/// ✅ 添加延迟调整方法，避免频繁调用
- (void)scheduleStoryHeightAdjustment {
    // 取消之前的调用
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateScrollViewContentSizeForStoryOnly) object:nil];
    
    // 延迟调用，避免频繁更新，只调整故事内容高度
    [self performSelector:@selector(updateScrollViewContentSizeForStoryOnly) withObject:nil afterDelay:0.1];
}

- (void)setIsEditMode:(BOOL)isEditMode {
    _isEditMode = isEditMode;
    
//    // 如果视图已经加载，立即更新UI
//    if (self.isViewLoaded) {
//        self.title = isEditMode ? @"Edit Story" : @"Create Story";
////        [self updateTextFieldsEditability];
//    }
}

//- (IBAction)addHeaderImageBtnClick:(id)sender {
//    [self showIllustrationPicker];
//}
//- (void)showIllustrationPicker {
//    SelectIllustrationVC *vc = [[SelectIllustrationVC alloc] init];
//    
//    // 设置当前已选择的图片URL，以便在选择器中显示选中状态
//    if (self.selectedIllustrationUrl && self.selectedIllustrationUrl.length > 0) {
//        vc.imgUrl = self.selectedIllustrationUrl;
//        NSLog(@"🖼️ 传递已选择的图片URL: %@", self.selectedIllustrationUrl);
//    }
//    
//    // 设置回调
//    vc.sureBlock = ^(NSString *imgUrl) {
//        NSLog(@"选中的插画: %@", imgUrl);
//        
//        // ✅ 检查插画是否真的有变更
//        NSString *currentUrl = imgUrl ?: @"";
//        NSString *originalUrl = self.originalIllustrationUrl ?: @"";
//        
//        // 保存选中的插画URL
//        self.selectedIllustrationUrl = imgUrl;
//        
//        // ✅ 编辑模式下检测插画变化
//        if (self.isEditMode && ![currentUrl isEqualToString:originalUrl]) {
//            self.hasUnsavedChanges = YES;
//            NSLog(@"🔄 插画发生变更: '%@' → '%@'", originalUrl, currentUrl);
//        }
//        
//        // 使用插画URL设置按钮背景
//        [self.voiceHeaderImageBtn sd_setImageWithURL:[NSURL URLWithString:imgUrl]
//                                             forState:UIControlStateNormal
//                                     placeholderImage:nil
//                                              options:SDWebImageRefreshCached
//                                            completed:nil];
//        self.deletHeaderBtn.hidden = NO;
//        NSLog(@"✅ 插画已选中，URL已保存");
//    };
//    
//    // 显示
//    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    [self presentViewController:vc animated:NO completion:^{
//        [vc showView];
//    }];
//}

- (void)removeImageButtonTapped {
    // ✅ 编辑模式下检测插画变化
    if (self.isEditMode) {
        NSString *originalUrl = self.originalIllustrationUrl ?: @"";
        if (originalUrl.length > 0) {
            self.hasUnsavedChanges = YES;
            NSLog(@"🔄 插画被删除，原插画: '%@'", originalUrl);
        }
    }
    
    self.selectedIllustrationUrl = nil;
    [self.voiceHeaderImageBtn setImage:nil forState:UIControlStateNormal];
//    self.deletHeaderBtn.hidden = YES;
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

- (IBAction)addNewVoice:(id)sender {
    if (self.voiceCount>=3) {
        [SVProgressHUD showErrorWithStatus:@"已创建3个音色，请删除后再创建"];
    }else{
        CreateVoiceViewController * vc = [[CreateVoiceViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
   
}

- (IBAction)saveStory:(id)sender {
    if (self.isEditMode) {
        // ✅ 编辑模式：调用编辑故事接口
        [self handleEditStory];
    } else {
        // 创建模式：调用合成音频接口（原有逻辑）
        [self handleCreateStory];
    }
}

/// ✅ 处理编辑故事
- (void)handleEditStory {
    NSLog(@"📝 开始编辑故事流程");
    
    // 检查是否有未保存的更改
    if (!self.hasUnsavedChanges && ![self detectAnyChanges]) {
        [self showErrorAlert:@"没有检测到任何更改"];
        return;
    }
    
    // 验证必要参数
    NSString *validationError = [self validateEditStoryParameters];
    if (validationError) {
        [self showErrorAlert:validationError];
        return;
    }
    
    // 获取选中的音色ID
    NSInteger currentVoiceId = [self getCurrentVoiceId];
    
    // ✅ 验证音色ID是否有效
    if (currentVoiceId <= 0) {
        NSLog(@"❌ 音色ID无效: %ld", (long)currentVoiceId);
        [self showErrorAlert:@"请选择一个有效的音色"];
        return;
    }
    
    NSLog(@"🎵 编辑故事使用的音色ID: %ld", (long)currentVoiceId);
    
    // 检测所有变更
    NSDictionary *changes = [self detectAllStoryChanges];
    NSLog(@"🔍 检测到的变更: %@", changes);
    
    // 准备编辑请求参数
    NSDictionary *params = @{
        @"familyId": @([[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue]),
        @"storyId": @(self.storyId),
        @"storyName": self.stroryThemeTextView.text ?: @"",
        @"storyContent": self.storyTextField.text ?: @"",
        @"illustrationUrl": self.selectedIllustrationUrl ?: @"",
        @"voiceId": @(currentVoiceId)
    };
    
    NSLog(@"📤 开始编辑故事，完整参数:");
    NSLog(@"   familyId: %@", params[@"familyId"]);
    NSLog(@"   storyId: %@", params[@"storyId"]);
    NSLog(@"   storyName: %@", params[@"storyName"]);
    NSLog(@"   storyContent长度: %ld", [(NSString *)params[@"storyContent"] length]);
    NSLog(@"   illustrationUrl: %@", params[@"illustrationUrl"]);
    NSLog(@"   voiceId: %@ ✅", params[@"voiceId"]); // 特别标注音色ID
    
    // 显示加载提示
    [SVProgressHUD showWithStatus:@"正在保存..."];
    
    // 调用编辑故事接口
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] updateStory:[[UpdateStoryRequestModel alloc] initWithParams:params]
                                           success:^(APIResponseModel * _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [SVProgressHUD dismiss];
        
        NSLog(@"✅ 故事编辑成功: %@", response);
        
        // ✅ 更新原始数据并清除未保存状态
        [strongSelf updateOriginalDataAfterSave];
        
        [LGBaseAlertView showAlertWithTitle:@"保存成功"
                                    content:@"故事已成功更新"
                               cancelBtnStr:nil
                              confirmBtnStr:@"确认"
                               confirmBlock:^(BOOL isValue, id obj) {
            if (isValue) {
                
                
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
        
    } failure:^(NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [SVProgressHUD dismiss];
        
        NSLog(@"❌ 故事编辑失败: %@", error.localizedDescription);
        
        // 显示错误提示
        NSString *errorMessage;
        if (error.code == -1009) {
            errorMessage = @"网络连接失败，请检查网络后重试";
        } else if (error.code == 401) {
            errorMessage = @"认证失败，请重新登录";
        } else if (error.code >= 500) {
            errorMessage = @"服务器繁忙，请稍后重试";
        } else {
            errorMessage = error.localizedDescription ?: @"编辑故事失败，请重试";
        }
        
        [strongSelf showErrorAlert:errorMessage];
    }];
}

/// ✅ 处理创建故事（原有逻辑）
- (void)handleCreateStory {
    // 检查是否选择了音色
    if (self.selectedVoiceIndex < 0 || self.selectedVoiceIndex >= self.voiceListArray.count) {
        [self showErrorAlert:@"请先选择一个音色"];
        return;
    }
    
    // 检查故事名称是否为空
    if (!self.stroryThemeTextView.text || self.stroryThemeTextView.text.length == 0) {
        [self showErrorAlert:@"请输入故事名称"];
        return;
    }
    
    // 获取选中的音色模型
    id selectedVoiceModel = self.voiceListArray[self.selectedVoiceIndex];
    
    // 获取 voiceId
    NSInteger voiceId = 0;
    if ([selectedVoiceModel respondsToSelector:@selector(voiceId)]) {
        voiceId = [[selectedVoiceModel valueForKey:@"voiceId"] integerValue];
    } else if ([selectedVoiceModel respondsToSelector:@selector(id)]) {
        voiceId = [[selectedVoiceModel valueForKey:@"id"] integerValue];
    }
    
    if (voiceId == 0) {
        [self showErrorAlert:@"获取音色ID失败"];
        return;
    }
    
    // 准备请求参数
    NSString *storyContent = self.isEditMode ? self.storyTextField.text : self.currentStory.storyContent;
    
    NSDictionary *params = @{
        @"storyId": @(self.storyId),
        @"familyId":@([[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue]),
        @"voiceId": @(voiceId),
        @"storyName": self.stroryThemeTextView.text ?: @"",
        @"storyContent": storyContent ?: @"",
        @"illustrationUrl": self.selectedIllustrationUrl ?: @""
    };
    
    NSLog(@"📤 开始合成音频，参数: %@", params);
    
    // 显示加载提示
    [SVProgressHUD showWithStatus:@"正在合成音频..."];
    
    // 调用音频合成接口
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] synthesizeStoryAudioWithParams:params
                                                              success:^(id _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [SVProgressHUD dismiss];
        
        NSLog(@"✅ 音频合成成功: %@", response);
        
        [LGBaseAlertView showAlertWithTitle:@"故事生成中，预计需要3-5min"
                                    content:@"稍后可在「故事清单」中查看故事"
                               cancelBtnStr:nil
                              confirmBtnStr:@"确认"
                               confirmBlock:^(BOOL isValue, id obj) {
            if (isValue) {
                
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        
    } failure:^(NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [SVProgressHUD dismiss];
        
        NSLog(@"❌ 音频合成失败: %@", error.localizedDescription);
        
        // 显示错误提示
        [strongSelf showErrorAlert:error.localizedDescription ?: @"音频合成失败，请重试"];
    }];
}
- (IBAction)deletBtnClick:(id)sender {
    // ✅ 实现删除故事功能
    
    // ✅ 检查故事ID是否有效
    if (self.storyId <= 0) {
        NSLog(@"⚠️ 故事ID无效，无法删除");
        [self showErrorAlert:@"删除失败：故事数据异常"];
        return;
    }
    
    [self showDeleteConfirmation];
}

#pragma mark - Delete Story Methods

/// 显示删除确认对话框
- (void)showDeleteConfirmation {
    // ✅ 获取故事名称用于确认对话框
    NSString *storyName = self.currentStory.storyName ?: self.stroryThemeTextView.text ?: @"此故事";
    
    NSString *alertTitle = @"删除故事";
    NSString *alertMessage = [NSString stringWithFormat:@"确定要删除故事《%@》吗？删除后无法恢复。", storyName];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // ✅ 取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"📝 用户取消删除故事: %@", storyName);
    }];
    
    // ✅ 删除按钮（使用危险样式）
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"🗑️ 用户确认删除故事: %@，开始执行删除操作", storyName);
        [self performDeleteStory];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    
    // ✅ 显示对话框
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

/// 执行删除故事操作
- (void)performDeleteStory {
    // ✅ 检查故事ID是否有效
    if (self.storyId <= 0) {
        NSLog(@"❌ 故事ID无效: %ld", (long)self.storyId);
        [self showErrorAlert:@"删除失败：故事ID无效"];
        return;
    }
    
    NSLog(@"🗑️ 开始删除故事，ID: %ld", (long)self.storyId);
    
    // ✅ 显示加载提示
    [SVProgressHUD showWithStatus:@"正在删除..."];
    
    // ✅ 停止音频播放（如果正在播放）
    [self stopAudioPlayback];
    
    // ✅ 调用删除接口
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] deleteStoryWithId:self.storyId
                                                  success:^(APIResponseModel * _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            NSLog(@"✅ 故事删除成功: %@", response);
            
            // ✅ 显示删除成功提示
            [strongSelf showDeleteSuccessAlert];
        });
        
    } failure:^(NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            NSLog(@"❌ 故事删除失败: %@", error.localizedDescription);
            
            // ✅ 显示删除失败提示
            NSString *errorMessage = error.localizedDescription ?: @"删除故事失败，请重试";
            [strongSelf showErrorAlert:[NSString stringWithFormat:@"删除失败：%@", errorMessage]];
        });
    }];
}

/// 停止音频播放
- (void)stopAudioPlayback {
    if (self.audioPlayerView) {
        [self.audioPlayerView hide];
        self.audioPlayerView = nil;
        self.currentPlayingIndex = -1;
        NSLog(@"🔇 已停止音频播放");
    }
}

/// 显示删除成功提示
- (void)showDeleteSuccessAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除成功"
                                                                             message:@"故事已成功删除"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        // ✅ 发送通知，让故事列表页面刷新数据
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StoryDeletedNotification" 
                                                            object:nil 
                                                          userInfo:@{@"storyId": @(self.storyId)}];
        
        // ✅ 删除成功后返回上一页
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - ✅ 编辑模式变更追踪方法

/// 记录原始故事数据
- (void)recordOriginalStoryData:(VoiceStoryModel *)story {
    NSLog(@"📋 记录原始故事数据用于变更追踪...");
    
    self.originalStoryName = story.storyName ?: @"";
    self.originalStoryContent = story.storyContent ?: @"";
    self.originalIllustrationUrl = story.illustrationUrl ?: @"";
    self.originalVoiceId = story.voiceId;
    
    NSLog(@"   原始故事名称: %@", self.originalStoryName);
    NSLog(@"   原始故事内容长度: %ld", (long)self.originalStoryContent.length);
    NSLog(@"   原始插画URL: %@", self.originalIllustrationUrl);
    NSLog(@"   原始音色ID: %ld", (long)self.originalVoiceId);
}

/// 设置编辑模式文本变化监听
- (void)setupEditModeTextObservers {
    NSLog(@"🔧 设置编辑模式文本变化监听");
    
    // 监听故事名称变化
    [self.stroryThemeTextView addTarget:self 
                                 action:@selector(storyNameDidChange:) 
                       forControlEvents:UIControlEventEditingChanged];
    
    // 监听故事内容变化（UITextView需要使用通知）
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storyContentDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self.storyTextField];
}

/// 故事名称变化监听
- (void)storyNameDidChange:(UITextField *)textField {
    NSString *currentName = textField.text ?: @"";
    if (![currentName isEqualToString:self.originalStoryName]) {
        self.hasUnsavedChanges = YES;
        NSLog(@"🔄 故事名称发生变更: '%@' → '%@'", self.originalStoryName, currentName);
    }
}

/// 故事内容变化监听
- (void)storyContentDidChange:(NSNotification *)notification {
    if (notification.object == self.storyTextField) {
        NSString *currentContent = self.storyTextField.text ?: @"";
        if (![currentContent isEqualToString:self.originalStoryContent]) {
            self.hasUnsavedChanges = YES;
            NSLog(@"🔄 故事内容发生变更，长度: %ld → %ld", 
                  (long)self.originalStoryContent.length, (long)currentContent.length);
        }
        
        // ✅ 使用延迟调整，避免频繁更新
        [self scheduleStoryHeightAdjustment];
    }
}

/// 根据音色ID选中对应的音色 - 改进匹配逻辑
- (void)selectVoiceWithId:(NSInteger)voiceId {
    NSLog(@"🔍 开始查找音色ID: %ld，当前音色列表数量: %ld", (long)voiceId, (long)self.voiceListArray.count);
    
    if (voiceId <= 0) {
        NSLog(@"⚠️ 无效的音色ID: %ld", (long)voiceId);
        self.selectedVoiceIndex = -1;
        return;
    }
    
    // ✅ 重置选中索引
    self.selectedVoiceIndex = -1;
    
    // ✅ 遍历查找匹配的音色
    for (NSInteger i = 0; i < self.voiceListArray.count; i++) {
        VoiceModel *voice = self.voiceListArray[i];
        
        // ✅ 添加更详细的日志
        NSLog(@"   检查音色[%ld]: 名称='%@', ID=%ld, cloneStatus=%ld", 
              (long)i, voice.voiceName ?: @"无名称", (long)voice.voiceId, (long)voice.cloneStatus);
        
        // ✅ 严格匹配音色ID
        if (voice.voiceId == voiceId) {
            self.selectedVoiceIndex = i;
            NSLog(@"🎵 成功匹配！自动选中音色: '%@' (ID: %ld, 索引: %ld)", 
                  voice.voiceName ?: @"无名称", (long)voiceId, (long)i);
            
            // ✅ 匹配成功后立即返回
            return;
        }
    }
    
    // ✅ 如果没有找到匹配的音色，提供更详细的错误信息
    NSLog(@"⚠️ 未找到匹配的音色ID: %ld", (long)voiceId);
    NSLog(@"   当前可用音色列表:");
    for (NSInteger i = 0; i < self.voiceListArray.count; i++) {
        VoiceModel *voice = self.voiceListArray[i];
        NSLog(@"     [%ld] %@ (ID: %ld)", (long)i, voice.voiceName ?: @"无名称", (long)voice.voiceId);
    }
    
    self.selectedVoiceIndex = -1;
}

/// ✅ 备用音色选择策略
- (void)tryFallbackVoiceSelection {
    NSLog(@"🔄 尝试备用音色选择策略");
    
    if (!self.isEditMode || !self.currentStory) {
        return;
    }
    
    NSInteger targetVoiceId = self.currentStory.voiceId;
    NSLog(@"🎯 目标音色ID: %ld", (long)targetVoiceId);
    
    // ✅ 策略1: 重新获取完整音色列表（包括所有状态）
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] getVoicesWithStatus:0 success:^(VoiceListResponseModel * _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"🔍 备用策略：获得完整音色列表，数量: %ld", (long)response.list.count);
        
        // 查找目标音色的详细信息
        VoiceModel *targetVoice = nil;
        for (VoiceModel *voice in response.list) {
            if (voice.voiceId == targetVoiceId) {
                targetVoice = voice;
                break;
            }
        }
        
        if (targetVoice) {
            NSLog(@"🎵 找到目标音色: %@, cloneStatus: %ld", targetVoice.voiceName ?: @"无名称", (long)targetVoice.cloneStatus);
            
            if (targetVoice.cloneStatus != 2) {
                NSLog(@"⚠️ 音色状态异常: cloneStatus = %ld (应为2)", (long)targetVoice.cloneStatus);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *statusText = @"";
                    switch (targetVoice.cloneStatus) {
                        case 0:
                            statusText = @"待处理";
                            break;
                        case 1:
                            statusText = @"处理中";
                            break;
                        case 3:
                            statusText = @"处理失败";
                            break;
                        default:
                            statusText = [NSString stringWithFormat:@"未知状态(%ld)", (long)targetVoice.cloneStatus];
                            break;
                    }
                    
                    NSString *alertMessage = [NSString stringWithFormat:@"故事使用的音色 '%@' 当前状态为：%@\n无法在列表中显示", 
                                            targetVoice.voiceName ?: @"未知音色", statusText];
                    [strongSelf showErrorAlert:alertMessage];
                });
            } else {
                // 音色状态正常但不在过滤列表中，可能是数据同步问题
                NSLog(@"🔄 音色状态正常，重新加载音色列表");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf reloadVoiceListAndRetrySelection];
                });
            }
        } else {
            NSLog(@"❌ 完整列表中也找不到音色ID: %ld", (long)targetVoiceId);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *alertMessage = [NSString stringWithFormat:@"故事使用的音色(ID:%ld)已不存在\n请重新选择音色", (long)targetVoiceId];
                [strongSelf showErrorAlert:alertMessage];
            });
        }
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"❌ 备用策略失败: %@", error.localizedDescription);
    }];
}

/// ✅ 重新加载音色列表并重试选择
- (void)reloadVoiceListAndRetrySelection {
    NSLog(@"🔄 重新加载音色列表并重试选择");
    
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] getVoicesWithStatus:0 success:^(VoiceListResponseModel * _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        // 重新过滤音色列表
        [strongSelf.voiceListArray removeAllObjects];
        strongSelf.voiceCount = response.list.count;
        
        for (VoiceModel *model in response.list) {
            if (model.cloneStatus == 2) {
                [strongSelf.voiceListArray addObject:model];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 刷新UI
            [strongSelf.voiceTabelView reloadData];
            strongSelf.emptyView.hidden = (strongSelf.voiceListArray.count > 0);
            
            // 再次尝试匹配
            if (strongSelf.currentStory.voiceId > 0) {
                [strongSelf selectVoiceWithId:strongSelf.currentStory.voiceId];
                
                if (strongSelf.selectedVoiceIndex >= 0) {
                    NSLog(@"✅ 重新加载后匹配成功");
                    [strongSelf.voiceTabelView reloadData];
                } else {
                    NSLog(@"❌ 重新加载后仍匹配失败");
                }
            }
            
            // 更新滚动视图（音色列表有变化，需要重新计算）
            [strongSelf updateScrollViewContentSizeWithVoiceHeightRecalc:YES];
        });
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"❌ 重新加载音色列表失败: %@", error.localizedDescription);
    }];
}

/// 获取当前选中的音色ID
- (NSInteger)getCurrentVoiceId {
    if (self.selectedVoiceIndex >= 0 && self.selectedVoiceIndex < self.voiceListArray.count) {
        VoiceModel *selectedVoice = self.voiceListArray[self.selectedVoiceIndex];
        return selectedVoice.voiceId;
    }
    
    // ✅ 编辑模式下，如果没有重新选择音色，返回原始音色ID
    if (self.isEditMode && self.originalVoiceId > 0) {
        NSLog(@"⚠️ 编辑模式下未重新选择音色，使用原始音色ID: %ld", (long)self.originalVoiceId);
        return self.originalVoiceId;
    }
    
    return 0;
}

/// 验证编辑故事参数
- (NSString *)validateEditStoryParameters {
    // 检查故事名称
    NSString *storyName = self.stroryThemeTextView.text;
    if (!storyName || storyName.length == 0) {
        return @"请输入故事名称";
    }
    
    // 检查故事内容
    NSString *storyContent = self.storyTextField.text;
    if (!storyContent || storyContent.length == 0) {
        return @"请输入故事内容";
    }
    
    // ✅ 改进音色选择检查逻辑 - 确保有有效的音色ID
    NSInteger currentVoiceId = [self getCurrentVoiceId];
    if (currentVoiceId <= 0) {
        // 如果是编辑模式且没有选择新音色，检查是否有原始音色ID
        if (self.isEditMode && self.originalVoiceId > 0) {
            NSLog(@"✅ 编辑模式：使用原始音色ID %ld", (long)self.originalVoiceId);
        } else {
            return @"请选择一个音色";
        }
    }
    
    // 检查插画选择
    if (!self.selectedIllustrationUrl || self.selectedIllustrationUrl.length == 0) {
        return @"请选择故事插画";
    }
    
    return nil; // 验证通过
}

/// 检测任意变更
- (BOOL)detectAnyChanges {
    NSString *currentName = self.stroryThemeTextView.text ?: @"";
    NSString *currentContent = self.storyTextField.text ?: @"";
    NSString *currentIllustration = self.selectedIllustrationUrl ?: @"";
    NSInteger currentVoiceId = [self getCurrentVoiceId];
    
    BOOL nameChanged = ![currentName isEqualToString:self.originalStoryName];
    BOOL contentChanged = ![currentContent isEqualToString:self.originalStoryContent];
    BOOL illustrationChanged = ![currentIllustration isEqualToString:self.originalIllustrationUrl];
    BOOL voiceChanged = (currentVoiceId != self.originalVoiceId);
    
    return (nameChanged || contentChanged || illustrationChanged || voiceChanged);
}

/// 检测所有故事变更
- (NSDictionary *)detectAllStoryChanges {
    NSMutableDictionary *changes = [NSMutableDictionary dictionary];
    NSMutableArray *changedFields = [NSMutableArray array];
    
    // 检测故事名称变更
    NSString *currentName = self.stroryThemeTextView.text ?: @"";
    BOOL nameChanged = ![currentName isEqualToString:self.originalStoryName];
    if (nameChanged) {
        [changedFields addObject:@"storyName"];
        changes[@"storyName"] = @{@"original": self.originalStoryName, @"current": currentName};
    }
    
    // 检测故事内容变更
    NSString *currentContent = self.storyTextField.text ?: @"";
    BOOL contentChanged = ![currentContent isEqualToString:self.originalStoryContent];
    if (contentChanged) {
        [changedFields addObject:@"storyContent"];
        changes[@"storyContent"] = @{
            @"original": @(self.originalStoryContent.length), 
            @"current": @(currentContent.length)
        };
    }
    
    // 检测插画变更
    NSString *currentIllustration = self.selectedIllustrationUrl ?: @"";
    BOOL illustrationChanged = ![currentIllustration isEqualToString:self.originalIllustrationUrl];
    if (illustrationChanged) {
        [changedFields addObject:@"illustrationUrl"];
        changes[@"illustrationUrl"] = @{@"original": self.originalIllustrationUrl, @"current": currentIllustration};
    }
    
    // 检测音色变更
    NSInteger currentVoiceId = [self getCurrentVoiceId];
    BOOL voiceChanged = (currentVoiceId != self.originalVoiceId);
    if (voiceChanged) {
        [changedFields addObject:@"voiceId"];
        changes[@"voiceId"] = @{@"original": @(self.originalVoiceId), @"current": @(currentVoiceId)};
    }
    
    // 汇总变更信息
    changes[@"changedFields"] = [changedFields copy];
    changes[@"hasChanges"] = @(changedFields.count > 0);
    changes[@"changeCount"] = @(changedFields.count);
    
    return [changes copy];
}

/// 保存成功后更新原始数据
- (void)updateOriginalDataAfterSave {
    NSLog(@"🔄 更新原始数据以防重复提交...");
    
    self.originalStoryName = self.stroryThemeTextView.text ?: @"";
    self.originalStoryContent = self.storyTextField.text ?: @"";
    self.originalIllustrationUrl = self.selectedIllustrationUrl ?: @"";
    self.originalVoiceId = [self getCurrentVoiceId];
    self.hasUnsavedChanges = NO;
    
    NSLog(@"   已更新原始故事名称: %@", self.originalStoryName);
    NSLog(@"   已更新原始故事内容长度: %ld", (long)self.originalStoryContent.length);
    NSLog(@"   已更新原始插画URL: %@", self.originalIllustrationUrl);
    NSLog(@"   已更新原始音色ID: %ld", (long)self.originalVoiceId);
}

#pragma mark - ✅ 调试和验证方法

/// 调试当前选中状态 - 增强版
- (void)debugCurrentSelectionState {
    NSLog(@"🔍 ========== 当前选中状态详细调试 ==========");
    NSLog(@"   编辑模式: %@", self.isEditMode ? @"是" : @"否");
    NSLog(@"   选中索引: %ld", (long)self.selectedVoiceIndex);
    NSLog(@"   音色数组数量: %ld", (long)self.voiceListArray.count);
    NSLog(@"   原始音色ID: %ld", (long)self.originalVoiceId);
    NSLog(@"   故事音色ID: %ld", (long)(self.currentStory ? self.currentStory.voiceId : -1));
    NSLog(@"   当前音色ID: %ld", (long)[self getCurrentVoiceId]);
    
    if (self.selectedVoiceIndex >= 0 && self.selectedVoiceIndex < self.voiceListArray.count) {
        VoiceModel *selectedVoice = self.voiceListArray[self.selectedVoiceIndex];
        NSLog(@"   选中音色: '%@' (ID: %ld, cloneStatus: %ld)", 
              selectedVoice.voiceName ?: @"无名称", 
              (long)selectedVoice.voiceId,
              (long)selectedVoice.cloneStatus);
    } else if (self.isEditMode && self.originalVoiceId > 0) {
        NSLog(@"   编辑模式：使用原始音色ID: %ld", (long)self.originalVoiceId);
    } else {
        NSLog(@"   未选中任何音色");
    }
    
    // ✅ 显示完整的音色列表信息
    NSLog(@"   --- 当前音色列表详情 ---");
    for (NSInteger i = 0; i < self.voiceListArray.count; i++) {
        VoiceModel *voice = self.voiceListArray[i];
        NSString *isSelectedMark = (i == self.selectedVoiceIndex) ? @" ✅" : @"";
        NSLog(@"     [%ld] '%@' (ID: %ld, cloneStatus: %ld)%@", 
              (long)i, 
              voice.voiceName ?: @"无名称", 
              (long)voice.voiceId,
              (long)voice.cloneStatus,
              isSelectedMark);
    }
    
    NSLog(@"========================================");
}

- (void)dealloc {
    NSLog(@"🔄 CreateStoryWithVoiceViewController dealloc");
    
    // ✅ 移除通知监听（包括键盘通知）
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // ✅ 停止音频播放并清理资源
    [self stopAudioPlayback];
    
    // ✅ 清理其他资源
    self.voiceListArray = nil;
    self.currentStory = nil;
    self.mainScrollView = nil;
    self.contentView = nil;
    
    NSLog(@"✅ CreateStoryWithVoiceViewController 资源清理完成");
}

@end
