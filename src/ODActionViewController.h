// ODActionViewController.h
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

#import <UIKit/UIKit.h>

@class ODActionControllerItem;

typedef void(^odactionvcitem_block_t)(__kindof ODActionControllerItem * _Nonnull);

@interface ODActionControllerItem : NSObject
@property (nullable, nonatomic, strong) odactionvcitem_block_t block;
@property (nullable, nonatomic, strong) NSString *title;

// Destructive buttons will be with red title
@property (nonatomic, assign, getter=isDestructive) BOOL destructive;

@property (nonatomic, assign, getter=isBold) BOOL bold;
@property (nonatomic, assign, getter=isDisabled) BOOL disabled;

// Specify class for custom cells
@property (nullable, nonatomic, strong) Class customCellClass;

// Items for group section
@property (nullable, nonatomic, strong) NSArray<ODActionControllerItem *> *subitems;

+ (nonnull instancetype)itemWithTitle:(nullable NSString *)title block:(nullable odactionvcitem_block_t)block;
@end


@interface ODActionViewController: UIViewController
- (nullable instancetype)initWithActionItems:(nonnull NSArray<ODActionControllerItem *> *)items
                           cancelButtonTitle:(nonnull NSString *)cancelButtonTitle;
- (void)dismissController;
@end


@interface UIViewController (ODActionViewController)
// Use this method to present menu controller properly for iOS7 & iOS8+.
// If you support iOS8+ only you can use standard `presentViewController:...` method
- (void)od_presentActionViewController:(UIViewController * _Nonnull)viewControllerToPresent
                    animated:(BOOL)flag completion:(void (^ _Nullable)(void))completion;
@end

@protocol ODActionViewCellDelegate <NSObject>
// Invoke this method to dismiss menu controller
- (void)dismissController;
@end

@interface ODActionViewCell: UITableViewCell
// You need override setItem: to configure custom cell. It will be invoked in `cellForRowAtIndexPath...`.
@property (nullable, nonatomic, strong) ODActionControllerItem *item;
@property (nullable, nonatomic, weak) NSObject<ODActionViewCellDelegate> *actionDelegate;
@end
