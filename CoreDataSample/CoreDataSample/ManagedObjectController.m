//
//  ManagedObjectController.m
//  CoreDataSample
//
//  Created by Kobayashi Shinji on 12/04/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ManagedObjectController.h"

@interface ManagedObjectController()

@property (readonly, nonatomic) NSURL* cloudPath;
@property (readonly, nonatomic) NSURL* tlogPath;

- (void)initCloudPath;
- (void)mergeChangesFrom_iCloud:(NSNotification*)notification;

@end

@implementation ManagedObjectController

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize fetchAllSortedByName = _fetchAllSortedByName;
@synthesize cloudPath = _cloudPath;
@synthesize tlogPath = _tlogPath;

- (id)init {
    self = [super init];
    if (self != nil) {
        [self initCloudPath];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(mergeChangesFrom_iCloud:) 
                                                     name:NSPersistentStoreDidImportUbiquitousContentChangesNotification 
                                                   object:nil];
    }
    return self;
}

#pragma mark - Public Method

- (NSUInteger)userCount {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.resultType = NSCountResultType;
    NSArray* result = [self.managedObjectContext executeFetchRequest:request error:nil];
    if (result != nil && [result count] > 0)
        return [[result objectAtIndex:0] intValue];
    else 
        return 0;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Properties

- (NSFetchRequest*)fetchAllSortedByName {
    if (_fetchAllSortedByName != nil)
        return _fetchAllSortedByName;
    
    _fetchAllSortedByName = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    _fetchAllSortedByName.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    return _fetchAllSortedByName;
}

#pragma mark - Core Data stack

// NSNotifications are posted synchronously on the caller's thread
// make sure to vector this back to the thread we want, in this case
// the main thread for our views & controller
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:@"RefetchAllDatabaseData" 
                                   object:self  
                                 userInfo:[notification userInfo]]];
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
        __managedObjectContext.mergePolicy = [[NSMergePolicy alloc] 
                                              initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
    }
        
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataSample" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataSample.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary* options;
    if (self.cloudPath != nil){
        options = [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                   [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                   @"CoreDataSample.store", NSPersistentStoreUbiquitousContentNameKey,
                   self.tlogPath, NSPersistentStoreUbiquitousContentURLKey,
                   nil];
    } else {
        options = [[NSDictionary alloc] initWithObjectsAndKeys:
                   [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption
                   , [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption
                   , nil];
    }
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                    configuration:nil 
                                                              URL:storeURL 
                                                          options:options
                                                            error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }  
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Private Method

- (void)initCloudPath 
{
    _tlogPath = nil;
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    _cloudPath = [fileMgr URLForUbiquityContainerIdentifier:nil];
    if (_cloudPath == nil)
        return;
    
    _cloudPath = [_cloudPath URLByAppendingPathComponent:@"Documents" isDirectory:YES];
    _tlogPath = [_cloudPath URLByAppendingPathComponent:@"TLOG" isDirectory:YES];
    
    BOOL exists, isDir;
    [fileMgr createDirectoryAtURL:_cloudPath withIntermediateDirectories:NO attributes:nil error:nil];
    exists = [fileMgr fileExistsAtPath:[_cloudPath relativePath] isDirectory:&isDir];
    if (exists && isDir) {
        [fileMgr createDirectoryAtURL:_tlogPath withIntermediateDirectories:NO attributes:nil error:nil];    
        exists = [fileMgr fileExistsAtPath:[_tlogPath relativePath] isDirectory:&isDir];
        //directory exists
        if (exists && isDir)
            return;
    }
    
    //fail create directrory
    _cloudPath = nil;
    _tlogPath = nil;
}


@end
