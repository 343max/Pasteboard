//
//  PBPasteboardConnectionController.h
//  PasteboardIOS
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

@interface PBPasteboardConnectionController : NSObject <CBPeripheralManagerDelegate, CBCentralManagerDelegate>

@property (strong, readonly) CBUUID *pasteboardServiceUUID;

@end
