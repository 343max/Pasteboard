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

@interface PBPasteboardCentralController : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

- initWithName:(NSString *)name;

- (void)sendText:(NSString *)text toPeripheral:(CBPeripheral *)peripheral;

@property (strong, readonly) CBUUID *pasteboardServiceUUID;
@property (strong, readonly) CBUUID *writeTextCharacteristicUUID;

@property (strong, readonly) NSString *name;

@property (readonly, nonatomic) NSSet *connectedPeripherals;

@end
