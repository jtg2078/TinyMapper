//
//  AppDelegate.h
//  TinyMapper
//
//  Created by ling tsu hsuan on 6/19/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;
@class APIManager;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// my addition
@property (strong, nonatomic) APIManager *apiManager;

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
- (void)dismissModalViewControllerAnimated:(BOOL)animated;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
