//
//  PBAppDelegate.m
//  PasteboardOSX
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import "PBPasteboardCentralController.h"
#import "PBAppDelegate.h"

@interface PBAppDelegate ()

- (void)peripheralCountChanged:(NSNotification *)notification;
- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent;

@end


@implementation PBAppDelegate

- (void)peripheralCountChanged:(NSNotification *)notification;
{
    self.window.title = [NSString stringWithFormat:@"%lu peripherals", (unsigned long)self.centralController.connectedPeripherals.count];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent;
{
    NSString *URLString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSURL *URL = [NSURL URLWithString:URLString];
    
    NSLog(@"URL: %@, host: %@, path: %@, query: %@", URL, URL.host, URL.path, URL.query);
    
    CBPeripheral *peripheral = [self.centralController peripheralWithHostname:URL.host];
    
    if (peripheral != nil) {
        if ([URL.path isEqualTo:@"/paste/text"]) {
            [self.centralController pasteText:[URL.query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                   toPeripheral:peripheral];
        }
    }
}


#pragma mark NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self
                           andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                         forEventClass:kInternetEventClass
                            andEventID:kAEGetURL];
    
    NSString *computerName = (__bridge NSString *)SCDynamicStoreCopyComputerName(NULL, NULL);
    _centralController = [[PBPasteboardCentralController alloc] initWithName:computerName];

    [self peripheralCountChanged:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peripheralCountChanged:)
                                                 name:PBPasteboardCentralControllerPeripheralWasConnectedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peripheralCountChanged:)
                                                 name:PBPasteboardCentralControllerPeripheralWasDisconnectedNotification
                                               object:nil];
}

- (void)applicationWillTerminate:(NSNotification *)notification;
{
    NSLog(@"willTerminate");
    [self.centralController disconnectPeripherals];
}

@end
