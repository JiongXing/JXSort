# JXSort
> 用Objective-C实现几种基本的排序算法，并把排序的过程图形化显示。其实算法还是挺有趣的 ^ ^.

- 选择排序
- 冒泡排序
- 插入排序
- 快速排序

# 选择排序
以升序为例。
选择排序比较好理解，一句话概括就是依次按位置挑选出适合此位置的元素来填充。

1. 暂定第一个元素为最小元素，往后遍历，逐个与最小元素比较，若发现更小者，与先前的"最小元素"交换位置。达到更新最小元素的目的。
2. 一趟遍历完成后，能确保刚刚完成的这一趟遍历中，最的小元素已经放置在前方了。然后缩小排序范围，新一趟排序从数组的第二个元素开始。
3. 在新一轮排序中重复第1、2步骤，直到范围不能缩小为止，排序完成。

![选择排序.gif](http://upload-images.jianshu.io/upload_images/2419179-2804b792efe11837.gif?imageMogr2/auto-orient/strip)

以下方法在`NSMutableArray+JXSort.m`中实现
```objc
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
```

# 冒泡排序

1. 在一趟遍历中，不断地对相邻的两个元素进行排序，小的在前大的在后，这样会造成大值不断沉底的效果，当一趟遍历完成时，最大的元素会被排在后方正确的位置上。
2. 然后缩小排序范围，即去掉最后方位置正确的元素，对前方数组进行新一轮遍历，重复第1步骤。直到范围不能缩小为止，排序完成。

![冒泡排序.gif](http://upload-images.jianshu.io/upload_images/2419179-8403919aa4a9383a.gif?imageMogr2/auto-orient/strip)

```objc
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
```

#插入排序
插入排序是从一个乱序的数组中依次取值，插入到一个已经排好序的数组中。
这看起来好像要两个数组才能完成，但如果只想在同一个数组内排序，也是可以的。此时需要想象出两个区域：前方有序区和后方乱序区。

1. 分区。开始时前方有序区只有一个元素，就是数组的第一个元素。然后把从第二个元素开始直到结尾的数组作为乱序区。
2. 从乱序区取第一个元素，把它正确插入到前方有序区中。把它与前方无序区的最后一个元素比较，亦即与它的前一个元素比较。
 - 如果比前一个元素要大，则不需要交换，这时有序区扩充一格，乱序区往后缩减一格，相当于直接拼在有序区末尾。
 - 如果和前一个元素相等，则继续和前二元素比较、再和前三元素比较......如果往前遍历到头了，发现前方所有元素值都长一个样的话(囧)，那也可以，不需要交换，这时有序区扩充一格，乱序区往后缩减一格，相当于直接拼在有序区末尾。如果比前一个元素大呢？对不起作为有序区不可能出现这种情况。如果比前一个元素小呢，请看下一点。
 - 如果比前一个元素小，则交换它们的位置。交换完后，继续比较取出元素和它此时的前一个元素，若更小就交换，若相等就比较前一个，直到遍历完成。
至此，把乱序区第一个元素正确插入到前方有序区中。
3. 往后缩小乱序区范围，继续取缩小范围后的第一个元素，重复第2步骤。直到范围不能缩小为止，排序完成。

![插入排序.gif](http://upload-images.jianshu.io/upload_images/2419179-b703fa5194694a5f.gif?imageMogr2/auto-orient/strip)

```objc
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
```

###  快速排序
快排的版本有好几种，粗略可分为：
- 原始的快排。
- 为制造适合高效排序环境而事先打乱数组顺序的快排。
- 为数组内大量重复值而优化的三向切分快排。

这里只讨论原始的快排。
关于在快排过程中何时进行交换以及交换谁的问题，我看见两种不同的思路：

1. 当左右两个游标都停止时，交换两个游标所指向元素。枢轴所在位置暂时不变，直到两个游标相遇重合，才更新枢轴位置，交换枢轴与游标所指元素。
2. 当右游标找到一个比枢轴小的元素时，马上把枢轴交换到游标所在位置，而游标位置的元素则移到枢轴那里。完成一次枢轴更新。然后左游标再去寻找比枢轴大的元素，同理。

第1种思路可以有效降低交换频率，在游标相遇后再对枢轴进行定位，这步会导致略微增加了比较的次数；
第2种思路交换操作会比较频繁，但是在交换的过程中同时也把枢轴的位置不断进行更新，当游标相遇时，枢轴的定位也完成了。
在两种思路都尝试实现过后，我还是喜欢第2种，即便交换操作会多一些，但实质上的交换只是对数组特定位置的赋值，这种操作还是挺快的。

1. 从待排序数组中选一个值作为分区的参考界线，一般选第一个元素即可。这个选出来的值可叫做枢轴`pivot`，它将会在一趟排序中不断被移动位置，只终移动到位于整个数组的正确位置上。
2. 一趟排序的目标是把小于枢轴的元素放在前方，把大于枢轴的元素放在后方，枢轴放在中间。这看起来一趟排序实质上所干的事情就是把数组分区。接下来考虑怎么完成一次分区。
3. 记一个游标`i`，指向待排序数组的首位，它将会不断向后移动；
再记一个游标`j`，指向待排序数组的末位，它将会不断向前移动。
这样可以预见的是，`i` 、`j`终有相遇时，当它们相遇的时候，就是这趟排序完成时。
4. 现在让游标`j`从后往前扫描，寻找比枢轴小的元素`x`，找到后停下来，准备把这个元素扔到前方去。
5. 在同一个数组内排序并不能扩大数组的容量，那怎么扔呢？
因为刚才把首位元素选作为`pivot`，所以当前它们的位置关系是`pivot ... x`。
又排序目标是升序，`x`是个小值却放在了`pivot`的后方，不妥，需要交换它们的位置。
6. 交换完后，它们的位置关系变成了`x ... pivot`。此时`j`指向了`pivot`，`i`指向了`x`。
7. 现在让游标`i`向后扫描，寻找比枢轴大的元素`y`，找到后停下来，与`pivot`进行交换。
完成后的位置关系是`pivot ... y`，此时`i`指向pivot，即pivot移到了`i`的位置。
8. 这里有个小优化，在`i`向后扫描开始时，`i`是指向`x`的，而在上一轮`j`游标的扫描中我们已经知道`x`是比`pivot`小的，所以完全可以让`i`跳过`x`，不需要拿着`x`和`pivot`再比较一次。
结论是在`j`游标的交换完成后，顺便把`i`往后移一位，`i ++`。
同理，在`i`游标的交换完成后，顺便把`j`往前移一位，`j --`。
9. 在扫描的过程中如果发现与枢轴相等的元素怎么办呢？
因我们不讨论三向切分的快排优化算法，所以这里答案是：不理它。
随着一趟一趟的排序，它们会慢慢被更小的元素往后挤，被更大的元素往前挤，最后的结果就是它们都会和枢轴一起移到了中间位置。
10. 当`i`和`j`相遇时，`i`和`j`都会指向`pivot`。在我们的分区方法里，把`i`返回，即在分区完成后把枢轴位置返回。
11. 接下来，让分出的两个数组分别按上述步骤各自分区，这是个递归的过程，直到数组不能再分时，排序完成。

快速排序是很天才的设计，实现不复杂，关键是它真的很快~

![快速排序.gif](http://upload-images.jianshu.io/upload_images/2419179-3b6bbe9a5b4a3c22.gif?imageMogr2/auto-orient/strip)

```objc
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
```

# 参考
[Swift算法俱乐部中文版 -- 插入排序](http://www.jianshu.com/p/0ab1369e703d)
[算法笔记－排序01:选择排序,插入排序,希尔排序](http://www.jianshu.com/p/a7efe0f8e4ab)
[算法笔记－排序02:归并排序,快速排序](http://www.jianshu.com/p/655db46e161d)
[1.2-交换排序-快速排序](http://www.jianshu.com/p/8773cc691ced)
