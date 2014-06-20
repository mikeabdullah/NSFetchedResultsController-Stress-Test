//
//  FSTMasterViewController.m
//  NSFRC Stress Test
//
//  Created by Mike on 20/06/2014.
//  Copyright (c) 2014 Karelia. All rights reserved.
//

#import "FSTMasterViewController.h"


// Initial Configuration
#define NUMBER_INITIAL_OBJECTS 10
#define USE_PREDICATE 0
#define SPLIT_INTO_SECTIONS 0

// Things to try changing in the model
#define INSERT_OBJECTS 0
#define MAX_INSERTIONS 3
#define DELETE_OBJECTS 0
#define EDIT_INTERVAL 0.5

// How to respond to FRC changes
#define MOVE_ROWS 0
#define RELOAD_ROWS 0
#define DELAY_UPDATING_CELLS 0

// Checks to run
#define CHECK_CELLS 1


@interface FSTMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation FSTMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Generate random objects
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    
    for (NSUInteger i=0; i<NUMBER_INITIAL_OBJECTS; i++) {
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        [newManagedObject setValue:@(rand() % 100 + 1) forKey:@"number"];
    }
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:EDIT_INTERVAL target:self selector:@selector(makeRandomChanges) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)makeRandomChanges {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Thing"];
    NSArray *objects = [self.fetchedResultsController.managedObjectContext executeFetchRequest:request error:NULL];
    
    
#if CHECK_CELLS
    // Check table view is correct first. Run this here, rather than at the end of changes so that
    // animations should have finished
    for (NSIndexPath *aPath in self.tableView.indexPathsForVisibleRows) {
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:aPath];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:aPath];
        if (cell) NSAssert([cell.textLabel.text isEqual:[[object valueForKey:@"number"] description]], @"");
    }
#endif
    
    
#if INSERT_OBJECTS
    // Add in some new objects
    NSUInteger numberToInsert = rand() % (MAX_INSERTIONS + 1);
    for (NSUInteger i=0; i<numberToInsert; i++) {
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Thing" inManagedObjectContext:self.fetchedResultsController.managedObjectContext];
        [newManagedObject setValue:@(rand() % 100 + 1) forKey:@"number"];
    }
#endif
    
    
    // Update some existing objects
    for (NSManagedObject *anObject in objects) {
        
        if (rand() % 10 == 0) {
            [anObject setValue:@(rand() % 100 + 1) forKey:@"number"];
        }
    }
    
    
#if DELETE_OBJECTS
    // Sparingly delete some objects
    for (NSInteger index=objects.count-1; index>=0; index--) {
        if (rand() % objects.count == 0) {
            NSManagedObject *object = objects[index];
            [self.fetchedResultsController.managedObjectContext deleteObject:object];
        }
    }
#endif
    
    
    [self.fetchedResultsController.managedObjectContext save:NULL];
    
    
    // Check the FRC is correct
    objects = self.fetchedResultsController.fetchedObjects;
    NSArray *sorted = [objects sortedArrayUsingDescriptors:
                       @[[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES]]];
    NSAssert([sorted isEqual:objects], @"");
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#if SPLIT_INTO_SECTIONS
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> info = self.fetchedResultsController.sections[section];
    return info.name;
}
#endif

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Thing" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
#if USE_PREDICATE
    // Filter
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"number < 50"];
#endif
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
#if SPLIT_INTO_SECTIONS
    NSString *sectionKeyPath = @"fst_sectionName";
#else
    NSString *sectionKeyPath = nil;
#endif
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionKeyPath cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"Inserting cell at %@.%@, value %@", @(newIndexPath.section), @(newIndexPath.row), [anObject valueForKey:@"number"]);
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"Deleting cell at %@.%@", @(indexPath.section), @(indexPath.row));
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            NSLog(@"Updating cell at %@.%@ to %@", @(indexPath.section), @(indexPath.row), [anObject valueForKey:@"number"]);
#if RELOAD_ROWS
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
#else
#if DELAY_UPDATING_CELLS
            dispatch_async(dispatch_get_main_queue(), ^{
#endif
                [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
#if DELAY_UPDATING_CELLS
            });
#endif
#endif
            break;
        }
        case NSFetchedResultsChangeMove:
            NSLog(@"Moving cell at %@.%@ to %@.%@, value %@", @(indexPath.section), @(indexPath.row), @(newIndexPath.section), @(newIndexPath.row), [anObject valueForKey:@"number"]);
#if MOVE_ROWS
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
#else
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
#endif
            break;
    }
    
    NSLog(@"DUMP: %@", [self.tableView.visibleCells valueForKeyPath:@"textLabel.text"]);
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"number"] description];
}

@end


@implementation NSManagedObject (StressTest)

- (NSString *)fst_sectionName {
//    return @"foo";
    NSNumber *number = [self valueForKey:@"number"];
    NSString *result = [NSString stringWithFormat:@"%@x", @(number.unsignedIntegerValue / 10)];
    return result;
}

@end
