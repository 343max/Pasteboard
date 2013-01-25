//
//  PBPasteboardConnectionController.m
//  PasteboardIOS
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import "PBPasteboardConnectionController.h"

@interface PBPasteboardConnectionController ()

@property (strong) CBPeripheralManager *peripheralManager;
@property (strong) CBCentralManager *centralManager;

@end


@implementation PBPasteboardConnectionController

- (id)init;
{
    return [self initWithName:@"Device"];
}

- (id)initWithName:(NSString *)name;
{
    self = [super init];
    
    if (self) {
        _name = name;
        _pasteboardServiceUUID = [CBUUID UUIDWithString:@"d6f23f70-66ff-11e2-bcfd-0800200c9a66"];
        
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
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


#pragma mark CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
{
    NSLog(@"centralManagerDidUpdateState: %i", central.state);
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CBCentralManagerStatePoweredOff");
            break;
            
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@"CBCentralManagerStatePoweredOn");
            [central scanForPeripheralsWithServices:@[ self.pasteboardServiceUUID ] options:nil];

            break;
        }
        default:
        {
            NSLog(@"don't know what to do");
            break;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI;
{
    NSLog(@"centralManager:didDiscoverPeripheral: %@\n                   advertisementData: %@\n                                RSSI: %@", peripheral.name, advertisementData, RSSI);
}



@end
