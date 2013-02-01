//
//  PBPasteboardCentralAndPeripheralController.m
//  PasteboardConnectionController
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import "PBPasteboardCentralAndPeripheralController.h"

NSString * const PBPasteboardDidReceiveTextNotification = @"PBPasteboardDidReceiveTextNotification";
NSString * const PBPasteboardPeripheralKey = @"PBPasteboardPeripheralKey";
NSString * const PBPasteboardValueKey = @"PBPasteboardValueKey";

@interface PBPasteboardCentralAndPeripheralController ()

@property (strong) CBPeripheralManager *peripheralManager;

@end


@implementation PBPasteboardCentralAndPeripheralController

- (id)initWithName:(NSString *)name;
{
    self = [super initWithName:name];
    
    if (self) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return self;
}


#pragma mark CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral;
{
    NSLog(@"peripheralManagerDidUpdateState: %i", peripheral.state);
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
        {
            NSLog(@"CBPeripheralManagerStatePoweredOn");
            
            CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:self.writeCharacteristicUUID
                                                                                         properties:CBCharacteristicPropertyWrite
                                                                                              value:nil
                                                                                        permissions:CBAttributePermissionsWriteable];
            CBMutableService *service = [[CBMutableService alloc] initWithType:self.pasteboardServiceUUID primary:YES];
            service.characteristics = @[ characteristic ];
            [peripheral addService:service];

            break;
        }
        default:
        {
            NSLog(@"don't know what to do");
            break;
        }
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error;
{
    NSLog(@"peripheralManager:didAddService: %@ error: %@", service, error);
    
    NSDictionary *dict = @{
        CBAdvertisementDataLocalNameKey: self.name,
        CBAdvertisementDataServiceUUIDsKey: @[ self.pasteboardServiceUUID ]
    };
    
    NSLog(@"advertismentData: %@", dict);
    
    [peripheral startAdvertising:dict];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error;
{
    NSLog(@"peripheralManagerDidStartAdvertising:error: %@", error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests;
{
    for (CBATTRequest *request in requests) {
        NSString *stringValue = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
        NSLog(@"peripheral:didReceiveWriteRequest: %@", stringValue);
        
        NSDictionary *userInfo = @{
            PBPasteboardPeripheralKey: peripheral,
            PBPasteboardValueKey: stringValue
        };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PBPasteboardDidReceiveTextNotification
                                                            object:self
                                                          userInfo:userInfo];
    }
}

@end
