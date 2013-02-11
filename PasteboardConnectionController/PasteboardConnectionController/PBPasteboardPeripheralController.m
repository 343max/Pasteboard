//
//  PBPasteboardCentralAndPeripheralController.m
//  PasteboardConnectionController
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "PBPasteboardUUIDs.h"
#import "PBPasteboardPayloadContainer.h"
#import "PBPasteboardPeripheralController.h"

#define PBLog(format, ...) [self postEventNotification:[NSString stringWithFormat:format, ##__VA_ARGS__]]

NSString * const PBPasteboardPeripheralControllerEventNotification = @"PBPasteboardPeripheralControllerEventNotification";
NSString * const PBPasteboardDidReceiveTextNotification = @"PBPasteboardDidReceiveTextNotification";
NSString * const PBPasteboardPeripheralKey = @"PBPasteboardPeripheralKey";
NSString * const PBPasteboardValueKey = @"PBPasteboardValueKey";

@interface PBPasteboardPeripheralController ()

@property (strong) CBPeripheralManager *peripheralManager;
@property (strong) PBPasteboardPayloadContainer *payloadContainer;

- (void)postEventNotification:(NSString *)notificationText;

@end


@implementation PBPasteboardPeripheralController

- (id)initWithName:(NSString *)name;
{
    self = [super init];
    
    if (self) {
        _name = name;
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return self;
}

- (void)postEventNotification:(NSString *)notificationText;
{
    NSLog(@"%@", notificationText);
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPasteboardPeripheralControllerEventNotification
                                                        object:self
                                                      userInfo:@{ @"text" : notificationText }];
}

#pragma mark CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral;
{
    PBLog(@"peripheralManagerDidUpdateState: %i", peripheral.state);
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
        {
            PBLog(@"CBPeripheralManagerStatePoweredOn");
            
            CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:[PBPasteboardUUIDs writeTextCharcteristicsUUID]
                                                                                         properties:CBCharacteristicPropertyWrite
                                                                                              value:nil
                                                                                        permissions:CBAttributePermissionsWriteable];
            CBMutableService *service = [[CBMutableService alloc] initWithType:[PBPasteboardUUIDs serviceUUID] primary:YES];
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
        CBAdvertisementDataServiceUUIDsKey: @[ [PBPasteboardUUIDs serviceUUID] ]
    };
    
    PBLog(@"advertismentData: %@", dict);
    
    [peripheral startAdvertising:dict];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error;
{
    PBLog(@"peripheralManagerDidStartAdvertising:error: %@", error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didSubscribeToCharacteristic:(CBCharacteristic *)characteristic;
{
    PBLog(@"peripheralManager:central:didSubscribeToCharacteristic: %@", characteristic);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic;
{
    PBLog(@"peripheralManager:central:didUnsubscribeFromCharacteristic: %@", characteristic);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request;
{
    PBLog(@"peripheralManager:didReceiveReadRequest: %@", request);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests;
{
    for (CBATTRequest *request in requests) {
        if (self.payloadContainer == nil) {
            self.payloadContainer = [[PBPasteboardPayloadContainer alloc] init];
        }
        
        [self.payloadContainer appendData:request.value];
        PBLog(@"peripheral:didReceiveWriteRequest: isComplete: %i", self.payloadContainer.isComplete);
        
        if (self.payloadContainer.isComplete) {
            switch (self.payloadContainer.payloadType) {
                case PBPasteboardPayloadTypeString:
                {
                    NSDictionary *userInfo = @{
                                               PBPasteboardPeripheralKey: peripheral,
                                               PBPasteboardValueKey: [self.payloadContainer stringValue]
                                               };
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:PBPasteboardDidReceiveTextNotification
                                                                        object:self
                                                                      userInfo:userInfo];
                    break;
                }
            }
            
            self.payloadContainer = nil;
        }
        
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

@end
