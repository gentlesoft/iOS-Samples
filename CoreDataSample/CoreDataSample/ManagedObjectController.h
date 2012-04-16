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

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

CG_INLINE NSString* uuid() {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uid = CFUUIDCreateString(NULL, uuid);
    NSString* res = (__bridge NSString*)uid;
    CFRelease(uid);
    CFRelease(uuid);
    return res;
}

@end
