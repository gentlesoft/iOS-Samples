//
//  DetailViewController.h
//  CoreDataSample
//
//  Created by Kobayashi Shinji on 12/04/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@class DetailViewController;

@protocol DetailViewControllerDelegate

- (void)detailContentDidSave:(DetailViewController*)controller;
- (void)detailContentDidCancel:(DetailViewController*)controller;

@end

@interface DetailViewController : UITableViewController

@property (strong, nonatomic) id<DetailViewControllerDelegate> delegate;
@property (strong, nonatomic) User* user;

- (void)readData:(User*)user;

@end
