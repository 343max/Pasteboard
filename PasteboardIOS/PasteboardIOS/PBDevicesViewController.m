//
//  PBDevicesViewController.m
//  PasteboardIOS
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <PasteboardConnectionControllerLibrary/PBPasteboardCentralAndPeripheralController.h>
#import "PBAppDelegate.h"
#import "PBDevicesViewController.h"

@interface PBDevicesViewController ()

@property (strong) NSMutableArray *messages;
@property (strong) UIAlertView *alertView;

- (void)sendText:(id)sender;
- (void)didReceiveText:(NSNotification *)notification;

@end

@implementation PBDevicesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.messages = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveText:)
                                                     name:PBPasteboardDidReceiveTextNotification
                                                   object:nil];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(sendText:)];
    }
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)sendText:(id)sender;
{
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Send Message"
                                                        message:@"Send the following message"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Send", nil];
    self.alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.alertView textFieldAtIndex:0].placeholder = @"my message";
    __block PBDevicesViewController *blockSelf = self;
    [self.alertView setHandler:^{
        PBPasteboardCentralAndPeripheralController *connectionController = appDelegate.connectionController;
        NSLog(@"text: %@", [blockSelf.alertView textFieldAtIndex:0].text);
        [connectionController sendText:[blockSelf.alertView textFieldAtIndex:0].text
                          toPeripheral:[connectionController.connectedPeripherals anyObject]];
    } forButtonAtIndex:1];
    [self.alertView show];
    
}

- (void)didReceiveText:(NSNotification *)notification;
{
    NSString *text = notification.userInfo[PBPasteboardValueKey];
    
    [self.messages addObject:text];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad;
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.messages[indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return NO;
}

@end
