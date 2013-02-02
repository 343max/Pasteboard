//
//  CBPeripheral+PasteboardConnectionController.m
//  PasteboardConnectionController
//
//  Created by Max Winde on 02.02.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import "CBPeripheral+PasteboardConnectionController.h"

@implementation CBPeripheral (PasteboardConnectionController)

- (CBCharacteristic *)characteristicWithUUID:(CBUUID *)characteristicUUID serviceUUID:(CBUUID *)serviceUUID;
{
    for (CBService *service in self.services) {
        if ([service.UUID isEqual:serviceUUID]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:characteristicUUID]) {
                    return characteristic;
                }
            }
        }
    }
    
    return nil;
}

@end
