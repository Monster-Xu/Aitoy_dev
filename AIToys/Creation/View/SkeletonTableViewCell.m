// SkeletonTableViewCell.m
#import "SkeletonTableViewCell.h"
#import "SkeletonView.h"

@interface SkeletonTableViewCell ()

@property (nonatomic, strong) SkeletonView *avatarSkeleton;
@property (nonatomic, strong) SkeletonView *titleSkeleton;
@property (nonatomic, strong) SkeletonView *subtitleSkeleton;
@property (nonatomic, strong) SkeletonView *contentSkeleton;
@property (nonatomic, assign) SkeletonCellStyle cellStyle;

@end

@implementation SkeletonTableViewCell

- (instancetype)initWithStyle:(SkeletonCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellStyle = style;
        [self setupUI];
        [self configureWithStyle:style];
    }
    return self;
}

- (void)setupUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    
    // 创建鱼骨视图
    self.avatarSkeleton = [[SkeletonView alloc] init];
    self.titleSkeleton = [[SkeletonView alloc] init];
    self.subtitleSkeleton = [[SkeletonView alloc] init];
    self.contentSkeleton = [[SkeletonView alloc] init];
    
    [self.contentView addSubview:self.avatarSkeleton];
    [self.contentView addSubview:self.titleSkeleton];
    [self.contentView addSubview:self.subtitleSkeleton];
    [self.contentView addSubview:self.contentSkeleton];
}

- (void)configureWithStyle:(SkeletonCellStyle)style {
    // 先隐藏所有视图
    self.avatarSkeleton.hidden = YES;
    self.titleSkeleton.hidden = YES;
    self.subtitleSkeleton.hidden = YES;
    self.contentSkeleton.hidden = YES;
    
    switch (style) {
        case SkeletonCellStyleDefault: {
            // 标题 + 副标题
            self.titleSkeleton.hidden = NO;
            self.subtitleSkeleton.hidden = NO;
            
            self.titleSkeleton.frame = CGRectMake(16, 12, 200, 20);
            self.subtitleSkeleton.frame = CGRectMake(16, 40, 150, 16);
            break;
        }
            
        case SkeletonCellStyleWithAvatar: {
            // 头像 + 标题 + 副标题
            self.avatarSkeleton.hidden = NO;
            self.titleSkeleton.hidden = NO;
            self.subtitleSkeleton.hidden = NO;
            
            self.avatarSkeleton.frame = CGRectMake(16, 12, 40, 40);
            self.avatarSkeleton.layer.cornerRadius = 20;
            self.avatarSkeleton.layer.masksToBounds = YES;
            
            self.titleSkeleton.frame = CGRectMake(72, 12, 120, 18);
            self.subtitleSkeleton.frame = CGRectMake(72, 36, 80, 14);
            break;
        }
            
        case SkeletonCellStyleDetail: {
            // 头像 + 标题 + 内容
            self.avatarSkeleton.hidden = NO;
            self.titleSkeleton.hidden = NO;
            self.contentSkeleton.hidden = NO;
            
            self.avatarSkeleton.frame = CGRectMake(16, 16, 50, 50);
            self.avatarSkeleton.layer.cornerRadius = 25;
            self.avatarSkeleton.layer.masksToBounds = YES;
            
            self.titleSkeleton.frame = CGRectMake(82, 16, 200, 20);
            self.contentSkeleton.frame = CGRectMake(82, 44, 260, 16);
            break;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self configureWithStyle:self.cellStyle];
}

- (void)startSkeletonAnimation {
    [self.avatarSkeleton startAnimating];
    [self.titleSkeleton startAnimating];
    [self.subtitleSkeleton startAnimating];
    [self.contentSkeleton startAnimating];
}

- (void)stopSkeletonAnimation {
    [self.avatarSkeleton stopAnimating];
    [self.titleSkeleton stopAnimating];
    [self.subtitleSkeleton stopAnimating];
    [self.contentSkeleton stopAnimating];
}

@end
