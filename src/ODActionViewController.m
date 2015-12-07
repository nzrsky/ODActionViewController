// ODActionViewController.m
//
// Copyright (c) 2009-2015 Alexey Nazaroff, AJR
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ODActionViewController.h"
#import <ODX.Blocks/UIActionSheet+ODBlocks.h>

@implementation UIActionSheetItem

+ (nonnull instancetype)itemWithTitle:(nonnull NSString *)title block:(nonnull uiactionsheetitem_block_t)block {
    UIActionSheetItem *item = [[UIActionSheetItem alloc] init];
    item.title = title;
    item.block = block;
    return item;
}

@end

@implementation UIActionSheet (ODBuilder)

+ (nonnull instancetype)od_actionSheetWithTitle:(nullable NSString *)title actionItems:(nonnull NSArray<UIActionSheetItem *> *)items
                              cancelButtonTitle:(nonnull NSString *)cancelButtonTitle {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [items enumerateObjectsUsingBlock:^(UIActionSheetItem * __nonnull item, NSUInteger idx, BOOL * __nonnull stop) {
        [sheet addButtonWithTitle:item.title];
        if (item.isDestructive) {
            [sheet setDestructiveButtonIndex:idx];
        }
    }];
    
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:cancelButtonTitle]];
    
    [sheet od_addCompletionBlock:^(BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            UIActionSheetItem *item = items[buttonIndex];
            if (item.block) {
                item.block();
            }
        }
    }];
    
    return sheet;
}

+ (nonnull instancetype)od_actionSheetWithActionItems:(nonnull NSArray<UIActionSheetItem *> *)items
                                    cancelButtonTitle:(nonnull NSString *)cancelButtonTitle {
    return [self od_actionSheetWithTitle:nil actionItems:items cancelButtonTitle:cancelButtonTitle];
}

@end
