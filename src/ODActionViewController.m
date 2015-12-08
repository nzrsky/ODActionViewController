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

static CGFloat const kActionTableCellHeight = 42.0f;
static CGFloat const kActionTableCellSpacing = 7.0f;
static CGFloat const kActionTableBackgroundAlpha = 0.5f;

static CGFloat const kActionTableCellSeparatorInset = 15.0f;

static CGFloat const kActionTableCellAlpha = 0.6f;
static CGFloat const kActionTableCellSeparatorWhite = 0.93f;

//static CGFloat const kActionTableCellFontSize = 14.0f;

@implementation ODActionControllerItem

+ (nonnull instancetype)itemWithTitle:(nonnull NSString *)title block:(nonnull odactionvcitem_block_t)block {
    ODActionControllerItem *item = [[ODActionControllerItem alloc] init];
    item.title = title;
    item.block = block;
    return item;
}

@end

@interface ODActionViewCell: UITableViewCell {
    UIView *_separator;
    UIFont *_defaultFont;
    UIFont *_boldFont;
}
@property (nonatomic, assign) BOOL showTopSeparator;
@property (nonatomic, assign, getter=isBold) BOOL bold;
@end

@implementation ODActionViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
        _defaultFont = self.textLabel.font;
        _boldFont = [UIFont boldSystemFontOfSize:self.textLabel.font.pointSize];
        
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.font = _defaultFont;
        
        _separator = [[UIView alloc] initWithFrame:(CGRect){kActionTableCellSeparatorInset, 0, self.frame.size.width - 2*kActionTableCellSeparatorInset, 1}];
        _separator.backgroundColor = [UIColor colorWithWhite:kActionTableCellSeparatorWhite alpha:1];
        _separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _separator.hidden = YES;
        [self addSubview:_separator];
        
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:kActionTableCellAlpha];
    }
    return self;
}

- (void)setShowTopSeparator:(BOOL)show {
    _showTopSeparator = show;
    _separator.hidden = !show;
}

- (void)setBold:(BOOL)bold {
    _bold = bold;
    self.textLabel.font = (bold) ? _boldFont : _defaultFont;
}

@end

@interface ODActionViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray<ODActionControllerItem *> *items;
@property (nonatomic, copy) NSString *tableTitle;
@end

@implementation ODActionViewController {
    UITableView *_tableView;
    UIView *_blurredBackground;
}

- (nullable instancetype)initWithTitle:(nullable NSString *)title
                                actionItems:(nonnull NSArray<ODActionControllerItem *> *)items
                          cancelButtonTitle:(nonnull NSString *)cancelButtonTitle {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        _tableTitle = title;
        _items = items;
        
        if (cancelButtonTitle) {
            __weak __typeof(self) self_weak_ = self;
            ODActionControllerItem *cancelItem = [ODActionControllerItem itemWithTitle:NSLocalizedString(@"Cancel", @"Cancel button") block:^{
                [self_weak_ dismissController];
            }];
            cancelItem.bold = YES;
            
            _items = [_items arrayByAddingObject:cancelItem];
        }
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_0) {
            self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect rect = self.view.bounds;
    UIView *headerView = [[UIView alloc] initWithFrame:rect];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    headerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kActionTableBackgroundAlpha];
    [headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissController)]];

    rect.size.height += [self calculateTableHeight];
    rect.origin.y = 0;
    
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    _tableView.tableHeaderView = headerView;
    _tableView.tableFooterView = [UIView new];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = kActionTableCellSpacing;
    _tableView.separatorColor = [UIColor clearColor];
    
    [_tableView registerClass:ODActionViewCell.class forCellReuseIdentifier:NSStringFromClass(ODActionViewCell.class)];
    [self.view addSubview:_tableView];

    rect.origin.y = self.view.bounds.size.height;
    _blurredBackground = [self blurredViewWithRect:rect];
    [self.view insertSubview:_blurredBackground atIndex:0];
}

- (UIView *)blurredViewWithRect:(CGRect)rect {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_0) {
        UIView *blurredView = nil;
        if (!UIAccessibilityIsReduceTransparencyEnabled()) {
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            blurredView = [[UIVisualEffectView alloc] initWithEffect:effect];
        } else {
            blurredView = [[UIView alloc] init];
            blurredView.backgroundColor = [UIColor lightGrayColor];
            blurredView.alpha = 0.5;
        }
        blurredView.frame = rect;
        blurredView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        return blurredView;
    } else {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:rect];
        toolbar.autoresizingMask = self.view.autoresizingMask;
        return toolbar;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGFloat newOffset = self.view.bounds.size.height - _tableView.frame.size.height;
    if (animated) {
        [self setTableOffset:0];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self setTableOffset:newOffset];
        } completion:nil];
    } else {
       [self setTableOffset:newOffset];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    CGFloat newOffset = 0;
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self setTableOffset:newOffset];
        } completion:nil];
    } else {
        [self setTableOffset:newOffset];
    }
}

- (void)dismissController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)calculateTableHeight {
    CGFloat h = (self.items.count) * (kActionTableCellSpacing);
    for (ODActionControllerItem *item in self.items) {
        h += (item.subitems ? item.subitems.count : 1)*kActionTableCellHeight;
    }
    return h;
}

- (void)setTableOffset:(CGFloat)offset {
    CGRect rc = _tableView.frame;
    rc.origin.y = offset;
    _tableView.frame = rc;
    
    rc.size.height -= self.view.bounds.size.height;
    rc.origin.y += self.view.bounds.size.height;
    _blurredBackground.frame = rc;
}

#pragma mark - Table
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kActionTableCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.items.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    return v;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    return v;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ODActionControllerItem *item = self.items[section];
    return item.subitems ? item.subitems.count : 1;
}

- (ODActionControllerItem *)itemWithIndexPath:(NSIndexPath *)indexPath {
    ODActionControllerItem *item = self.items[indexPath.section];
    if (item.subitems) {
        item = item.subitems[indexPath.row];
    }
    return item;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ODActionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ODActionViewCell.class) forIndexPath:indexPath];
    ODActionControllerItem *item = [self itemWithIndexPath:indexPath];
    cell.textLabel.text = item.title;
    cell.textLabel.textColor = self.view.tintColor;
    cell.showTopSeparator = indexPath.row > 0;
    cell.bold = item.isBold;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ODActionControllerItem *item = [self itemWithIndexPath:indexPath];
    
    if (item.block) {
        item.block();
    }
}

@end


@implementation UIViewController (ODActionViewController)

- (void)od_presentActionViewController:(UIViewController *)viewControllerToPresent
                              animated:(BOOL)flag completion:(void (^)(void))completion {
//    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewControllerToPresent];
//    
//    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_0) {
//        nc.providesPresentationContextTransitionStyle = YES;
//        nc.definesPresentationContext = YES;
//        nc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//        [self presentViewController:nc animated:NO completion:completion];
//    } else {
//        id<UIApplicationDelegate> appDelegate = (id<UIApplicationDelegate>)[[UIApplication sharedApplication] delegate];
//        [self presentViewController:nc animated:NO completion:^{
//            [nc dismissViewControllerAnimated:NO completion:^{
//                UIModalPresentationStyle _style = appDelegate.window.rootViewController.modalPresentationStyle;
//                appDelegate.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
//                [self presentViewController:nc animated:NO completion:completion];
//                appDelegate.window.rootViewController.modalPresentationStyle = _style;
//            }];
//        }];
//    }

    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_0) {
        [self setModalPresentationStyle:UIModalPresentationCurrentContext];
        [self presentViewController:viewControllerToPresent animated:YES completion:completion];
    } else {
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
}

@end
