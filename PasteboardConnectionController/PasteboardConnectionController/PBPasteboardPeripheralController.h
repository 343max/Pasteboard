//
//  PBPasteboardCentralAndPeripheralController.h
//  PasteboardConnectionController
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

extern NSString * const PBPasteboardPeripheralControllerEventNotification;
extern NSString * const PBPasteboardTransmissionDidStartNotification;
extern NSString * const PBPasteboardTransmissionDidProgressNotification;
extern NSString * const PBPasteboardTransmissionDidEndNotification;
extern NSString * const PBPasteboardDidReceiveTextNotification;
extern NSString * const PBPasteboardPeripheralKey;
extern NSString * const PBPasteboardValueKey;

@interface PBPasteboardPeripheralController : NSObject <CBPeripheralManagerDelegate>

- (id)initWithName:(NSString *)name;

@property (strong, readonly) NSString *name;

@end
