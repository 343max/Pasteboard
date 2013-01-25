//
//  PBPasteboardCentralAndPeripheralController.m
//  PasteboardConnectionController
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import "PBPasteboardCentralAndPeripheralController.h"

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
            
            CBMutableService *service = [[CBMutableService alloc] initWithType:self.pasteboardServiceUUID primary:YES];
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

@end
