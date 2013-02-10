//
//  PBPasteboardConnectionController.h
//  PasteboardIOS
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif

#import <Foundation/Foundation.h>

extern NSString * const PBPasteboardCentralControllerStatusDidChangeNotification;
extern NSString * const PBPasteboardCentralControllerPeripheralWasConnectedNotification;
extern NSString * const PBPasteboardCentralControllerPeripheralWasDisconnectedNotification;
extern NSString * const PBPasteboardCentralControllerPeripheralKey;

extern NSString * const PBPasteboardCentralControllerEventNotification;


@interface PBPasteboardCentralController : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

- (id)initWithName:(NSString *)name;

- (void)scanForPeripherals;
- (void)reconnectPeripherals;
- (void)disconnectPeripherals;

- (void)pasteText:(NSString *)text toPeripheral:(CBPeripheral *)peripheral;

- (CBPeripheral *)peripheralWithHostname:(NSString *)hostname;

@property (strong, readonly) NSString *name;

@property (readonly, nonatomic) NSSet *connectedPeripherals;

@end
