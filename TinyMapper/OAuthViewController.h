//
//  OAuthViewController.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/26/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol OAuthViewControllerDelegate;
@interface OAuthViewController : UINavigationController 
{
    
}

@property (assign, nonatomic) id<OAuthViewControllerDelegate> authDelegate;

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL *)URL;

@end


@protocol OAuthViewControllerDelegate <NSObject>

@optional
- (void)receivedAuthToken:(NSString *)token;

@end
