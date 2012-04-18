//
//  ManagedObjectController.h
//  CoreDataSample
//
//  Created by Kobayashi Shinji on 12/04/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ManagedObjectController : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSFetchRequest* fetchAllSortedByName;

- (NSUInteger)userCount;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
