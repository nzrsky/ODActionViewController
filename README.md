# ODActionViewController

[![Version](https://img.shields.io/cocoapods/v/ODActionViewController.svg?style=flat)](http://cocoapods.org/pods/ODActionViewController)
[![License](https://img.shields.io/cocoapods/l/ODActionViewController.svg?style=flat)](http://cocoapods.org/pods/ODActionViewController)
[![Platform](https://img.shields.io/cocoapods/p/ODActionViewController.svg?style=flat)](http://cocoapods.org/pods/ODActionViewController)

Controller for custom UIActionSheet like in Map.app.

## Usage

```objective-c
#import <ODActionViewController.h>

- (void)showActionSheet {
    UIActionSheetItem *item = [UIActionSheetItem itemWithTitle:@"Choose from Library" block:^{
        // ...
    }];

    [[UIActionSheet od_actionSheetWithTitle:NSLocalizedString(@"Photo", nil) actionItems:@[ item ]
                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)] showInView:self.view];
}

```

## Installation

ODActionViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ODActionViewController"
```

## Author

Alexey Nazaroff, alexx.nazaroff@gmail.com

## License

ODActionViewController is available under the MIT license. See the LICENSE file for more info.
