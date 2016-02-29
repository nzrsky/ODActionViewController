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

static CGFloat const kODActionTableCellHeight = 47.0f;
static CGFloat const kODActionTableCellSpacing = 7.0f;
static CGFloat const kODActionTableBackgroundAlpha = 0.6f;

static CGFloat const kODActionTableCellSeparatorInset = 15.0f;

static CGFloat const kODActionTableCellAlpha = 0.6f;
static CGFloat const kODActionTableCellSeparatorWhite = 0.93f;

static CGFloat const kODActionTableHeaderViewHeight = 0.0f;
static CGFloat const kODActionTableFooterViewHeight = kODActionTableCellSpacing;

#pragma mark Item
@implementation ODActionControllerItem

+ (nonnull instancetype)itemWithTitle:(nullable NSString *)title block:(nullable odactionvcitem_block_t)block {
    ODActionControllerItem *item = [[ODActionControllerItem alloc] init];
    item.title = title;
    item.block = block;
    return item;
}

@end

#pragma mark Cell
@interface ODActionViewCell () {
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

        _separator = [[UIView alloc] initWithFrame:(CGRect){ kODActionTableCellSeparatorInset,
            0,
            self.frame.size.width - 2*kODActionTableCellSeparatorInset,
            1
        }];
        _separator.backgroundColor = [UIColor colorWithWhite:kODActionTableCellSeparatorWhite alpha:1];
        _separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _separator.hidden = YES;
        [self addSubview:_separator];

        self.backgroundColor = [UIColor colorWithWhite:1 alpha:kODActionTableCellAlpha];
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

- (void)setItem:(ODActionControllerItem *)item {
    _item = item;

    self.textLabel.text = item.title;
    self.bold = item.isBold;
}

@end

#pragma mark Section
static CGFloat const kODActionViewSectionHeaderHeight = 30.0f;
static CGFloat const kODActionViewControllerAppearanceAnimationDuration = 0.2f;
static CGFloat const kODActionViewControllerBackgroundAlpha = 0.5f;
static CGFloat const kODActionViewControllerItemsFontSize = 14.0f;

@interface ODActionViewSectionHeader : UITableViewHeaderFooterView
@property (nonatomic, strong) NSString *title;
@end

@implementation ODActionViewSectionHeader {
    UILabel *_label;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        CGRect labelFrame = self.bounds;
        _label = [[UILabel alloc] initWithFrame:labelFrame];
        _label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIButton new].tintColor;
        _label.font = [UIFont systemFontOfSize:kODActionViewControllerItemsFontSize];
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _label.text = title;
}

- (NSString *)title {
    return _label.text;
}

+ (CGFloat)defaultHeight {
    return kODActionViewSectionHeaderHeight;
}

@end

@interface ODActionViewController () <UITableViewDataSource, UITableViewDelegate, ODActionViewCellDelegate>
@property (nonatomic, strong) NSArray<ODActionControllerItem *> *items;
@end

@implementation ODActionViewController {
    UITableView *_tableView;
    UIView *_blurredBackground;
}

- (nullable instancetype)initWithActionItems:(nonnull NSArray<ODActionControllerItem *> *)items
                           cancelButtonTitle:(nullable NSString *)cancelButtonTitle {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        _items = items;

        if (cancelButtonTitle) {
//            __weak __typeof(self) self_weak_ = self;
            ODActionControllerItem *cancelItem = [ODActionControllerItem itemWithTitle:NSLocalizedString(@"Cancel", @"Cancel button") block:/*^(id sender){
                [self_weak_ dismissController];
            }*/ nil];
            cancelItem.bold = YES;

            _items = [_items arrayByAddingObject:cancelItem];
        }

        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
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
    headerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kODActionTableBackgroundAlpha];
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
    _tableView.sectionHeaderHeight = kODActionTableHeaderViewHeight;
    _tableView.sectionFooterHeight = kODActionTableFooterViewHeight;
    _tableView.separatorColor = [UIColor clearColor];

    [_tableView registerClass:ODActionViewCell.class forCellReuseIdentifier:NSStringFromClass(ODActionViewCell.class)];
    [_tableView registerClass:ODActionViewSectionHeader.class forHeaderFooterViewReuseIdentifier:NSStringFromClass(ODActionViewSectionHeader.class)];
    
    for (ODActionControllerItem *item in self.items) {
        if (item.customCellClass) {
            [_tableView registerClass:item.customCellClass forCellReuseIdentifier:NSStringFromClass(item.customCellClass)];
        }
    }

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
            blurredView.alpha = kODActionViewControllerBackgroundAlpha;
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
    [self setTableOffset:0];
    _tableView.tableHeaderView.alpha = 0;
    [UIView animateWithDuration:kODActionViewControllerAppearanceAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        _tableView.tableHeaderView.alpha = 1;
        [self setTableOffset:newOffset];
    } completion:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dismissController {
    [self dismissControllerWithBlock:nil];
}

- (void)dismissControllerWithBlock:(nullable void(^)())block {
    CGFloat newOffset = 0;
    [UIView animateWithDuration:kODActionViewControllerAppearanceAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _tableView.tableHeaderView.alpha = 0;
                         [self setTableOffset:newOffset];
                     }
                     completion:^(BOOL finished) {
                         [self dismissViewControllerAnimated:NO completion:nil];
                         if (block) {
                             block();
                         }
                     }];
}

- (CGFloat)calculateTableHeight {
    CGFloat h = (self.items.count) * (kODActionTableCellSpacing);
    for (ODActionControllerItem *item in self.items) {
        h += (item.subitems ? item.subitems.count : 1)*kODActionTableCellHeight +
             ((item.subitems && item.title) ? [ODActionViewSectionHeader defaultHeight] : kODActionTableHeaderViewHeight);
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
    return kODActionTableCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.items.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ODActionControllerItem *item = self.items[section];
    if (item.subitems && item.title) {
        ODActionViewSectionHeader *view = (id)[tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass(ODActionViewSectionHeader.class)];
        view.title = item.title;
        return view;
    } else {
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        v.backgroundColor = [UIColor clearColor];
        return v;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    ODActionControllerItem *item = self.items[section];
    return (item.subitems && item.title) ? [ODActionViewSectionHeader defaultHeight] : kODActionTableHeaderViewHeight;
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
    ODActionControllerItem *item = [self itemWithIndexPath:indexPath];

    ODActionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(item.customCellClass ?: ODActionViewCell.class)
                                                             forIndexPath:indexPath];
    cell.item = item;
    cell.textLabel.textColor = (item.disabled) ? [UIColor lightGrayColor] : ((item.destructive) ? [UIColor redColor] : self.view.tintColor);
    cell.showTopSeparator = indexPath.row > 0;
    cell.actionDelegate = self;
    cell.selectionStyle = (item.disabled) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ODActionControllerItem *item = [self itemWithIndexPath:indexPath];

    if (item.isDisabled) return;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    void (^finishedBlock)();
    if (item.block) {
        finishedBlock = ^{
            item.block(item);
        };
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissControllerWithBlock:finishedBlock];
    });
}

@end

@implementation UIViewController (ODActionViewController)

- (void)od_presentActionViewController:(UIViewController *)viewControllerToPresent
                              animated:(BOOL)animated completion:(void (^)(void))completion {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
//        self.providesPresentationContextTransitionStyle = YES;
//        self.definesPresentationContext = YES;
    }

    [self presentViewController:viewControllerToPresent animated:animated completion:completion];
}

@end
