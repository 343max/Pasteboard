//
//  PBAppDelegate.h
//  PasteboardIOS
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

#define appDelegate ((PBAppDelegate *)[[UIApplication sharedApplication] delegate])

@class PBPasteboardCentralController;
@class PBPasteboardPeripheralController;

@interface PBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, readonly) PBPasteboardPeripheralController *peripheralController;
@property (strong, readonly) PBPasteboardCentralController *centralController;

@end
