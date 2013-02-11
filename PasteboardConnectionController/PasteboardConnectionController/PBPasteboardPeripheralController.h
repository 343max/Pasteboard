//
//  PBPasteboardCentralAndPeripheralController.h
//  PasteboardConnectionController
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

extern NSString * const PBPasteboardPeripheralControllerEventNotification;
extern NSString * const PBPasteboardPeripheralControllerTransferDidStartNotification;
extern NSString * const PBPasteboardPeripheralControllerTransferDidProgressNotification;
extern NSString * const PBPasteboardPeripheralControllerTransferDidEndNotification;
extern NSString * const PBPasteboardDidReceiveTextNotification;
extern NSString * const PBPasteboardPeripheralKey;
extern NSString * const PBPasteboardValueKey;

@interface PBPasteboardPeripheralController : NSObject <CBPeripheralManagerDelegate>

- (id)initWithName:(NSString *)name;

@property (strong, readonly) NSString *name;

@end
