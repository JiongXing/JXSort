//
//  NSMutableArray+JXSort.m
//  SortDemo
//
//  Created by JiongXing on 2016/10/18.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "NSMutableArray+JXSort.h"

@implementation NSMutableArray (JXSort)

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

- (void)jx_insertionSortUsingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback {
    if (self.count == 0) {
        return;
    }
    for (NSInteger i = 1; i < self.count; i ++) {
        for (NSInteger j = i; j > 0 && comparator(self[j], self[j - 1]) == NSOrderedAscending; j --) {
            [self jx_exchangeWithIndexA:j indexB:j - 1 didExchange:exchangeCallback];
        }
    }
}

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
        // 寻找小于pivot的元素
        while (i < j && comparator(self[j], pivot) != NSOrderedAscending) {
            j --;
        }
        if (i < j) {
            [self jx_exchangeWithIndexA:i indexB:j didExchange:exchangeCallback];
            i ++;
        }
        
        // 寻找大于pivot的元素
        while (i < j && comparator(self[i], pivot) != NSOrderedDescending) {
            i ++;
        }
        if (i < j) {
            [self jx_exchangeWithIndexA:i indexB:j didExchange:exchangeCallback];
            j --;
        }
    }
    return i;
}

- (void)jx_exchangeWithIndexA:(NSInteger)indexA indexB:(NSInteger)indexB didExchange:(JXSortExchangeCallback)exchangeCallback {
    id temp = self[indexA];
    self[indexA] = self[indexB];
    self[indexB] = temp;
    
    if (exchangeCallback) {
        exchangeCallback(temp, self[indexA]);
    }
}

@end
