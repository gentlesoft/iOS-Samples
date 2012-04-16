//
//  MasterViewController.m
//  CoreDataSample
//
//  Created by Kobayashi Shinji on 12/04/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "ManagedObjectController.h"
#import "User.h"

@interface MasterViewController () <DetailViewControllerDelegate>

@property (strong, nonatomic) NSIndexPath* selectedIndex;
@property (strong, nonatomic) User* createdUser;

- (void)reloadTableData;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation MasterViewController

@synthesize managedObjectController = _managedObjectController;
@synthesize selectedIndex = _selectedIndex;
@synthesize createdUser = _createdUser;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self reloadTableData];    
    _selectedIndex = nil;
    _createdUser = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    _content = nil;
    _selectedIndex = nil;
    _createdUser = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView flashScrollIndicators];
    if (_selectedIndex != nil)
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:
                                                [NSIndexPath indexPathForRow:_selectedIndex.row
                                                                   inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    if (_createdUser != nil) {
        [_content insertObject:_createdUser atIndex:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:
                                                [NSIndexPath indexPathForRow:0 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    _selectedIndex = nil;
    _createdUser = nil;
}

#pragma mark - Properties

- (NSManagedObjectContext*)managedObjectContext { return self.managedObjectController.managedObjectContext; }

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [_content count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        User* user = [_content objectAtIndex:indexPath.row];
        [_content removeObjectAtIndex:indexPath.row];
        
        [self.managedObjectContext deleteObject:user];
        
        [self.managedObjectController saveContext];
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailViewController* detailViewController = [segue destinationViewController];
    detailViewController.delegate = self;
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        _selectedIndex = [self.tableView indexPathForSelectedRow];
        detailViewController.user = [_content objectAtIndex:_selectedIndex.row];
        detailViewController.navigationItem.title = @"Edit User";
        
    } else if ([[segue identifier] isEqualToString:@"newDetail"]) {
        _selectedIndex = nil;
        detailViewController.user = nil;
        detailViewController.navigationItem.title = @"New User";
        
    }
}

#pragma mark - DetailViewControllerDelegate

- (void)detailContentDidSave:(DetailViewController *)controller {
    User* user;
    if (_selectedIndex != nil)
        user = [_content objectAtIndex:_selectedIndex.row];
    else {
        user = (User*)[NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                    inManagedObjectContext:self.managedObjectContext];
        _createdUser = user;
    }

    [controller readData:user];
    [self.managedObjectController saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)detailContentDidCancel:(DetailViewController *)controller {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private Method

- (void)reloadTableData {
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSError* error;
    _content = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    [self.tableView reloadData];
}    

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    User* user = [_content objectAtIndex:indexPath.row];
    cell.textLabel.text = user.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Tel:%@  Email:%@", user.tel, user.email];
}

@end
