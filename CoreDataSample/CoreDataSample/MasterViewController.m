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

#define SECTION_NO_DATA 0
#define SECTION_NO_MORE 1
#define ROW_READ_COUNT 5

@interface MasterViewController () <DetailViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem* addButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem* editButton;
@property (strong, nonatomic) NSIndexPath* selectedIndex;
@property (strong, nonatomic) User* createdUser;

- (IBAction)editButtonPress:(id)sender;
- (BOOL)hideMoreCell;
- (void)reloadTableData:(BOOL)animated;
- (void)readMoreData;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation MasterViewController

@synthesize managedObjectController = _managedObjectController;
@synthesize addButton = _addButton;
@synthesize editButton = _editButton;
@synthesize selectedIndex = _selectedIndex;
@synthesize createdUser = _createdUser;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                target:self 
                                                                action:@selector(editButtonPress:)];
    _selectedIndex = nil;
    _createdUser = nil;
    
    _currentFetch = self.managedObjectController.fetchAllSortedByName;
    _currentFetch.fetchLimit = ROW_READ_COUNT;
    _currentFetch.fetchBatchSize = ROW_READ_COUNT;
    [self reloadTableData:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    _doneButton = nil;
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
    if (_selectedIndex != nil) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:
                                                [NSIndexPath indexPathForRow:_selectedIndex.row
                                                                   inSection:SECTION_NO_DATA]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if (_createdUser != nil) {
        [_content insertObject:_createdUser atIndex:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:
                                                [NSIndexPath indexPathForRow:0 inSection:SECTION_NO_DATA]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                  inSection:SECTION_NO_DATA]
                              atScrollPosition:UITableViewScrollPositionNone
                                      animated:YES];
    }
    _selectedIndex = nil;
    _createdUser = nil;
}

#pragma mark - Properties

- (NSManagedObjectContext*)managedObjectContext { return self.managedObjectController.managedObjectContext; }

#pragma mark - Action

- (IBAction)editButtonPress:(id)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (![self hideMoreCell]) {
        if (self.tableView.editing)
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:SECTION_NO_MORE]
                          withRowAnimation:UITableViewRowAnimationFade];
        else 
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:SECTION_NO_MORE]
                          withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if (self.tableView.editing) {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        [self.navigationItem setLeftBarButtonItem:_doneButton animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:_addButton animated:YES];
        [self.navigationItem setLeftBarButtonItem:_editButton animated:YES];
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.editing || [self hideMoreCell])
        return 1;
    else 
        return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_NO_DATA:   return [_content count];
        case SECTION_NO_MORE:   return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell;
    switch (indexPath.section) {
        case SECTION_NO_DATA:
            cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
            [self configureCell:cell atIndexPath:indexPath];
            break;
        case SECTION_NO_MORE:
            cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
            break;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    switch (indexPath.section) {
        case SECTION_NO_DATA:   return YES;
        case SECTION_NO_MORE:   return NO;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        User* user = [_content objectAtIndex:indexPath.row];
        [_content removeObjectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:user];
        [self.managedObjectController saveContext];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SECTION_NO_MORE:
            [self readMoreData];
            break;
    }
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

- (BOOL)hideMoreCell {
    return [self.managedObjectController userCount] <= [_content count];
}

- (void)reloadTableData:(BOOL)animated {
    NSError* error;
    _currentFetch.fetchOffset = 0;
    _content = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:_currentFetch
                                                                                       error:&error]];
    [self.tableView reloadData];
}    

- (void)readMoreData {
    NSError* error;
    _currentFetch.fetchOffset = [_content count];
    [_content addObjectsFromArray:[self.managedObjectContext executeFetchRequest:_currentFetch
                                                                           error:&error]];
    [self.tableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    User* user = [_content objectAtIndex:indexPath.row];
    cell.textLabel.text = user.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Tel:%@  Email:%@", user.tel, user.email];
}

@end
