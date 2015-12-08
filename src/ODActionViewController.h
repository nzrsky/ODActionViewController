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

@property (nonatomic, assign, getter=isDestructive) BOOL destructive;
@property (nonatomic, assign, getter=isBold) BOOL bold;
@property (nonatomic, assign, getter=isDisabled) BOOL disabled;

@property (nullable, nonatomic, strong) Class customCellClass;
@property (nullable, nonatomic, strong) NSArray<ODActionControllerItem *> *subitems;

+ (nonnull instancetype)itemWithTitle:(nullable NSString *)title block:(nonnull odactionvcitem_block_t)block;
@end


@interface ODActionViewController: UIViewController
- (nullable instancetype)initWithActionItems:(nonnull NSArray<ODActionControllerItem *> *)items
                           cancelButtonTitle:(nonnull NSString *)cancelButtonTitle;
@end


@interface UIViewController (ODActionViewController)
- (void)od_presentActionViewController:(UIViewController * _Nonnull)viewControllerToPresent
                    animated:(BOOL)flag completion:(void (^ _Nullable)(void))completion;
@end

@protocol ODActionViewCellDelegate <NSObject>
- (void)dismissController;
@end

@interface ODActionViewCell: UITableViewCell
@property (nullable, nonatomic, strong) ODActionControllerItem *item;
@property (nullable, nonatomic, weak) NSObject<ODActionViewCellDelegate> *actionDelegate;
@end