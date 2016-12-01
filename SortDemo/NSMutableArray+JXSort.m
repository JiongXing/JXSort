//
//  NSMutableArray+JXSort.m
//  SortDemo
//
//  Created by JiongXing on 2016/10/18.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "NSMutableArray+JXSort.h"

@implementation NSMutableArray (JXSort)

/// 交换两个元素
- (void)jx_exchangeWithIndexA:(NSInteger)indexA indexB:(NSInteger)indexB didExchange:(JXSortExchangeCallback)exchangeCallback {
    id temp = self[indexA];
    self[indexA] = self[indexB];
    self[indexB] = temp;
    
    if (exchangeCallback) {
        exchangeCallback(temp, self[indexA]);
    }
}

#pragma mark - 选择排序
- (void)jx_selectionSortUsingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback {
    if (self.count == 0) {
        return;
    }
    for (NSInteger i = 0; i < self.count - 1; i ++) {
        for (NSInteger j = i + 1; j < self.count; j ++) {
            if (comparator(self[i], self[j]) == NSOrderedDescending) {
                [self jx_exchangeWithIndexA:i indexB:j didExchange:exchangeCallback];
            }
        }
    }
}

#pragma mark - 冒泡排序
- (void)jx_bubbleSortUsingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback {
    if (self.count == 0) {
        return;
    }
    for (NSInteger i = self.count - 1; i > 0; i --) {
        for (NSInteger j = 0; j < i; j ++) {
            if (comparator(self[j], self[j + 1]) == NSOrderedDescending) {
                [self jx_exchangeWithIndexA:j indexB:j + 1 didExchange:exchangeCallback];
            }
        }
    }
}

#pragma mark - 插入排序
- (void)jx_insertionSortUsingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback {
    for (NSInteger i = 1; i < self.count; i ++) {
        for (NSInteger j = i; j > 0 && comparator(self[j], self[j - 1]) == NSOrderedAscending; j --) {
            [self jx_exchangeWithIndexA:j indexB:j - 1 didExchange:exchangeCallback];
        }
    }
}

#pragma mark - 快速排序
- (void)jx_quickSortUsingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback {
    if (self.count == 0) {
        return;
    }
    [self jx_quickSortWithLowIndex:0 highIndex:self.count - 1 usingComparator:comparator didExchange:exchangeCallback];
}

- (void)jx_quickSortWithLowIndex:(NSInteger)low highIndex:(NSInteger)high usingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback {
    if (low >= high) {
        return;
    }
    NSInteger pivotIndex = [self jx_quickPartitionWithLowIndex:low highIndex:high usingComparator:comparator didExchange:exchangeCallback];
    [self jx_quickSortWithLowIndex:low highIndex:pivotIndex - 1 usingComparator:comparator didExchange:exchangeCallback];
    [self jx_quickSortWithLowIndex:pivotIndex + 1 highIndex:high usingComparator:comparator didExchange:exchangeCallback];
}

- (NSInteger)jx_quickPartitionWithLowIndex:(NSInteger)low highIndex:(NSInteger)high usingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback {
    id pivot = self[low];
    NSInteger i = low;
    NSInteger j = high;
    
    while (i < j) {
        // 略过大于等于pivot的元素
        while (i < j && comparator(self[j], pivot) != NSOrderedAscending) {
            j --;
        }
        if (i < j) {
            // i、j未相遇，说明找到了小于pivot的元素。交换。
            [self jx_exchangeWithIndexA:i indexB:j didExchange:exchangeCallback];
            i ++;
        }
        
        /// 略过小于等于pivot的元素
        while (i < j && comparator(self[i], pivot) != NSOrderedDescending) {
            i ++;
        }
        if (i < j) {
            // i、j未相遇，说明找到了大于pivot的元素。交换。
            [self jx_exchangeWithIndexA:i indexB:j didExchange:exchangeCallback];
            j --;
        }
    }
    return i;
}

#pragma mark - 堆排序
- (void)jx_heapSortUsingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback {
    // copy一份副本，对副本排序。增加的此步与排序无关，仅为增强程序健壮性，防止在排序过程中被中断而影响到原数组。
    NSMutableArray *array = [self mutableCopy];
    
    // 排序过程中不使用第0位
    [array insertObject:[NSNull null] atIndex:0];
    
    // 构造大顶堆
    // 遍历所有非终结点，把以它们为根结点的子树调整成大顶堆
    // 最后一个非终结点位置在本队列长度的一半处
    for (NSInteger index = array.count / 2; index > 0; index --) {
        // 根结点下沉到合适位置
        [array sinkIndex:index bottomIndex:array.count - 1 usingComparator:comparator didExchange:exchangeCallback];
    }
    
    // 完全排序
    // 从整棵二叉树开始，逐渐剪枝
    for (NSInteger index = array.count - 1; index > 1; index --) {
        // 每次把根结点放在列尾，下一次循环时将会剪掉
        [array jx_exchangeWithIndexA:1 indexB:index didExchange:exchangeCallback];
        // 下沉根结点，重新调整为大顶堆
        [array sinkIndex:1 bottomIndex:index - 1 usingComparator:comparator didExchange:exchangeCallback];
    }
    
    // 排序完成后删除占位元素
    [array removeObjectAtIndex:0];
    
    // 用排好序的副本代替自己
    [self removeAllObjects];
    [self addObjectsFromArray:array];
}

/// 下沉，传入需要下沉的元素位置，以及允许下沉的最底位置
- (void)sinkIndex:(NSInteger)index bottomIndex:(NSInteger)bottomIndex usingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback {
    for (NSInteger maxChildIndex = index * 2; maxChildIndex <= bottomIndex; maxChildIndex *= 2) {
        // 如果存在右子结点，并且左子结点比右子结点小
        if (maxChildIndex < bottomIndex && (comparator(self[maxChildIndex], self[maxChildIndex + 1]) == NSOrderedAscending)) {
            // 指向右子结点
            ++ maxChildIndex;
        }
        // 如果最大的子结点元素小于本元素，则本元素不必下沉了
        if (comparator(self[maxChildIndex], self[index]) == NSOrderedAscending) {
            break;
        }
        // 否则
        // 把最大子结点元素上游到本元素位置
        [self jx_exchangeWithIndexA:index indexB:maxChildIndex didExchange:exchangeCallback];
        // 标记本元素需要下沉的目标位置，为最大子结点原位置
        index = maxChildIndex;
    }
}

@end
