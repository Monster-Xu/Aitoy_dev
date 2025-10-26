//
//  BottomPickerView.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//

#import "BottomPickerView.h"
#import <Masonry/Masonry.h>

@interface BottomPickerView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, strong) NSArray<NSString *> *options;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) BottomPickerViewSelectBlock selectBlock;

@end

@implementation BottomPickerView

- (instancetype)initWithTitle:(NSString *)title
                      options:(NSArray<NSString *> *)options
                selectedIndex:(NSInteger)selectedIndex
                  selectBlock:(BottomPickerViewSelectBlock)selectBlock {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _titleText = title;
        _options = options;
        _selectedIndex = selectedIndex;
        _selectBlock = selectBlock;
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 半透明黑色蒙层
    self.overlayView = [[UIView alloc] init];
    self.overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.overlayView.alpha = 0;
    [self addSubview:self.overlayView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTapped)];
    [self.overlayView addGestureRecognizer:tapGesture];
    
    [self.overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // 底部容器
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.containerView.layer.cornerRadius = 20;
//    self.containerView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.containerView.layer.masksToBounds = YES;
    [self addSubview:self.containerView];
    
    // 计算容器高度
    CGFloat maxHeight = [UIScreen mainScreen].bounds.size.height * 0.7;
    CGFloat optionHeight = 52.0;
    CGFloat titleHeight = 60.0;
    CGFloat cancelButtonHeight = 56.0;
    CGFloat bottomSafeArea = 0;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        bottomSafeArea = window.safeAreaInsets.bottom;
    }
    
    CGFloat tableHeight = MIN(self.options.count * optionHeight, maxHeight - titleHeight - cancelButtonHeight - bottomSafeArea - 20);
    CGFloat containerHeight = titleHeight + tableHeight + cancelButtonHeight;
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.right.equalTo(self).offset(-16);
        make.bottom.equalTo(self).offset(-34);
        make.height.mas_equalTo(containerHeight);
    }];
    
    // 标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.titleText;
    self.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(0);
        make.left.equalTo(self.containerView).offset(0);
        make.right.equalTo(self.containerView).offset(0);
        make.height.mas_equalTo(54);
    }];
    
    // TableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.showsVerticalScrollIndicator = YES;
    self.tableView.bounces = YES;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PickerCell"];
    [self.containerView addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(0);
        make.left.right.equalTo(self.containerView);
        make.height.mas_equalTo(tableHeight);
    }];
    
    // 取消按钮
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
    self.cancelButton.backgroundColor = [UIColor whiteColor];
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.cancelButton];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom).offset(10);
        make.left.right.equalTo(self.containerView);
        make.height.mas_equalTo(cancelButtonHeight);
    }];
    
    // 初始位置在屏幕下方
    self.containerView.transform = CGAffineTransformMakeTranslation(0, containerHeight);
}

#pragma mark - Public Methods

- (void)show {
    // 添加到window
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    [window addSubview:self];
    
    // 动画显示
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.overlayView.alpha = 1;
        self.containerView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)dismiss {
    CGFloat containerHeight = CGRectGetHeight(self.containerView.frame);
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.overlayView.alpha = 0;
        self.containerView.transform = CGAffineTransformMakeTranslation(0, containerHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Actions

- (void)overlayTapped {
    [self dismiss];
}

- (void)cancelButtonTapped {
    [self dismiss];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PickerCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.options[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    // 设置选中状态样式
    if (indexPath.row == self.selectedIndex) {
        cell.textLabel.textColor = [UIColor systemBlueColor];
        cell.textLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectBlock) {
        self.selectBlock(indexPath.row, self.options[indexPath.row]);
    }
    [self dismiss];
}

@end
