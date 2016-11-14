//
//  ViewController.m
//  SortDemo
//
//  Created by JiongXing on 2016/10/18.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "ViewController.h"
#import "NSMutableArray+JXSort.h"

static const NSInteger kBarCount = 100;

@interface ViewController ()

@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) NSMutableArray<UIView *> *barArray;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) dispatch_semaphore_t sema;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"重置" style:UIBarButtonItemStylePlain target:self action:@selector(onReset)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"排序" style:UIBarButtonItemStylePlain target:self action:@selector(onSort)];
    
    self.segmentControl.frame = CGRectMake(15, 64 + 10, CGRectGetWidth(self.view.bounds) - 30, 30);
    self.timeLabel.frame = CGRectMake(CGRectGetWidth(self.view.bounds) * 0.5 - 50,
                                      CGRectGetHeight(self.view.bounds) * 0.8, 120, 40);
    
    [self onReset];
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = [UIColor darkTextColor];
        [self.view addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UISegmentedControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"选择", @"冒泡", @"插入", @"快速", @"堆排序"]];
        _segmentControl.selectedSegmentIndex = 0;
        [_segmentControl addTarget:self action:@selector(onSegmentControlChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_segmentControl];
    }
    return _segmentControl;
}

- (void)onSegmentControlChanged:(UISegmentedControl *)segmentControl {
    [self onReset];
}

- (void)onReset {
    [self invalidateTimer];
    self.timeLabel.text = nil;
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat barMargin = 1;
    CGFloat barWidth = floorf((width - barMargin * (kBarCount + 1)) / kBarCount);
    CGFloat barOrginX = roundf((width - (barMargin + barWidth) * kBarCount + barMargin) / 2.0);
    CGFloat barAreaY = 64 + 10 + 30 + 10;
    CGFloat barBottom = CGRectGetHeight(self.view.bounds) * 0.8;
    CGFloat barAreaHeight = barBottom - barAreaY;
    
    [self.barArray enumerateObjectsUsingBlock:^(UIView * _Nonnull bar, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat barHeight = 20 + arc4random_uniform(barAreaHeight - 20);
        // 若需要制造高概率重复数据请打开此行，令数值为10的整数倍(或修改为其它倍数)
//        barHeight = roundf(barHeight / 10) * 10;
        bar.frame = CGRectMake(barOrginX + idx * (barMargin + barWidth), barBottom - barHeight, barWidth, barHeight);
    }];
    NSLog(@"重置成功!");
    [self printBarArray];
}

- (void)onSort {
    [self invalidateTimer];
    self.sema = dispatch_semaphore_create(0);
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    
    // 定时器信号
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.002 repeats:YES block:^(NSTimer * _Nonnull timer) {
        // 发出信号量，唤醒排序线程
        dispatch_semaphore_signal(weakSelf.sema);
        // 更新计时
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] - nowTime;
        weakSelf.timeLabel.text = [NSString stringWithFormat:@"耗时(秒):%2.3f", interval];
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        switch (self.segmentControl.selectedSegmentIndex) {
            case 0:
                [self selectionSort];
                break;
            case 1:
                [self bubbleSort];
                break;
            case 2:
                [self insertionSort];
                break;
            case 3:
                [self quickSort];
                break;
            case 4:
                [self heapSort];
                break;
            default:
                break;
        }
        [self invalidateTimer];
        [self printBarArray];
    });
}

- (void)selectionSort {
    [self.barArray jx_selectionSortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [self compareWithBarOne:obj1 andBarTwo:obj2];
    } didExchange:^(UIView *obj1, UIView *obj2) {
        [self exchangePositionWithBarOne:obj1 andBarTwo:obj2];
    }];
}

- (void)bubbleSort {
    [self.barArray jx_bubbleSortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [self compareWithBarOne:obj1 andBarTwo:obj2];
    } didExchange:^(UIView *obj1, UIView *obj2) {
        [self exchangePositionWithBarOne:obj1 andBarTwo:obj2];
    }];
}

- (void)insertionSort {
    [self.barArray jx_insertionSortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [self compareWithBarOne:obj1 andBarTwo:obj2];
    } didExchange:^(UIView *obj1, UIView *obj2) {
        [self exchangePositionWithBarOne:obj1 andBarTwo:obj2];
    }];
}

- (void)quickSort {
    [self.barArray jx_quickSortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [self compareWithBarOne:obj1 andBarTwo:obj2];
    } didExchange:^(id obj1, id obj2) {
        [self exchangePositionWithBarOne:obj1 andBarTwo:obj2];
    }];
}

- (void)heapSort {
    [self.barArray jx_heapSortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [self compareWithBarOne:obj1 andBarTwo:obj2];
    } didExchange:^(id obj1, id obj2) {
        [self exchangePositionWithBarOne:obj1 andBarTwo:obj2];
    }];
}

- (NSComparisonResult)compareWithBarOne:(UIView *)barOne andBarTwo:(UIView *)barTwo {
    // 模拟进行比较所需的耗时
    dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER);
    
    CGFloat height1 = CGRectGetHeight(barOne.frame);
    CGFloat height2 = CGRectGetHeight(barTwo.frame);
    if (height1 == height2) {
        return NSOrderedSame;
    }
    return height1 < height2 ? NSOrderedAscending : NSOrderedDescending;
}

- (void)exchangePositionWithBarOne:(UIView *)barOne andBarTwo:(UIView *)barTwo {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect frameOne = barOne.frame;
        CGRect frameTwo = barTwo.frame;
        frameOne.origin.x = barTwo.frame.origin.x;
        frameTwo.origin.x = barOne.frame.origin.x;
        barOne.frame = frameOne;
        barTwo.frame = frameTwo;
    });
}

- (NSMutableArray<UIView *> *)barArray {
    if (!_barArray) {
        _barArray = [NSMutableArray arrayWithCapacity:kBarCount];
        
        for (NSInteger index = 0; index < kBarCount; index ++) {
            UIView *bar = [[UIView alloc] init];
            bar.backgroundColor = [UIColor blueColor];
            
            [self.view addSubview:bar];
            [_barArray addObject:bar];
        }
    }
    return _barArray;
}

- (void)invalidateTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.sema = nil;
}

- (void)printBarArray {
#if 1
    NSMutableString *str = [NSMutableString string];
    [self.barArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [str appendFormat:@"%@ ", @(CGRectGetHeight(obj.frame))];
    }];
    NSLog(@"数组：%@", str);
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
