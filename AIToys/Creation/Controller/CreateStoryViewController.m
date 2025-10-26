//
//  CreateStoryViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//

#import "CreateStoryViewController.h"
#import "CreateStoryWithVoiceViewController.h"
#import "BottomPickerView.h"
#import "VoiceInputView.h"
#import "LGBaseAlertView.h"
#import "VoiceStoryModel.h"
#import <Speech/Speech.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "AFStoryAPIManager.h"
#import "APIRequestModel.h"
#import "APIResponseModel.h"
#import "SelectAvatarVC.h"
#import "SelectIllustrationVC.h"

@interface CreateStoryViewController () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

// UI Components
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

// Card Containers
@property (nonatomic, strong) UIView *themeCardView;
@property (nonatomic, strong) UIView *illustrationCardView;
@property (nonatomic, strong) UIView *contentCardView;
@property (nonatomic, strong) UIView *typeCardView;
@property (nonatomic, strong) UIView *protagonistCardView;
@property (nonatomic, strong) UIView *lengthCardView;

// Story Theme
@property (nonatomic, strong) UILabel *themeLabel;
@property (nonatomic, strong) UITextView *themeTextView;
@property (nonatomic, strong) UILabel *themePlaceholderLabel;

// Story Illustration
@property (nonatomic, strong) UILabel *illustrationLabel;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) UIButton *removeImageButton;
@property (nonatomic, strong) UILabel *addImageLabel;
@property (nonatomic, strong) UIImageView *addImageIcon;

// Story Content
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIButton *voiceInputButton;
@property (nonatomic, strong) UILabel *contentCharCountLabel;
@property (nonatomic, strong) UILabel *contentPlaceholderLabel;

// Story Type
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UIButton *typeButton;
@property (nonatomic, strong) UILabel *typeValueLabel;
@property (nonatomic, strong) UIImageView *typeChevronImageView;

// Story's Protagonist
@property (nonatomic, strong) UILabel *protagonistLabel;
@property (nonatomic, strong) UITextField *protagonistTextField;

// Story Length
@property (nonatomic, strong) UILabel *lengthLabel;
@property (nonatomic, strong) UIButton *lengthButton;
@property (nonatomic, strong) UILabel *lengthValueLabel;
@property (nonatomic, strong) UIImageView *lengthChevronImageView;

// Bottom Button
@property (nonatomic, strong) UIButton *nextButton;

// Data
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, copy) NSString *selectedIllustrationUrl;
@property (nonatomic, assign) NSInteger selectedTypeIndex;
@property (nonatomic, assign) NSInteger selectedLengthIndex;

// Speech Recognition
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) AVAudioEngine *audioEngine;

// 故事类型和时长数据
@property (nonatomic, strong) NSArray<NSString *> *storyTypes;
@property (nonatomic, strong) NSArray<NSString *> *storyLengths;

@end

@implementation CreateStoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航栏
    self.title = @"Create Story";
    self.view.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0]];
    
    // 自定义返回按钮，拦截返回事件
    [self setupCustomBackButton];
    
    // 初始化数据
    [self setupData];
    
    [self setupUI];
    [self setupSpeechRecognition];
    
    // ✅ UI 创建完成后，如果有传入的故事模型，设置表单数据
    if (self.storyModel) {
        [self setupFormWithStoryModel:self.storyModel];
    }
    
    // 添加键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 设置滑动返回手势代理，以便拦截滑动返回
    if (@available(iOS 7.0, *)) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 重置滑动返回手势代理
    if (@available(iOS 7.0, *)) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup Methods

- (void)setupCustomBackButton {
    // 隐藏默认的返回按钮
    self.navigationItem.hidesBackButton = YES;
    
    // 创建自定义返回按钮
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(customBackButtonTapped)];
    backButton.tintColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)customBackButtonTapped {
    [self.view endEditing:YES];
    
    // 检查是否有输入内容
    if ([self hasUserInput]) {
        [self showDiscardChangesAlert];
    } else {
        [self goBack];
    }
}

/// 检查用户是否有输入内容
- (BOOL)hasUserInput {
    // 检查故事主题
    if (self.themeTextView.text.length > 0) {
        return YES;
    }
    
    // 检查是否选择了图片
    if (self.selectedImage || self.selectedIllustrationUrl) {
        return YES;
    }
    
    // 检查故事内容
    if (self.contentTextView.text.length > 0) {
        return YES;
    }
    
    // 检查故事类型是否已选择
    if (self.selectedTypeIndex >= 0) {
        return YES;
    }
    
    // 检查主角名称
    if (self.protagonistTextField.text.length > 0) {
        return YES;
    }
    
    // 检查故事长度是否已选择
    if (self.selectedLengthIndex >= 0) {
        return YES;
    }
    
    return NO;
}

/// 显示放弃更改的确认弹窗
- (void)showDiscardChangesAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"放弃更改？"
                                                                   message:@"你有未保存的内容，确定要离开吗？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // 取消按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    // 确认离开按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"离开"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self goBack];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/// 执行返回操作
- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupData {
    // 初始化故事类型数据
    self.storyTypes = @[@"Fairy Tale", @"Fable", @"Adventure", @"Superhero", @"Science Fiction", @"Educational", @"Bedtime Story"];
    
    // 初始化故事时长数据
    self.storyLengths = @[@"1min 30s", @"3min", @"4.5min", @"6min"];
    
    // 默认值
    self.selectedTypeIndex = -1;
    self.selectedLengthIndex = -1;
}

- (void)setupUI {
    // ScrollView
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:self.scrollView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-90);
    }];
    
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    // Story Theme
    [self setupThemeSection];
    
    // Story Illustration
    [self setupIllustrationSection];
    
    // Story Content
    [self setupContentSection];
    
    // Story Type
    [self setupTypeSection];
    
    // Story's Protagonist
    [self setupProtagonistSection];
    
    // Story Length
    [self setupLengthSection];
    
    // Next Button
    [self setupNextButton];
}

#pragma mark - Setup Sections

- (void)setupThemeSection {
    // 白色卡片容器
    self.themeCardView = [[UIView alloc] init];
    self.themeCardView.backgroundColor = [UIColor whiteColor];
    self.themeCardView.layer.cornerRadius = 12;
    self.themeCardView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.themeCardView];
    
    [self.themeCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(16);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.height.mas_greaterThanOrEqualTo(80);
    }];
    
    // 标题（放在卡片内部顶部）
    self.themeLabel = [[UILabel alloc] init];
    self.themeLabel.text = @"Story Theme";
    self.themeLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.themeLabel.textColor = [UIColor blackColor];
    [self.themeCardView addSubview:self.themeLabel];
    
    [self.themeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.themeCardView).offset(16);
        make.left.equalTo(self.themeCardView).offset(16);
        make.right.equalTo(self.themeCardView).offset(-16);
    }];
    
    // 输入框（使用 UITextView 以支持多行）
    self.themeTextView = [[UITextView alloc] init];
    self.themeTextView.font = [UIFont systemFontOfSize:15];
    self.themeTextView.textColor = [UIColor blackColor];
    self.themeTextView.backgroundColor = [UIColor clearColor];
    self.themeTextView.textContainerInset = UIEdgeInsetsMake(8, 12, 16, 12);
    self.themeTextView.delegate = self;
    self.themeTextView.scrollEnabled = NO;
    [self.themeCardView addSubview:self.themeTextView];
    
    [self.themeTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.themeLabel.mas_bottom).offset(4);
        make.left.equalTo(self.themeCardView).offset(4);
        make.right.equalTo(self.themeCardView).offset(-4);
        make.bottom.equalTo(self.themeCardView).offset(-4);
    }];
    
    // Placeholder
    self.themePlaceholderLabel = [[UILabel alloc] init];
    self.themePlaceholderLabel.text = @"Please Input,不超过120字符";
    self.themePlaceholderLabel.font = [UIFont systemFontOfSize:15];
    self.themePlaceholderLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1];
    self.themePlaceholderLabel.userInteractionEnabled = NO;
    [self.themeCardView addSubview:self.themePlaceholderLabel];
    
    [self.themePlaceholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.themeTextView).offset(16);
        make.top.equalTo(self.themeTextView).offset(8);
    }];
}

- (void)setupIllustrationSection {
    // 白色卡片容器
    self.illustrationCardView = [[UIView alloc] init];
    self.illustrationCardView.backgroundColor = [UIColor whiteColor];
    self.illustrationCardView.layer.cornerRadius = 12;
    self.illustrationCardView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.illustrationCardView];
    
    [self.illustrationCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.themeCardView.mas_bottom).offset(24);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo(138);
    }];
    
    // 标题（放在卡片内部顶部）
    self.illustrationLabel = [[UILabel alloc] init];
    self.illustrationLabel.text = @"Story Header";
    self.illustrationLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.illustrationLabel.textColor = [UIColor blackColor];
    self.illustrationLabel.numberOfLines = 0;
    [self.illustrationCardView addSubview:self.illustrationLabel];
    
    [self.illustrationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.illustrationCardView).offset(16);
        make.left.equalTo(self.illustrationCardView).offset(16);
        make.right.lessThanOrEqualTo(self.illustrationCardView).offset(-16);
    }];
    
    // 为了确保标题有足够的高度，我们手动设置一个固定的约束
    [self.illustrationLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.illustrationLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    // 图片容器
    self.imageContainerView = [[UIView alloc] init];
    self.imageContainerView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    self.imageContainerView.layer.cornerRadius = 8;
    self.imageContainerView.layer.masksToBounds = YES;
    self.imageContainerView.userInteractionEnabled = YES;
    [self.illustrationCardView addSubview:self.imageContainerView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImageButtonTapped)];
    [self.imageContainerView addGestureRecognizer:tapGesture];
    
    [self.imageContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.illustrationCardView).offset(16);
        make.top.equalTo(self.illustrationLabel.mas_bottom).offset(12);
        make.width.height.mas_equalTo(76);
        make.bottom.lessThanOrEqualTo(self.illustrationCardView).offset(-16);
    }];
    
    // 添加图片图标
    self.addImageIcon = [[UIImageView alloc] init];
    self.addImageIcon.image = [UIImage systemImageNamed:@"plus"];
    self.addImageIcon.tintColor = [UIColor colorWithWhite:0.6 alpha:1];
    [self.imageContainerView addSubview:self.addImageIcon];
    
    [self.addImageIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.imageContainerView);
        make.centerY.equalTo(self.imageContainerView).offset(-10);
        make.width.height.mas_equalTo(24);
    }];
    
    // 添加图片文字
    self.addImageLabel = [[UILabel alloc] init];
    self.addImageLabel.text = @"添加图片";
    self.addImageLabel.font = [UIFont systemFontOfSize:12];
    self.addImageLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1];
    self.addImageLabel.textAlignment = NSTextAlignmentCenter;
    [self.imageContainerView addSubview:self.addImageLabel];
    
    [self.addImageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.imageContainerView);
        make.top.equalTo(self.addImageIcon.mas_bottom).offset(4);
    }];
    
    // 选中的图片视图
    self.selectedImageView = [[UIImageView alloc] init];
    self.selectedImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.selectedImageView.clipsToBounds = YES;
    self.selectedImageView.hidden = YES;
    [self.imageContainerView addSubview:self.selectedImageView];
    
    [self.selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.imageContainerView);
    }];
    
    // 删除按钮（X）
    self.removeImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.removeImageButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.removeImageButton.layer.cornerRadius = 12;
    [self.removeImageButton setImage:[UIImage systemImageNamed:@"xmark"] forState:UIControlStateNormal];
    self.removeImageButton.tintColor = [UIColor whiteColor];
    [self.removeImageButton addTarget:self action:@selector(removeImageButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.removeImageButton.hidden = YES;
    // ✅ 添加到背景卡片中，避免被图层截断
    [self.illustrationCardView addSubview:self.removeImageButton];
    
    [self.removeImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        // ✅ 相对于图片容器定位，但约束到背景卡片，避免被截断
        make.top.equalTo(self.imageContainerView).offset(-12);
        make.left.equalTo(self.imageContainerView.mas_right).offset(-12);
        make.width.height.mas_equalTo(24);
    }];
}

- (void)setupContentSection {
    // 白色卡片容器
    self.contentCardView = [[UIView alloc] init];
    self.contentCardView.backgroundColor = [UIColor whiteColor];
    self.contentCardView.layer.cornerRadius = 12;
    self.contentCardView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.contentCardView];
    
    [self.contentCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.illustrationCardView.mas_bottom).offset(24);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo(180);
    }];
    
    // 标题（放在卡片内部顶部）
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.text = @"Story Content";
    self.contentLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.contentLabel.textColor = [UIColor blackColor];
    [self.contentCardView addSubview:self.contentLabel];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentCardView).offset(16);
        make.left.equalTo(self.contentCardView).offset(16);
        make.right.equalTo(self.contentCardView).offset(-16);
    }];
    
    // 内容输入框
    self.contentTextView = [[UITextView alloc] init];
    self.contentTextView.font = [UIFont systemFontOfSize:15];
    self.contentTextView.textColor = [UIColor blackColor];
    self.contentTextView.backgroundColor = [UIColor clearColor];
    self.contentTextView.textContainerInset = UIEdgeInsetsMake(8, 12, 40, 12);
    self.contentTextView.delegate = self;
    [self.contentCardView addSubview:self.contentTextView];
    
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLabel.mas_bottom).offset(4);
        make.left.equalTo(self.contentCardView).offset(4);
        make.right.equalTo(self.contentCardView).offset(-4);
        make.bottom.equalTo(self.contentCardView).offset(-4);
    }];
    
    // Placeholder
    self.contentPlaceholderLabel = [[UILabel alloc] init];
    self.contentPlaceholderLabel.text = @"Please Input";
    self.contentPlaceholderLabel.font = [UIFont systemFontOfSize:15];
    self.contentPlaceholderLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1];
    self.contentPlaceholderLabel.userInteractionEnabled = NO;
    [self.contentCardView addSubview:self.contentPlaceholderLabel];
    
    [self.contentPlaceholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentTextView).offset(16);
        make.top.equalTo(self.contentTextView).offset(8);
    }];
    
    // 字数统计
    self.contentCharCountLabel = [[UILabel alloc] init];
    self.contentCharCountLabel.text = @"0/2400";
    self.contentCharCountLabel.font = [UIFont systemFontOfSize:12];
    self.contentCharCountLabel.textColor = [UIColor systemGrayColor];
    [self.contentCardView addSubview:self.contentCharCountLabel];
    
    [self.contentCharCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        // ✅ 字数统计移到右边
        make.right.equalTo(self.contentCardView).offset(-16);
        make.bottom.equalTo(self.contentCardView).offset(-12);
    }];
    
    // 麦克风按钮
    self.voiceInputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.voiceInputButton setImage:[UIImage systemImageNamed:@"mic.fill"] forState:UIControlStateNormal];
    self.voiceInputButton.tintColor = [UIColor systemGrayColor];
    
    // 点击显示语音输入界面
    [self.voiceInputButton addTarget:self action:@selector(voiceInputButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentCardView addSubview:self.voiceInputButton];
    
    [self.voiceInputButton mas_makeConstraints:^(MASConstraintMaker *make) {
        // ✅ 麦克风按钮移到左边，字数统计标签的左侧
        make.right.equalTo(self.contentCharCountLabel.mas_left).offset(-8);
        make.centerY.equalTo(self.contentCharCountLabel);
        make.width.height.mas_equalTo(24);
    }];
}

- (void)setupTypeSection {
    // 白色卡片容器
    self.typeCardView = [[UIView alloc] init];
    self.typeCardView.backgroundColor = [UIColor whiteColor];
    self.typeCardView.layer.cornerRadius = 12;
    self.typeCardView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.typeCardView];
    
    [self.typeCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentCardView.mas_bottom).offset(24);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo(52);
    }];
    
    // 标题（放在卡片内部左侧）
    self.typeLabel = [[UILabel alloc] init];
    self.typeLabel.text = @"Story Type";
    self.typeLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.typeLabel.textColor = [UIColor blackColor];
    [self.typeCardView addSubview:self.typeLabel];
    
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.typeCardView).offset(16);
        make.centerY.equalTo(self.typeCardView);
    }];
    
    // 可点击按钮（透明覆盖整个卡片）
    self.typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.typeButton addTarget:self action:@selector(typeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.typeCardView addSubview:self.typeButton];
    
    [self.typeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.typeCardView);
    }];
    
    // 右箭头
    self.typeChevronImageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    self.typeChevronImageView.tintColor = [UIColor systemGrayColor];
    self.typeChevronImageView.userInteractionEnabled = NO;
    [self.typeCardView addSubview:self.typeChevronImageView];
    
    [self.typeChevronImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.typeCardView).offset(-16);
        make.centerY.equalTo(self.typeCardView);
        make.width.mas_equalTo(8);
        make.height.mas_equalTo(14);
    }];
    
    // 值标签（放在右侧，箭头左边）
    self.typeValueLabel = [[UILabel alloc] init];
    self.typeValueLabel.text = @"Please Select";
    self.typeValueLabel.font = [UIFont systemFontOfSize:15];
    self.typeValueLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1];
    self.typeValueLabel.textAlignment = NSTextAlignmentRight;
    self.typeValueLabel.userInteractionEnabled = NO;
    [self.typeCardView addSubview:self.typeValueLabel];
    
    [self.typeValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.typeChevronImageView.mas_left).offset(-8);
        make.centerY.equalTo(self.typeCardView);
        make.left.greaterThanOrEqualTo(self.typeLabel.mas_right).offset(16);
    }];
}

- (void)setupProtagonistSection {
    // 白色卡片容器
    self.protagonistCardView = [[UIView alloc] init];
    self.protagonistCardView.backgroundColor = [UIColor whiteColor];
    self.protagonistCardView.layer.cornerRadius = 12;
    self.protagonistCardView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.protagonistCardView];
    
    [self.protagonistCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.typeCardView.mas_bottom).offset(24);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo(52);
    }];
    
    // 标题（放在卡片内部左侧）
    self.protagonistLabel = [[UILabel alloc] init];
    self.protagonistLabel.text = @"Story's Protagonist";
    self.protagonistLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.protagonistLabel.textColor = [UIColor blackColor];
    [self.protagonistCardView addSubview:self.protagonistLabel];
    
    [self.protagonistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.protagonistCardView).offset(16);
        make.centerY.equalTo(self.protagonistCardView);
    }];
    
    // 输入框（放在右侧）
    self.protagonistTextField = [[UITextField alloc] init];
    self.protagonistTextField.font = [UIFont systemFontOfSize:15];
    self.protagonistTextField.textColor = [UIColor blackColor];
    self.protagonistTextField.textAlignment = NSTextAlignmentRight;
    self.protagonistTextField.placeholder = @"Please Input";
    self.protagonistTextField.delegate = self;
    [self.protagonistCardView addSubview:self.protagonistTextField];
    
    [self.protagonistTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.protagonistCardView).offset(-16);
        make.centerY.equalTo(self.protagonistCardView);
        make.left.greaterThanOrEqualTo(self.protagonistLabel.mas_right).offset(16);
        make.width.mas_greaterThanOrEqualTo(100); // 确保输入框有最小宽度
    }];
}

- (void)setupLengthSection {
    // 白色卡片容器
    self.lengthCardView = [[UIView alloc] init];
    self.lengthCardView.backgroundColor = [UIColor whiteColor];
    self.lengthCardView.layer.cornerRadius = 12;
    self.lengthCardView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.lengthCardView];
    
    [self.lengthCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.protagonistCardView.mas_bottom).offset(24);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo(52);
        make.bottom.equalTo(self.contentView).offset(-24);
    }];
    
    // 标题（放在卡片内部左侧）
    self.lengthLabel = [[UILabel alloc] init];
    self.lengthLabel.text = @"Story Length";
    self.lengthLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.lengthLabel.textColor = [UIColor blackColor];
    [self.lengthCardView addSubview:self.lengthLabel];
    
    [self.lengthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lengthCardView).offset(16);
        make.centerY.equalTo(self.lengthCardView);
    }];
    
    // 可点击按钮
    self.lengthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lengthButton addTarget:self action:@selector(lengthButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.lengthCardView addSubview:self.lengthButton];
    
    [self.lengthButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.lengthCardView);
    }];
    
    // 右箭头
    self.lengthChevronImageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    self.lengthChevronImageView.tintColor = [UIColor systemGrayColor];
    self.lengthChevronImageView.userInteractionEnabled = NO;
    [self.lengthCardView addSubview:self.lengthChevronImageView];
    
    [self.lengthChevronImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.lengthCardView).offset(-16);
        make.centerY.equalTo(self.lengthCardView);
        make.width.mas_equalTo(8);
        make.height.mas_equalTo(14);
    }];
    
    // 值标签（放在右侧，箭头左边）
    self.lengthValueLabel = [[UILabel alloc] init];
    self.lengthValueLabel.text = @"Please Select";
    self.lengthValueLabel.font = [UIFont systemFontOfSize:15];
    self.lengthValueLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1];
    self.lengthValueLabel.textAlignment = NSTextAlignmentRight;
    self.lengthValueLabel.userInteractionEnabled = NO;
    [self.lengthCardView addSubview:self.lengthValueLabel];
    
    [self.lengthValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.lengthChevronImageView.mas_left).offset(-8);
        make.centerY.equalTo(self.lengthCardView);
        make.left.greaterThanOrEqualTo(self.lengthLabel.mas_right).offset(16);
    }];
}

- (void)setupNextButton {
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextButton setTitle:@"Next Step" forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    self.nextButton.backgroundColor = [UIColor systemBlueColor];
    self.nextButton.layer.cornerRadius = 28;
    [self.nextButton addTarget:self action:@selector(nextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
    
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(27);
        make.right.equalTo(self.view).offset(-27);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-16);
        make.height.mas_equalTo(56);
    }];
}

#pragma mark - Actions

- (void)addImageButtonTapped {
    [self.view endEditing:YES];
    
    [self showIllustrationPicker];
}

- (void)showIllustrationPicker {
    SelectIllustrationVC *vc = [[SelectIllustrationVC alloc] init];
    
    // 设置当前已选择的图片URL，以便在选择器中显示选中状态
    if (self.selectedIllustrationUrl && self.selectedIllustrationUrl.length > 0) {
        vc.imgUrl = self.selectedIllustrationUrl;
        NSLog(@"🖼️ 传递已选择的图片URL: %@", self.selectedIllustrationUrl);
    }
    
    // 设置回调
    vc.sureBlock = ^(NSString *imgUrl) {
        NSLog(@"选中的插画: %@", imgUrl);
        
        // 保存选中的插画URL
        self.selectedIllustrationUrl = imgUrl;
        
        // 使用插画URL设置按钮背景
        [self.selectedImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]
                                  placeholderImage:nil
                                           options:SDWebImageRefreshCached
                                         completed:nil];
        self.selectedImageView.hidden = NO;
        self.removeImageButton.hidden = NO;
        self.addImageIcon.hidden = YES;
        self.addImageLabel.hidden = YES;
        NSLog(@"✅ 插画已选中，URL已保存");
    };
    
    // 显示
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:vc animated:NO completion:^{
        [vc showView];
    }];
}

- (void)removeImageButtonTapped {
    self.selectedImage = nil;
    self.selectedIllustrationUrl = nil;
    self.selectedImageView.image = nil;
    self.selectedImageView.hidden = YES;
    self.removeImageButton.hidden = YES;
    self.addImageIcon.hidden = NO;
    self.addImageLabel.hidden = NO;
}

- (void)showImagePicker {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)voiceInputButtonTapped {
    [self.view endEditing:YES];
    
    // 检查语音识别权限
    SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
    
    if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
        // 请求权限
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus authStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (authStatus == SFSpeechRecognizerAuthorizationStatusAuthorized) {
                    [self showVoiceInputView];
                } else {
                    [self showVoicePermissionDeniedAlert];
                }
            });
        }];
    } else if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
        [self showVoiceInputView];
    } else {
        [self showVoicePermissionDeniedAlert];
    }
}

- (void)showVoiceInputView {
    NSLog(@"🎤 显示语音输入界面");
    
    // 使用 VoiceInputView 实现录音功能
    VoiceInputView *voiceView = [[VoiceInputView alloc]
        initWithCompletionBlock:^(NSString *text) {
            // ✅ 录音完成，将文字插入到当前光标位置或覆盖选中文字
            [self insertVoiceTextToContentTextView:text];
        } 
        cancelBlock:^{
            // 处理取消操作
            NSLog(@"🎤 语音录制取消");
        }];
    
    [voiceView show];
}

- (void)showVoicePermissionDeniedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否允许Tanlepal录制音频"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"仅使用期间允许"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                           options:@{}
                                 completionHandler:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"本次使用允许"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                           options:@{}
                                 completionHandler:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"禁止"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}



/// 将语音识别的文字插入到文本视图中，并更新字数统计
- (void)insertVoiceTextToContentTextView:(NSString *)recognizedText {
    if (!recognizedText || recognizedText.length == 0) {
        return;
    }
    
    // 获取当前文本和光标位置
    NSString *currentText = self.contentTextView.text ?: @"";
    NSRange selectedRange = self.contentTextView.selectedRange;
    
    // 在光标位置插入或替换文字
    NSString *newText;
    if (selectedRange.length > 0) {
        // 如果有选中文字，替换选中部分
        newText = [currentText stringByReplacingCharactersInRange:selectedRange withString:recognizedText];
    } else {
        // 在光标位置插入文字
        NSMutableString *mutableText = [currentText mutableCopy];
        [mutableText insertString:recognizedText atIndex:selectedRange.location];
        newText = [mutableText copy];
    }
    
    // 检查字数限制
    if (newText.length > 2400) {
        newText = [newText substringToIndex:2400];
        
        // 提示用户字数限制
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"内容已达到2400字符限制"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    // 更新文本视图
    self.contentTextView.text = newText;
    
    // 更新placeholder显示状态
    self.contentPlaceholderLabel.hidden = newText.length > 0;
    
    // 更新字数统计
    self.contentCharCountLabel.text = [NSString stringWithFormat:@"%ld/2400", (long)newText.length];
    
    // 设置新的光标位置（在插入文字的末尾）
    NSInteger newCursorPosition = selectedRange.location + recognizedText.length;
    if (newCursorPosition > newText.length) {
        newCursorPosition = newText.length;
    }
    self.contentTextView.selectedRange = NSMakeRange(newCursorPosition, 0);
    
    NSLog(@"语音文字已插入，当前字数: %ld", (long)newText.length);
}

- (void)typeButtonTapped {
    [self.view endEditing:YES];
    
    BottomPickerView *picker = [[BottomPickerView alloc] initWithTitle:@"请选择故事类型"
                                                                options:self.storyTypes
                                                          selectedIndex:self.selectedTypeIndex
                                                            selectBlock:^(NSInteger selectedIndex, NSString *selectedValue) {
        self.selectedTypeIndex = selectedIndex;
        self.typeValueLabel.text = selectedValue;
        self.typeValueLabel.textColor = [UIColor blackColor];
    }];
    
    [picker show];
}

- (void)lengthButtonTapped {
    [self.view endEditing:YES];
    
    BottomPickerView *picker = [[BottomPickerView alloc] initWithTitle:@"请选择故事时长"
                                                                options:self.storyLengths
                                                          selectedIndex:self.selectedLengthIndex
                                                            selectBlock:^(NSInteger selectedIndex, NSString *selectedValue) {
        self.selectedLengthIndex = selectedIndex;
        self.lengthValueLabel.text = selectedValue;
        self.lengthValueLabel.textColor = [UIColor blackColor];
    }];
    
    [picker show];
}

- (void)nextButtonTapped {
    [self.view endEditing:YES];
    
    // 验证输入
    NSString *errorMessage = [self validateInputs];
    if (errorMessage) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:errorMessage
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // 创建故事请求
    [self createStoryRequest];
}

- (NSString *)validateInputs {
    // 验证故事名称
    if (self.themeTextView.text.length == 0) {
        return @"请输入故事名称";
    }
    if (self.themeTextView.text.length > 120) {
        return @"故事名称不超过120字符";
    }
    
    // 验证插图
    if (!self.selectedImage && !self.selectedIllustrationUrl) {
        return @"请选择故事插图";
    }
    
    // 验证故事内容
    if (self.contentTextView.text.length == 0) {
        return @"请输入故事内容";
    }
    if (self.contentTextView.text.length > 2400) {
        return @"故事内容不超过2400字符";
    }
    
    // 验证故事类型
    if (self.selectedTypeIndex < 0) {
        return @"请选择故事类型";
    }
    
    // 验证主角名称
    if (self.protagonistTextField.text.length == 0) {
        return @"请输入故事主角";
    }
    if (self.protagonistTextField.text.length > 30) {
        return @"故事主角不超过30字符";
    }
    
    // 验证故事时长
    if (self.selectedLengthIndex < 0) {
        return @"请选择故事时长";
    }
    
    return nil;
}

- (void)createStoryRequest {
    // 显示加载提示
    [self showLoadingAlert];
    
    // 转换参数
    NSArray *lengthValues = @[@90, @180, @270, @360];
    NSInteger storyLength = [lengthValues[self.selectedLengthIndex] integerValue];
    StoryType storyType = (StoryType)(self.selectedTypeIndex + 1);
    
    // 创建请求模型
    CreateStoryRequestModel *request = [[CreateStoryRequestModel alloc]
        initWithName:self.themeTextView.text
             summary:self.contentTextView.text
                type:storyType
      protagonistName:self.protagonistTextField.text
              length:storyLength
      illustrationUrl:self.selectedIllustrationUrl ?: @"/illustration/001.png"];
    
     //验证请求模型
    if (![request isValid]) {
        [self hideLoadingAlert];
        [self showErrorAlert:[request validationError]];
        return;
    }
    
    // 调用API
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] createStory:request
                                           success:^(APIResponseModel *response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [strongSelf hideLoadingAlert];
        
        if (response.isSuccess) {
            NSLog(@"✅ 故事创建成功");
            [strongSelf handleCreateStorySuccess:response];
        } else {
            NSLog(@"❌ 故事创建失败: %@", response.errorMessage);
            [strongSelf showErrorAlert:response.errorMessage];
        }
        
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [strongSelf hideLoadingAlert];
//        NSLog(@"❌ 网络请求失败: %@", error.localizedDescription);
//        [strongSelf showErrorAlert:error.localizedDescription];
    }];
}
- (void)handleCreateStorySuccess:(APIResponseModel *)response {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"创建成功"
                                                                   message:@"故事已开始生成，可在故事列表中查看"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"查看故事"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showLoadingAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"正在创建故事...\n\n"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    [alert.view addSubview:indicator];
    
    [NSLayoutConstraint activateConstraints:@[
        [indicator.centerXAnchor constraintEqualToAnchor:alert.view.centerXAnchor],
        [indicator.bottomAnchor constraintEqualToAnchor:alert.view.bottomAnchor constant:-20]
    ]];
    
    [indicator startAnimating];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)hideLoadingAlert {
    if (self.presentedViewController && [self.presentedViewController isKindOfClass:[UIAlertController class]]) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showErrorAlert:(NSString *)errorMessage {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"创建失败"
                                                                   message:errorMessage ?: @"请稍后重试"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.selectedImage = image;
    self.selectedImageView.image = image;
    self.selectedImageView.hidden = NO;
    self.removeImageButton.hidden = NO;
    self.addImageIcon.hidden = YES;
    self.addImageLabel.hidden = YES;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if (textView == self.themeTextView) {
        // 更新placeholder
        self.themePlaceholderLabel.hidden = textView.text.length > 0;
        
        // 限制字数
        if (textView.text.length > 120) {
            textView.text = [textView.text substringToIndex:120];
        }
    } else if (textView == self.contentTextView) {
        // 更新placeholder
        self.contentPlaceholderLabel.hidden = textView.text.length > 0;
        
        // 更新字数统计
        NSInteger length = textView.text.length;
        if (length > 2400) {
            textView.text = [textView.text substringToIndex:2400];
            length = 2400;
        }
        self.contentCharCountLabel.text = [NSString stringWithFormat:@"%ld/2400", (long)length];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.protagonistTextField) {
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return newText.length <= 30;
    }
    return YES;
}

#pragma mark - Speech Recognition

- (void)setupSpeechRecognition {
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    self.audioEngine = [[AVAudioEngine alloc] init];
}

#pragma mark - UIGestureRecognizerDelegate

/// 拦截滑动返回手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (@available(iOS 7.0, *)) {
        if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
            // 如果有用户输入，阻止滑动返回并显示确认弹窗
            if ([self hasUserInput]) {
                [self showDiscardChangesAlert];
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight - 80, 0);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.contentInset = UIEdgeInsetsZero;
    }];
}

#pragma mark - Story Model Setup

/// 根据传入的故事模型设置表单字段（用于生成失败后重新编辑）
- (void)setupFormWithStoryModel:(VoiceStoryModel *)storyModel {
    NSLog(@"🔄 设置表单字段 - 故事: %@, 状态: %ld", storyModel.storyName, (long)storyModel.storyStatus);
    
    [self setFormFieldsWithStoryModel:storyModel];
}

/// 设置表单字段的具体实现
- (void)setFormFieldsWithStoryModel:(VoiceStoryModel *)storyModel {
    
    // 1. 设置故事主题（标题）
    if (storyModel.storyName && storyModel.storyName.length > 0) {
        self.themeTextView.text = storyModel.storyName;
        self.themePlaceholderLabel.hidden = YES;
        NSLog(@"✅ 设置故事主题: %@", storyModel.storyName);
    }
    
    // 2. 设置故事内容（摘要）
    if (storyModel.storySummary && storyModel.storySummary.length > 0) {
        self.contentTextView.text = storyModel.storySummary;
        self.contentPlaceholderLabel.hidden = YES;
        [self updateContentCharCount];
        NSLog(@"✅ 设置故事内容: %@", [storyModel.storySummary substringToIndex:MIN(50, storyModel.storySummary.length)]);
    }
    
    // 3. 设置主角名称
    if (storyModel.protagonistName && storyModel.protagonistName.length > 0) {
        self.protagonistTextField.text = storyModel.protagonistName;
        NSLog(@"✅ 设置主角名称: %@", storyModel.protagonistName);
    }
    
    // 4. 设置故事类型
    if (storyModel.storyType > 0 && storyModel.storyType <= self.storyTypes.count) {
        self.selectedTypeIndex = storyModel.storyType - 1; // 转换为数组索引
        self.typeValueLabel.text = self.storyTypes[self.selectedTypeIndex];
        self.typeValueLabel.textColor = [UIColor blackColor]; // 设置选中后的颜色
        NSLog(@"✅ 设置故事类型: %@ (索引: %ld)", self.storyTypes[self.selectedTypeIndex], (long)self.selectedTypeIndex);
    }
    
    // 5. 设置故事长度（根据 storyLength 匹配）
    [self setStoryLengthFromModel:storyModel.storyLength];
    
    // 6. 设置插图
    if (storyModel.illustrationUrl && storyModel.illustrationUrl.length > 0) {
        [self setIllustrationFromURL:storyModel.illustrationUrl];
    }
    
    // 7. 更新导航栏标题，表明这是编辑模式
    self.title = @"Edit Story";
    
    NSLog(@"🎯 表单字段设置完成");
}

/// 根据故事长度设置对应的选项
- (void)setStoryLengthFromModel:(NSInteger)storyLength {
    // 故事长度映射：90s=1min30s, 180s=3min, 270s=4.5min, 360s=6min
    NSArray *lengthValues = @[@(90), @(180), @(270), @(360)]; // 对应的秒数
    
    for (NSInteger i = 0; i < lengthValues.count; i++) {
        if ([lengthValues[i] integerValue] == storyLength) {
            self.selectedLengthIndex = i;
            self.lengthValueLabel.text = self.storyLengths[i];
            self.lengthValueLabel.textColor = [UIColor blackColor]; // 设置选中后的颜色
            NSLog(@"✅ 设置故事长度: %@ (索引: %ld, 原始值: %lds)", self.storyLengths[i], (long)i, (long)storyLength);
            return;
        }
    }
    
    // 如果没有匹配的长度，设置为默认值
    NSLog(@"⚠️ 未找到匹配的故事长度: %lds，使用默认值", (long)storyLength);
}

/// 从URL设置插图
- (void)setIllustrationFromURL:(NSString *)illustrationUrl {
    self.selectedIllustrationUrl = illustrationUrl;
    
    // 显示网络图片
    [self.selectedImageView sd_setImageWithURL:[NSURL URLWithString:illustrationUrl]
                              placeholderImage:[UIImage imageNamed:@"placeholder_image"]
                                     completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            // 成功加载图片，更新 UI
            self.selectedImageView.hidden = NO;
            self.removeImageButton.hidden = NO;
            self.addImageLabel.hidden = YES;
            self.addImageIcon.hidden = YES;
            NSLog(@"✅ 设置插图: %@", illustrationUrl);
        } else {
            NSLog(@"⚠️ 插图加载失败: %@, 错误: %@", illustrationUrl, error.localizedDescription);
        }
    }];
}

/// 更新内容字数统计
- (void)updateContentCharCount {
    NSInteger currentLength = self.contentTextView.text.length;
    NSInteger maxLength = 2400;
    self.contentCharCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)currentLength, (long)maxLength];
    
    if (currentLength > maxLength) {
        self.contentCharCountLabel.textColor = [UIColor systemRedColor];
    } else {
        self.contentCharCountLabel.textColor = [UIColor systemGrayColor];
    }
}

@end
