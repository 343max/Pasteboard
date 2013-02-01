//
//  PBPasteboardConnectionController.m
//  PasteboardIOS
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import "PBPasteboardCentralController.h"

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif


@interface PBPasteboardCentralController ()

@property (strong, readonly) NSMutableSet *connectedPeripherals;
@property (strong, readonly) CBCentralManager *centralManager;

@end


@implementation PBPasteboardCentralController

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
        _writeCharacteristicUUID = [CBUUID UUIDWithString:@"9606d0b0-6c87-11e2-bcfd-0800200c9a66"];
        
        _connectedPeripherals = [[NSMutableSet alloc] init];
        
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return self;
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
    
    if (![self.connectedPeripherals containsObject:peripheral]) {
        [self.connectedPeripherals addObject:peripheral];
        [central connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
{
    NSLog(@"didConnectPeripheral: %@", peripheral.name);
    
    peripheral.delegate = self;
    [peripheral discoverServices:@[ self.pasteboardServiceUUID ]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    [self.connectedPeripherals removeObject:peripheral];
    
    NSLog(@"didFailToConnectPeripheral: %@ error: %@", peripheral.name, error);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    [self.connectedPeripherals removeObject:peripheral];
    
    NSLog(@"didDisconnectPeripheral: %@ error: %@", peripheral.name, error);
}


#pragma mark CBPeripheralDelegate

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error;
{
    NSLog(@"peripheral: %@ didUpdateRSSI: %@", peripheral.name, peripheral.RSSI);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
{
    NSLog(@"peripheralDidDiscoverServices: %@ error: %@", peripheral.name, error);
    NSLog(@"services: %@", peripheral.services);
    
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:self.pasteboardServiceUUID]) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    NSLog(@"peripheral: %@ didDiscoverCharecteristicsForService: %@ error: %@", peripheral.name, service, error);
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"characteristic: %@", characteristic);
        
        [peripheral writeValue:[@"Hello" dataUsingEncoding:NSUTF8StringEncoding]
             forCharacteristic:characteristic
                          type:CBCharacteristicWriteWithResponse];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
{
    NSLog(@"peripheral:didWriteValueForCharacteristic:");
}

@end
