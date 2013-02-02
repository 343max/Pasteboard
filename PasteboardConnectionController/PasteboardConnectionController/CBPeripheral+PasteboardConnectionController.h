//
//  CBPeripheral+PasteboardConnectionController.h
//  PasteboardConnectionController
//
//  Created by Max Winde on 02.02.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (PasteboardConnectionController)

- (CBCharacteristic *)characteristicWithUUID:(CBUUID *)characteristicUUID serviceUUID:(CBUUID *)serviceUUID;

@end
