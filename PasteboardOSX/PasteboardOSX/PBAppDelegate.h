//
//  PBAppDelegate.h
//  PasteboardOSX
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PBAppDelegate : NSObject <NSApplicationDelegate>

@property (strong, readonly) PBPasteboardCentralController *pasteboardController;
@property (assign) IBOutlet NSWindow *window;

@end
