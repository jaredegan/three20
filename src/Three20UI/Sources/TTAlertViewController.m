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

#import "Three20UI/TTAlertViewController.h"

// UI
#import "Three20UI/TTNavigator.h"
#import "Three20UI/TTAlertViewControllerDelegate.h"
#import "Three20UI/TTAlertView.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCore.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTAlertViewController

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
- (id)initWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate {
  if (self = [self initWithNibName:nil bundle:nil]) {
    _delegate = delegate;

    if (nil != title) {
      self.alertView.title = title;
    }

    if (nil != message) {
      self.alertView.message = message;
    }
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString*)title message:(NSString*)message {
  if (self = [self initWithTitle:title message:message delegate:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [self initWithTitle:nil message:nil delegate:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [(UIAlertView*)self.view setDelegate:nil];
  TT_RELEASE_SAFELY(_URLs);
  TT_RELEASE_SAFELY(_userInfo);
  TT_RELEASE_SAFELY(_targets);
  TT_RELEASE_SAFELY(_selectors);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  TTAlertView* alertView = [[[TTAlertView alloc] initWithTitle:nil message:nil delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:nil] autorelease];
  alertView.popupViewController = self;
  self.view = alertView;
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
  [self.alertView show];
  [self viewDidAppear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissPopupViewControllerAnimated:(BOOL)animated {
  [self viewWillDisappear:animated];
  [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:animated];
  [self viewDidDisappear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAlertviewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if ([_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
    [_delegate alertView:alertView clickedButtonAtIndex:buttonIndex];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)alertViewCancel:(UIAlertView*)alertView {
  if ([_delegate respondsToSelector:@selector(alertViewCancel:)]) {
    [_delegate alertViewCancel:alertView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willPresentAlertView:(UIAlertView*)alertView {
  if ([_delegate respondsToSelector:@selector(willPresentAlertView:)]) {
    [_delegate willPresentAlertView:alertView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didPresentAlertView:(UIAlertView*)alertView {
  if ([_delegate respondsToSelector:@selector(didPresentAlertView:)]) {
    [_delegate didPresentAlertView:alertView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)alertView:(UIAlertView*)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
  NSObject* target = [self targetAtIndex:buttonIndex];
  NSString* selectorAsString = [self selectorAtIndex:buttonIndex];
  if (target && selectorAsString) {
    [target performSelector:NSSelectorFromString(selectorAsString)];
  }

  if ([_delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
    [_delegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  NSString* URL = [self buttonURLAtIndex:buttonIndex];
  BOOL canOpenURL = YES;
  if ([_delegate respondsToSelector:
       @selector(alertViewController:didDismissWithButtonIndex:URL:)]) {
    canOpenURL = [_delegate alertViewController:self didDismissWithButtonIndex:buttonIndex URL:URL];
  }
  if (URL && canOpenURL) {
    TTOpenURL(URL);
  }
  if ([_delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
    [_delegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIAlertView*)alertView {
  return (UIAlertView*)self.view;
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

  return [self.alertView addButtonWithTitle:title];
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
- (NSInteger)addCancelButtonWithTitle:(NSString*)title URL:(NSString*)URL
                               target:(NSObject *)target selector:(SEL)selector {
  self.alertView.cancelButtonIndex = [self addButtonWithTitle:title
                                                          URL:URL
                                                       target:target
                                                     selector:selector];
  return self.alertView.cancelButtonIndex;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)addCancelButtonWithTitle:(NSString*)title URL:(NSString*)URL {
  return [self addCancelButtonWithTitle:title URL:URL target:nil selector:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)addCancelButtonWithTitle:(NSString*)title target:(NSObject *)target
                             selector:(SEL)selector {
  return [self addCancelButtonWithTitle:title URL:nil target:target selector:selector];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)buttonURLAtIndex:(NSInteger)buttonIndex {
  id URL = [_URLs objectAtIndex:buttonIndex];
  return URL != [NSNull null] ? URL : nil;
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
