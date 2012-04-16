//
//  MasterViewController.h
//  CoreDataSample
//
//  Created by Kobayashi Shinji on 12/04/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@class ManagedObjectController;

@interface MasterViewController : UITableViewController {
    UIBarButtonItem* _doneButton;
    NSMutableArray* _content;
    NSFetchRequest* _currentFetch;
}

@property (strong, nonatomic) ManagedObjectController* managedObjectController;
@property (readonly, nonatomic) NSManagedObjectContext* managedObjectContext;

@end
