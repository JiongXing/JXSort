//
//  NSMutableArray+JXSort.h
//  SortDemo
//
//  Created by JiongXing on 2016/10/18.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSComparisonResult(^JXSortComparator)(id obj1, id obj2);
typedef void(^JXSortExchangeCallback)(id obj1, id obj2);

@interface NSMutableArray (JXSort)

// 选择排序
- (void)jx_selectionSortUsingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback;

// 冒泡排序
- (void)jx_bubbleSortUsingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback;

// 插入排序
- (void)jx_insertionSortUsingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback;

// 快速排序
- (void)jx_quickSortUsingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback;

@end
