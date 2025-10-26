//
//  SelectBirthdayView.m
//  AIToys
//
//  Created by qdkj on 2025/8/13.
//

#import "SelectBirthdayView.h"
#import "NSDate+YYAdd.h"

@interface SelectBirthdayView()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSMutableArray *years;

@property (nonatomic, copy) NSString *selMonth;
@property (nonatomic, copy) NSString *selYear;
@property (nonatomic, strong) NSDate *selectedDate;

@end

@implementation SelectBirthdayView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle]loadNibNamed:@"SelectBirthdayView" owner:nil options:nil]objectAtIndex:0];
        self.frame = frame;
        [self setupUI];
        [self setupInitialValues];
    }
    return self;
}

- (void)setupUI {
    self.titleLabel.text = LocalString(@"选择出生日期");
    [self.sureBtn setTitle:LocalString(@"确定") forState:0];
    [self.cancelBtn setTitle:LocalString(@"取消") forState:0];
    self.pickerView = [[UIPickerView alloc] initWithFrame:self.containerView.bounds];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.containerView addSubview:self.pickerView];
    
    self.months = @[@"January", @"February", @"March", @"April",
                   @"May", @"June", @"July", @"August",
                   @"September", @"October", @"November", @"December"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger currentYear = [components year];
    
    self.years = [NSMutableArray array];
    for (NSInteger year = currentYear - 100; year <= currentYear; year++) {
        [self.years addObject:[NSString stringWithFormat:@"%ld", (long)year]];
    }
}

- (void)setupInitialValues {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]];
    NSInteger currentYear = [components year];
    NSInteger currentMonth = [components month];
    
    NSInteger yearIndex = [self.years indexOfObject:[NSString stringWithFormat:@"%ld", (long)currentYear]];
    [self.pickerView selectRow:yearIndex inComponent:1 animated:NO];
    [self.pickerView selectRow:currentMonth-1 inComponent:0 animated:NO];
    self.selectedDate = [NSDate date];
    self.selYear = self.years[yearIndex];
    self.selMonth = self.months[currentMonth-1];
}

-(void)setDefalutDate:(NSDate *)defalutDate{
    _defalutDate = defalutDate;
    self.selectedDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:defalutDate];
    NSInteger currentYear = [components year];
    NSInteger currentMonth = [components month];
    
    NSInteger yearIndex = [self.years indexOfObject:[NSString stringWithFormat:@"%ld", (long)currentYear]];
    [self.pickerView selectRow:yearIndex inComponent:1 animated:NO];
    [self.pickerView selectRow:currentMonth-1 inComponent:0 animated:NO];
    self.selYear = self.years[yearIndex];
    self.selMonth = self.months[currentMonth-1];
}

//取消
- (IBAction)cancelBtnClick:(id)sender {
    [self hide];
}


//确定
- (IBAction)sureBtnClick:(id)sender {
    NSString *dateStr = [NSString stringWithFormat:@"%@ %@",self.selMonth,self.selYear];
    if(self.confirmBlock){
        self.confirmBlock(dateStr,self.selectedDate);
    }
    [self hide];
}

-(void)show
{
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
}

- (void)hide
{
    [self removeFromSuperview];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return component == 0 ? self.months.count : self.years.count;
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return component == 0 ? self.months[row] : self.years[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger monthIndex = [pickerView selectedRowInComponent:0];
    NSInteger yearIndex = [pickerView selectedRowInComponent:1];
    
    self.selYear = self.years[yearIndex];
    self.selMonth = self.months[monthIndex];
    NSInteger year = [self.selYear integerValue];
    NSInteger month = monthIndex + 1; // 修正月份值(数组索引+1)
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *currentComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:currentComponents.day];
    self.selectedDate = [calendar dateFromComponents:components];
}


@end
