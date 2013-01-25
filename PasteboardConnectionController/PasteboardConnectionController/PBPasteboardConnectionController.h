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

- initWithName:(NSString *)name;

@property (strong, readonly) CBUUID *pasteboardServiceUUID;
@property (strong, readonly) NSString *name;

@end
