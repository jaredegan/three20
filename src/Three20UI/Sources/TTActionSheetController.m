//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UI/TTActionSheetController.h"

// UI
#import "Three20UI/TTNavigator.h"
#import "Three20UI/TTActionSheetControllerDelegate.h"
#import "Three20UI/TTActionSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCore.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTActionSheetController

@synthesize delegate = _delegate;
@synthesize userInfo = _userInfo;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    _URLs = [[NSMutableArray alloc] init];
	_targets = TTCreateNonRetainingArray();
	_selectors = [[NSMutableArray alloc] init];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString*)title delegate:(id)delegate {
  if (self = [self initWithNibName:nil bundle:nil]) {
    _delegate = delegate;

    if (nil != title) {
      self.actionSheet.title = title;
    }
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString*)title {
  if (self = [self initWithTitle:title delegate:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [self initWithTitle:nil delegate:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_URLs);
  TT_RELEASE_SAFELY(_targets);
  TT_RELEASE_SAFELY(_selectors);
  TT_RELEASE_SAFELY(_userInfo);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  TTActionSheet* actionSheet = [[[TTActionSheet alloc] initWithTitle:nil delegate:self
                                                       cancelButtonTitle:nil
                                                       destructiveButtonTitle:nil
                                                       otherButtonTitles:nil] autorelease];
  actionSheet.popupViewController = self;
  self.view = actionSheet;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UTViewController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)persistView:(NSMutableDictionary*)state {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTPopupViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showInView:(UIView*)view animated:(BOOL)animated {
  [self viewWillAppear:animated];
  [self.actionSheet showInView:view.window];
  [self viewDidAppear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
  [self viewWillAppear:animated];
  [self.actionSheet showFromBarButtonItem:item animated:animated];
  [self viewDidAppear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated {
  [self viewWillAppear:animated];
  [self.actionSheet showFromRect:rect inView:view animated:animated];
  [self viewDidAppear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissPopupViewControllerAnimated:(BOOL)animated {
  [self viewWillDisappear:animated];
  [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex
                    animated:animated];
  [self viewDidDisappear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIActionSheetDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if ([_delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
    [_delegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheetCancel:(UIActionSheet*)actionSheet {
  if ([_delegate respondsToSelector:@selector(actionSheetCancel:)]) {
    [_delegate actionSheetCancel:actionSheet];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willPresentActionSheet:(UIActionSheet*)actionSheet {
  if ([_delegate respondsToSelector:@selector(willPresentActionSheet:)]) {
    [_delegate willPresentActionSheet:actionSheet];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didPresentActionSheet:(UIActionSheet*)actionSheet {
  if ([_delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
    [_delegate didPresentActionSheet:actionSheet];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet*)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
  NSObject* target = [self targetAtIndex:buttonIndex];
  NSString* selectorAsString = [self selectorAtIndex:buttonIndex];
  if (target && selectorAsString) {
    [target performSelector:NSSelectorFromString(selectorAsString)];
  }

  if ([_delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
    [_delegate actionSheet:actionSheet willDismissWithButtonIndex:buttonIndex];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
  NSString* URL = [self buttonURLAtIndex:buttonIndex];
  BOOL canOpenURL = YES;

  if ([_delegate
        respondsToSelector:@selector(actionSheetController:didDismissWithButtonIndex:URL:)]) {
    canOpenURL = [_delegate actionSheetController: self
                        didDismissWithButtonIndex: buttonIndex
                                              URL: URL];
  }

  if (URL && canOpenURL) {
    TTOpenURL(URL);
  }

  if ([_delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
    [_delegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIActionSheet*)actionSheet {
  return (UIActionSheet*)self.view;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)addButtonWithTitle:(NSString*)title URL:(NSString*)URL target:(NSObject *)target
                       selector:(SEL)selector {
  if (URL) {
    [_URLs addObject:URL];

  } else {
    [_URLs addObject:[NSNull null]];
  }

  if (target) {
    [_targets addObject:target];

  } else {
    [_targets addObject:[NSNull null]];
  }

  if (selector) {
    [_selectors addObject:NSStringFromSelector(selector)];

  } else {
    [_selectors addObject:[NSNull null]];
  }

  return [self.actionSheet addButtonWithTitle:title];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)addButtonWithTitle:(NSString*)title URL:(NSString*)URL {
  return [self addButtonWithTitle:title URL:URL target:nil selector:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)addButtonWithTitle:(NSString*)title target:(NSObject *)target selector:(SEL)selector {
  return [self addButtonWithTitle:title URL:nil target:target selector:selector];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)addCancelButtonWithTitle:(NSString*)title URL:(NSString*)URL {
  self.actionSheet.cancelButtonIndex = [self addButtonWithTitle:title URL:URL];
  return self.actionSheet.cancelButtonIndex;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)addDestructiveButtonWithTitle:(NSString*)title URL:(NSString*)URL {
  self.actionSheet.destructiveButtonIndex = [self addButtonWithTitle:title URL:URL];
  return self.actionSheet.destructiveButtonIndex;
}




///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)buttonURLAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex < _URLs.count) {
    id URL = [_URLs objectAtIndex:buttonIndex];
    return URL != [NSNull null] ? URL : nil;

  } else {
    return nil;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSObject*)targetAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex < _targets.count) {
    id target = [_targets objectAtIndex:buttonIndex];
    return target != [NSNull null] ? target : nil;

  } else {
    return nil;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)selectorAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex < _selectors.count) {
    id selector = [_selectors objectAtIndex:buttonIndex];
    return selector != [NSNull null] ? selector : nil;

  } else {
    return nil;
  }
}


@end
