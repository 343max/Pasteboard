//
//  CBPeripheral+PasteboardConnectionController.h
//  PasteboardConnectionController
//
//  Created by Max Winde on 02.02.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif

@interface CBPeripheral (PasteboardConnectionController)

- (CBCharacteristic *)characteristicWithUUID:(CBUUID *)characteristicUUID serviceUUID:(CBUUID *)serviceUUID;

@end
