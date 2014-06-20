//
//  FSTAppDelegate.h
//  NSFRC Stress Test
//
//  Created by Mike on 20/06/2014.
//  Copyright (c) 2014 Karelia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
