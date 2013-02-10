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
    self.window.title = [NSString stringWithFormat:@"%lu peripherals", (unsigned long)self.pasteboardController.connectedPeripherals.count];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent;
{
    NSString *URLAsString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSLog(@"URL: %@", URLAsString);
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
    _pasteboardController = [[PBPasteboardCentralController alloc] initWithName:computerName];

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

@end
