//
//  PBPasteboardConnectionController.m
//  PasteboardIOS
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif

#import "CBPeripheral+PasteboardConnectionController.h"

#import "PBPasteboardCentralController.h"

#define PBLog(format, ...) [self postEventNotification:[NSString stringWithFormat:format, ##__VA_ARGS__]]

NSString * const PBPasteboardCentralControllerStatusDidChangeNotification = @"PBPasteboardCentralControllerStatusDidChangeNotification";
NSString * const PBPasteboardCentralControllerPeripheralWasConnectedNotification = @"PBPasteboardCentralControllerPeripheralWasConnectedNotification";
NSString * const PBPasteboardCentralControllerPeripheralWasDisconnectedNotification = @"PBPasteboardCentralControllerPeripheralWasDisconnectedNotification";
NSString * const PBPasteboardCentralControllerPeripheralKey = @"PBPasteboardCentralControllerPeripheralKey";

NSString * const PBPasteboardCentralControllerEventNotification = @"PBPasteboardCentralControllerEventNotification";

@interface PBPasteboardCentralController ()

@property (strong, nonatomic) NSSet *connectedPeripherals;
@property (strong) NSMutableSet *discoveredUnconnectedPeripherals;
@property (strong, readonly) CBCentralManager *centralManager;

@property (strong, nonatomic) NSArray *registeredPeripheralsUUIDs;

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
        _writeTextCharacteristicUUID = [CBUUID UUIDWithString:@"9606d0b0-6c87-11e2-bcfd-0800200c9a66"];
        
        _connectedPeripherals = [[NSSet alloc] init];
        _discoveredUnconnectedPeripherals = [[NSMutableSet alloc] init];
        
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return self;
}

- (void)scanForPeripherals;
{
    [self.centralManager scanForPeripheralsWithServices:@[ self.pasteboardServiceUUID ] options:nil];
}



- (void)sendText:(NSString *)text toPeripheral:(CBPeripheral *)peripheral;
{
    NSData *value = [text dataUsingEncoding:NSUTF8StringEncoding];
    CBCharacteristic *characteristic = [peripheral characteristicWithUUID:self.writeTextCharacteristicUUID
                                                              serviceUUID:self.pasteboardServiceUUID];
    NSAssert(characteristic != nil, @"characteristic must not be nil");
    [peripheral writeValue:value
         forCharacteristic:characteristic
                      type:CBCharacteristicWriteWithResponse];
}

- (void)postEventNotification:(NSString *)notificationText;
{
    NSLog(@"%@", notificationText);
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPasteboardCentralControllerEventNotification
                                                        object:self
                                                      userInfo:@{ @"text" : notificationText }];
}


#pragma mark Accessors
@synthesize registeredPeripheralsUUIDs = _registeredPeripheralsUUIDs;

- (NSArray *)registeredPeripheralsUUIDs;
{
    if (_registeredPeripheralsUUIDs == nil) {
        NSArray *uuids = [[NSUserDefaults standardUserDefaults] arrayForKey:@"RegisteredPeripherals"];
        NSMutableArray *registeredPeripheralsUUIDs = [[NSMutableArray alloc] initWithCapacity:uuids.count];
        
        for (NSData *uuidData in uuids) {
            [registeredPeripheralsUUIDs addObject:[CBUUID UUIDWithData:uuidData]];
        }
        
        _registeredPeripheralsUUIDs = [registeredPeripheralsUUIDs copy];
    }
    
    return _registeredPeripheralsUUIDs;
}

- (void)setRegisteredPeripheralsUUIDs:(NSArray *)registeredPeripheralsUUIDs;
{
    if ([registeredPeripheralsUUIDs isEqualToArray:_registeredPeripheralsUUIDs]) {
        return;
    }
    
    _registeredPeripheralsUUIDs = registeredPeripheralsUUIDs;
    
    NSMutableArray *uuidsData = [[NSMutableArray alloc] initWithCapacity:registeredPeripheralsUUIDs.count];
    
    for (CBUUID *uuid in registeredPeripheralsUUIDs) {
        [uuidsData addObject:uuid.data];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:uuidsData forKey:@"RegisteredPeripherals"];
}

#pragma mark CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPasteboardCentralControllerStatusDidChangeNotification
                                                        object:self
                                                      userInfo:nil];
    
    PBLog(@"centralManagerDidUpdateState: %i", central.state);
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            PBLog(@"CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            PBLog(@"CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            PBLog(@"CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            PBLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            PBLog(@"CBCentralManagerStatePoweredOff");
            break;
            
        case CBCentralManagerStatePoweredOn:
        {
            PBLog(@"CBCentralManagerStatePoweredOn");
            [self scanForPeripherals];

            break;
        }
        default:
        {
            PBLog(@"don't know what to do");
            break;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI;
{
    PBLog(@"centralManager:didDiscoverPeripheral: %@\n                   advertisementData: %@\n                                RSSI: %@", peripheral.name, advertisementData, RSSI);
    
    if (![self.connectedPeripherals containsObject:peripheral] &&
        ![self.discoveredUnconnectedPeripherals containsObject:peripheral])
    {
        [self.discoveredUnconnectedPeripherals addObject:peripheral];
        [central connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
{
    PBLog(@"didConnectPeripheral: %p %@", peripheral, peripheral.name);
    
    [self.discoveredUnconnectedPeripherals removeObject:peripheral];
    self.connectedPeripherals = [self.connectedPeripherals setByAddingObject:peripheral];

    peripheral.delegate = self;
    [peripheral discoverServices:@[ self.pasteboardServiceUUID ]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    [self.discoveredUnconnectedPeripherals removeObject:peripheral];
    
    PBLog(@"didFailToConnectPeripheral: %@ error: %@", peripheral.name, error);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    if ([self.connectedPeripherals containsObject:peripheral]) {
        NSMutableSet *connectedPeripherals = [self.connectedPeripherals mutableCopy];
        [connectedPeripherals removeObject:peripheral];
        self.connectedPeripherals = [connectedPeripherals copy];

        [[NSNotificationCenter defaultCenter] postNotificationName:PBPasteboardCentralControllerPeripheralWasDisconnectedNotification
                                                            object:self
                                                          userInfo:@{ PBPasteboardCentralControllerPeripheralKey: peripheral }];
    }
    
    PBLog(@"didDisconnectPeripheral: %@ error: %@", peripheral.name, error);
}


#pragma mark CBPeripheralDelegate

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error;
{
    PBLog(@"peripheral: %@ didUpdateRSSI: %@", peripheral.name, peripheral.RSSI);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
{
    PBLog(@"peripheralDidDiscoverServices: %@ error: %@", peripheral.name, error);
    PBLog(@"services: %@", peripheral.services);
    
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:self.pasteboardServiceUUID]) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    PBLog(@"peripheral: %@ didDiscoverCharecteristicsForService: %@ error: %@", peripheral.name, service, error);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPasteboardCentralControllerPeripheralWasConnectedNotification
                                                        object:self
                                                      userInfo:@{ PBPasteboardCentralControllerPeripheralKey: peripheral }];

    for (CBCharacteristic *characteristic in service.characteristics) {
        PBLog(@"characteristic: %@", characteristic);
        
        [self sendText:@"I can see you!" toPeripheral:peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
{
    PBLog(@"peripheral:didWriteValueForCharacteristic:");
}

@end
