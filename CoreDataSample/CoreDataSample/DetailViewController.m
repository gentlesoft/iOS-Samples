//
//  DetailViewController.m
//  CoreDataSample
//
//  Created by Kobayashi Shinji on 12/04/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "User.h"

@interface DetailViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField* nameField;
@property (weak, nonatomic) IBOutlet UITextField* telField;
@property (weak, nonatomic) IBOutlet UITextField* emailField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* saveButton;

- (IBAction)saveButtonPresss:(id)sender;
- (IBAction)cancelButtonPress:(id)sender;
- (void)loadViewWithUser:(User*)user;

@end

@implementation DetailViewController

@synthesize delegate = _delegate;
@synthesize user = _user;
@synthesize nameField = _nameField;
@synthesize telField = _telField;
@synthesize emailField = _emailField;
@synthesize saveButton = _saveButton;

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self loadViewWithUser:_user];
    [_nameField becomeFirstResponder];
}

#pragma mark - Public Method

- (void)readData:(User*)user {
    user.name = _nameField.text;
    user.tel = _telField.text;
    user.email = _emailField.text;
    user.timeStamp = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - Action

- (IBAction)saveButtonPresss:(id)sender {
    [_delegate detailContentDidSave:self];
    _delegate = nil;
    _user = nil;
}

- (IBAction)cancelButtonPress:(id)sender {
    [_delegate detailContentDidCancel:self];
    _delegate = nil;
    _user = nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField != _nameField)
        return YES;
    
    NSString* chaged = [textField.text stringByReplacingCharactersInRange:range withString:string];
    _saveButton.enabled = chaged.length > 0;
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField != _nameField)
        return YES;
    
    _saveButton.enabled = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _nameField)
        [_telField becomeFirstResponder];
    else if (textField == _telField)
        [_emailField becomeFirstResponder];
    else if (textField == _emailField)
        [_nameField becomeFirstResponder];
    return YES;
}

#pragma mark - Private Method

- (void)loadViewWithUser:(User*)user {
    if (user != nil) {
        _nameField.text = user.name;
        _telField.text = user.tel;
        _emailField.text = user.email;
        
    } else {
        _nameField.text = @"";
        _telField.text = @"";
        _emailField.text = @"";
    }
    _saveButton.enabled = _nameField.text.length > 0;
}

@end


