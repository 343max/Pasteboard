//
//  PBAppDelegate.m
//  PasteboardIOS
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import "PBPasteboardCentralAndPeripheralController.h"
#import "PBDevicesViewController.h"
#import "PBAppDelegate.h"

@interface PBAppDelegate ()

- (void)didReceiveText:(NSNotification *)notification;

@end


@implementation PBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _connectionController = [[PBPasteboardCentralAndPeripheralController alloc] initWithName:[UIDevice currentDevice].name];
    
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
}

@end
