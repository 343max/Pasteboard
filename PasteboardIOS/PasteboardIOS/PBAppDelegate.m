//
//  PBAppDelegate.m
//  PasteboardIOS
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import <PasteboardConnectionControllerLibrary/PBPasteboardCentralController.h>
#import <PasteboardConnectionControllerLibrary/PBPasteboardPeripheralController.h>
#import "PBDevicesViewController.h"
#import "PBAppDelegate.h"

@interface PBAppDelegate ()

- (void)didReceiveText:(NSNotification *)notification;

@end


@implementation PBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _centralController = [[PBPasteboardCentralController alloc] initWithName:[UIDevice currentDevice].model];
    _peripheralController = [[PBPasteboardPeripheralController alloc] initWithName:[UIDevice currentDevice].model];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    PBDevicesViewController *devicesViewController = [[PBDevicesViewController alloc] initWithStyle:UITableViewStylePlain];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:devicesViewController];
    self.window.rootViewController = self.navigationController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveText:)
                                                 name:PBPasteboardDidReceiveTextNotification
                                               object:nil];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)didReceiveText:(NSNotification *)notification;
{
    NSString *text = notification.userInfo[PBPasteboardValueKey];
    
    UILocalNotification *localNotifcation = [[UILocalNotification alloc] init];
    localNotifcation.alertBody = [NSString stringWithFormat:@"did receive text: \"%@\"", text];
    localNotifcation.fireDate = [NSDate date];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotifcation];
    
    [UIPasteboard generalPasteboard].string = text;
}

@end
