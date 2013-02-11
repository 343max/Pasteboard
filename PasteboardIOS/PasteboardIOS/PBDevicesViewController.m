//
//  PBDevicesViewController.m
//  PasteboardIOS
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "PBPasteboardCentralController.h"
#import "PBPasteboardPeripheralController.h"
#import "PBAppDelegate.h"
#import "PBDevicesViewController.h"

@interface PBDevicesViewController ()

@property (strong) NSMutableArray *messages;
@property (strong) UIAlertView *alertView;

- (void)sendText:(id)sender;
- (void)didReceiveText:(NSNotification *)notification;
- (void)didReceiveEvent:(NSNotification *)notification;
- (void)peripheralCountChanged:(NSNotification *)notification;

- (void)transferDidStart:(NSNotification *)notifcation;
- (void)transferDidProgress:(NSNotification *)notification;
- (void)transferDidEnd:(NSNotification *)notification;

@end

@implementation PBDevicesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.messages = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(transferDidStart:)
                                                     name:PBPasteboardPeripheralControllerTransferDidStartNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(transferDidProgress:)
                                                     name:PBPasteboardPeripheralControllerTransferDidProgressNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(transferDidEnd:)
                                                     name:PBPasteboardPeripheralControllerTransferDidEndNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveText:)
                                                     name:PBPasteboardDidReceiveTextNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveEvent:)
                                                     name:PBPasteboardCentralControllerEventNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveEvent:)
                                                     name:PBPasteboardPeripheralControllerEventNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(peripheralCountChanged:)
                                                     name:PBPasteboardCentralControllerPeripheralWasConnectedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(peripheralCountChanged:)
                                                     name:PBPasteboardCentralControllerPeripheralWasDisconnectedNotification
                                                   object:nil];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(sendText:)];
        
        [self peripheralCountChanged:nil];
    }
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)transferDidStart:(NSNotification *)notifcation;
{
    self.navigationItem.titleView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
}

- (void)transferDidProgress:(NSNotification *)notification;
{
    UIProgressView *progressView = (UIProgressView *)self.navigationItem.titleView;
    
    NSInteger complete = [notification.userInfo[@"complete"] integerValue];
    NSInteger total = [notification.userInfo[@"total"] integerValue];
    
    [progressView setProgress:(float)complete / total animated:YES];
}

- (void)transferDidEnd:(NSNotification *)notification;
{
    self.navigationItem.titleView = nil;
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
        PBPasteboardCentralController *centralController = appDelegate.centralController;
        NSLog(@"text: %@", [blockSelf.alertView textFieldAtIndex:0].text);
        [centralController pasteText:[blockSelf.alertView textFieldAtIndex:0].text
                        toPeripheral:[centralController.connectedPeripherals anyObject]];
    } forButtonAtIndex:1];
    [self.alertView show];
    
}

- (void)didReceiveText:(NSNotification *)notification;
{
    NSString *text = notification.userInfo[PBPasteboardValueKey];
    CBPeripheral *peripheral = notification.userInfo[PBPasteboardCentralControllerPeripheralKey];
    
    if (peripheral == nil) {
        peripheral = (id)[NSNull null];
    }
    
    [self.messages addObject:@{
        @"kind": @"Text",
        @"message": text,
        @"peripheral": peripheral
    }];
    
    [self.tableView reloadData];
}

- (void)didReceiveEvent:(NSNotification *)notification;
{
    [self.messages addObject:@{
        @"kind": @"Log",
        @"message": notification.userInfo[@"text"],
        @"date": [NSDate date]
    }];
    
    [self.tableView reloadData];
}

- (void)peripheralCountChanged:(NSNotification *)notification;
{
    self.title = [NSString stringWithFormat:@"%i peripherals", appDelegate.centralController.connectedPeripherals.count];
    self.navigationItem.rightBarButtonItem.enabled = (appDelegate.centralController.connectedPeripherals.count) != 0;
}

- (void)viewDidLoad;
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Text"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Log"];
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
    NSDictionary *dict = self.messages[indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dict[@"kind"]
                                                            forIndexPath:indexPath];
    

    if ([dict[@"kind"] isEqualToString:@"Text"]) {
        CBPeripheral *peripheral = dict[@"peripheral"];
        cell.textLabel.text = dict[@"message"];
        if ([NSNull null] != (id)peripheral) {
            cell.detailTextLabel.text = peripheral.name;
        }
    } else if([dict[@"kind"] isEqualToString:@"Log"]) {
        cell.textLabel.text = dict[@"message"];
        cell.detailTextLabel.text = dict[@"date"];
        cell.textLabel.font = [UIFont fontWithName:@"Courier" size:11.0];
        cell.textLabel.numberOfLines = 0;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return NO;
}

@end
