//
//  SecondMenuView.m
//  LoveBB
//
//  Created by AngelLL on 15/10/22.
//  Copyright © 2015年 Daniel_Li. All rights reserved.
//

#import "JHCustomMenu.h"
#import "ATFontManager.h"

#define TopToView 15.0f
#define LeftToView 10.0f
#define CellLineEdgeInsets UIEdgeInsetsMake(0, 10, 0, 10)
#define TableViewBGcolor [UIColor colorWithRed:251/255.0 green:251/255.0 blue:252/255.0 alpha:1.0]

@interface JHCustomMenu()
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic ,strong) UIImageView *backImgView;
@end
@implementation JHCustomMenu

- (instancetype)initWithDataArr:(NSArray *)dataArr origin:(CGPoint)origin width:(CGFloat)width rowHeight:(CGFloat)rowHeight
{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    if (self) {
        if (rowHeight <= 0) {
            rowHeight = 44;
        }
        self.backgroundColor = [UIColor clearColor];
//        self.backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(origin.x + LeftToView, origin.y, width, rowHeight * dataArr.count + TopToView)];
//        self.backImgView.image = [UIImage imageNamed:@"bg_top_right_popup"];
//        [self addSubview:self.backImgView];
       
        self.origin = origin;
        self.rowHeight = rowHeight;
        self.width = width;
        self.arrData = [dataArr copy];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x + LeftToView + 10, TopToView + origin.y, width - 20, rowHeight * dataArr.count) style:UITableViewStylePlain];
//        self.tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        __weak __typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.alpha = 1;
            weakSelf.backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(origin.x + LeftToView, origin.y, width, rowHeight * dataArr.count + TopToView)];
            weakSelf.backImgView.image = [UIImage imageNamed:@"bg_top_right_popup"];
            weakSelf.backImgView.transform = CGAffineTransformMakeScale(1, 1);
            
        } completion:^(BOOL finished) {
            [weakSelf addSubview:weakSelf.backImgView];
            [weakSelf addSubview:weakSelf.tableView];
        }];
        
        self.backImgView.layer.cornerRadius = 10;
//        self.backImgView.layer.shadowColor = UIColorHex(0xA7A9F9).CGColor;
//
//        self.backImgView.layer.shadowOffset = CGSizeMake(-2, 2);
//
//        self.backImgView.layer.shadowOpacity = 1;
        
        self.backImgView.clipsToBounds = false;
        
        self.tableView.layer.cornerRadius = 10;
//        self.tableView.layer.shadowColor = UIColorHex(0xA7A9F9).CGColor;
        
//        self.tableView.layer.shadowOffset = CGSizeMake(-2, 2);
//
//        self.tableView.layer.shadowOpacity = 1;
        
        self.tableView.clipsToBounds = false;
        
        _tableView.bounces = NO;
        _tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:233/255.0 alpha:1.0];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"JHCustomMenu"];
        if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            
            [self.tableView setSeparatorInset:CellLineEdgeInsets];
            
        }
        
        if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            
            [self.tableView setLayoutMargins:CellLineEdgeInsets];
            
        }

    }
    return self;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JHCustomMenu"];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:60/255.0 green:60/255.0 blue:60/255.0 alpha:1.0];
    cell.textLabel.font = [ATFontManager systemFontOfSize:15];
    cell.textLabel.text = self.arrData[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    if (self.arrImgName.count > indexPath.row) {
        cell.imageView.image = [UIImage imageNamed:self.arrImgName[indexPath.row]];
//        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.delegate respondsToSelector:@selector(jhCustomMenu:didSelectRowAtIndexPath:)]){
        [self.delegate jhCustomMenu:tableView didSelectRowAtIndexPath:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissWithCompletion:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:CellLineEdgeInsets];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:CellLineEdgeInsets];
        
    }
    
}

- (void)dismissWithCompletion:(void (^)(JHCustomMenu *object))completion
{
    __weak __typeof(self) weakSelf = self;
//    weakSelf.alpha = 0;
//    weakSelf.tableView.frame = CGRectMake(weakSelf.origin.x + LeftToView , weakSelf.origin.y + TopToView, 0, 0);
//    [weakSelf removeFromSuperview];
//    if (completion) {
//        completion(weakSelf);
//    }
//    if (weakSelf.dismiss) {
//        weakSelf.dismiss();
//    }
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.alpha = 0;
        weakSelf.backImgView.frame = CGRectMake(weakSelf.origin.x + LeftToView + weakSelf.width, weakSelf.origin.y, 0, 0);
        weakSelf.backImgView.contentMode = UIViewContentModeScaleToFill;
        weakSelf.backImgView.transform = CGAffineTransformMakeScale(0.1, 0.1);

    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
        if (completion) {
            completion(weakSelf);
        }
        if (weakSelf.dismiss) {
            weakSelf.dismiss();
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (![touch.view isEqual:self.tableView]) {
        [self dismissWithCompletion:nil];
    }
}

//- (void)drawRect:(CGRect)rect
//
//{
//
//
////    [colors[serie] setFill];
//
//    //拿到当前视图准备好的画板
//
//    CGContextRef
//    context = UIGraphicsGetCurrentContext();
//
//    //利用path进行绘制三角形
//
//    CGContextBeginPath(context);//标记
//
//    CGContextMoveToPoint(context,
//                         kScreenWidth - 30, TopToView * 0.5 + 64);//设置起点
//
//    CGContextAddLineToPoint(context,
//                            kScreenWidth - 35, TopToView + 64);
//
//    CGContextAddLineToPoint(context,
//                            kScreenWidth - 25, TopToView + 64);
//
//    CGContextClosePath(context);//路径结束标志，不写默认封闭
//
//    [TableViewBGcolor setFill]; //设置填充色
//
//    [TableViewBGcolor setStroke]; //设置边框颜色
//
//    CGContextDrawPath(context,
//                      kCGPathFillStroke);//绘制路径path
//}

@end

