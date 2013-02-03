//
//  PBPasteboardCentralAndPeripheralController.m
//  PasteboardConnectionController
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import "PBPasteboardCentralAndPeripheralController.h"

#define PBLog(format, ...) [self postEventNotification:[NSString stringWithFormat:format, ##__VA_ARGS__]]

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
    PBLog(@"peripheralManagerDidUpdateState: %i", peripheral.state);
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
        {
            PBLog(@"CBPeripheralManagerStatePoweredOn");
            
            CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:self.writeTextCharacteristicUUID
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
            PBLog(@"don't know what to do");
            break;
        }
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error;
{
    PBLog(@"peripheralManager:didAddService: %@ error: %@", service, error);
    
    NSDictionary *dict = @{
        CBAdvertisementDataLocalNameKey: self.name,
        CBAdvertisementDataServiceUUIDsKey: @[ self.pasteboardServiceUUID ]
    };
    
    PBLog(@"advertismentData: %@", dict);
    
    [peripheral startAdvertising:dict];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error;
{
    PBLog(@"peripheralManagerDidStartAdvertising:error: %@", error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheralManager didReceiveWriteRequests:(NSArray *)requests;
{
    for (CBATTRequest *request in requests) {
        NSString *stringValue = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
        PBLog(@"peripheral:didReceiveWriteRequest: %@", stringValue);
        
        NSDictionary *userInfo = @{
            PBPasteboardPeripheralKey: peripheralManager,
            PBPasteboardValueKey: stringValue
        };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PBPasteboardDidReceiveTextNotification
                                                            object:self
                                                          userInfo:userInfo];
    }
}

@end
