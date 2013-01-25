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

@property (strong) PBPasteboardCentralController *pasteboardController;

@end


@implementation PBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *computerName = (__bridge NSString *)SCDynamicStoreCopyComputerName(NULL, NULL);
    self.pasteboardController = [[PBPasteboardCentralController alloc] initWithName:computerName];
}

@end
