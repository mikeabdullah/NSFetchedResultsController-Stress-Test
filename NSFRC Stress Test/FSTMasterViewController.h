//
//  FSTMasterViewController.h
//  NSFRC Stress Test
//
//  Created by Mike on 20/06/2014.
//  Copyright (c) 2014 Karelia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface FSTMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
