//
//  OAuthWebViewController.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/26/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol OAuthWebViewControllerDelegate;
@interface OAuthWebViewController : UIViewController

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL *)URL;

@property (nonatomic, strong) UIColor *barsTintColor;
@property (nonatomic, assign) id<OAuthWebViewControllerDelegate> authDelegate;

@end

@protocol OAuthWebViewControllerDelegate <NSObject>

@optional
- (void)receivedTitle:(NSString *)title;

@end