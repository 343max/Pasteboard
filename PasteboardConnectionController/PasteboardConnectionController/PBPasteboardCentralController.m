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

#import "PBPasteboardUUIDs.h"
#import "PBPasteboardPayloadSender.h"
#import "PBPasteboardPayloadReceiver.h"
#import "PBPasteboardCentralController.h"

#define PBLog(format, ...) [self postEventNotification:[NSString stringWithFormat:format, ##__VA_ARGS__]]

NSString * const PBPasteboardCentralControllerStatusDidChangeNotification = @"PBPasteboardCentralControllerStatusDidChangeNotification";
NSString * const PBPasteboardCentralControllerPeripheralWasConnectedNotification = @"PBPasteboardCentralControllerPeripheralWasConnectedNotification";
NSString * const PBPasteboardCentralControllerPeripheralWasDisconnectedNotification = @"PBPasteboardCentralControllerPeripheralWasDisconnectedNotification";
NSString * const PBPasteboardCentralControllerPeripheralKey = @"PBPasteboardCentralControllerPeripheralKey";

NSString * const PBPasteboardCentralControllerEventNotification = @"PBPasteboardCentralControllerEventNotification";

@interface PBPasteboardCentralController ()

@property (strong) NSSet *connectedPeripherals;
@property (strong) NSMutableSet *discoveredUnconnectedPeripherals;
@property (strong, readonly) CBCentralManager *centralManager;

@property (strong, nonatomic) NSArray *registeredPeripheralsUUIDs;

@property (strong, readonly) NSTimer *updateRSSITimer;

- (void)postEventNotification:(NSString *)notificationText;
- (void)updateRSSIOFAllDevices:(NSTimer *)timer;

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
        
        _connectedPeripherals = [[NSSet alloc] init];
        _discoveredUnconnectedPeripherals = [[NSMutableSet alloc] init];
        
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
//        _updateRSSITimer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                            target:self
//                                                          selector:@selector(updateRSSIOFAllDevices:)
//                                                          userInfo:nil
//                                                           repeats:YES];
    }
    
    return self;
}

- (CBPeripheral *)peripheralWithHostname:(NSString *)hostname;
{
    for (CBPeripheral *peripheral in self.connectedPeripherals) {
        if ([peripheral.name caseInsensitiveCompare:hostname] == NSOrderedSame) {
            return peripheral;
        }
    }
    
    return nil;
}

- (void)scanForPeripherals;
{
    [self.centralManager scanForPeripheralsWithServices:@[ [PBPasteboardUUIDs serviceUUID] ] options:nil];
}

- (void)reconnectPeripherals;
{
    [self.centralManager retrievePeripherals:self.registeredPeripheralsUUIDs];
}

- (void)disconnectPeripherals;
{
    for (CBPeripheral *peripheral in self.connectedPeripherals) {
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void)updateRSSIOFAllDevices:(NSTimer *)timer;
{
    for (CBPeripheral *peripheral in [self.connectedPeripherals allObjects]) {
        [peripheral readRSSI];
    }
}

- (void)sendPayload:(PBPasteboardPayloadSender *)payloadSender toPeripheral:(CBPeripheral *)peripheral;
{
    CBCharacteristic *characteristic = [peripheral characteristicWithUUID:[PBPasteboardUUIDs writeTextCharcteristicsUUID]
                                                              serviceUUID:[PBPasteboardUUIDs serviceUUID]];
    NSAssert(characteristic != nil, @"characteristic must not be nil");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *nextChunk = [payloadSender nextChunk];
        
        while (nextChunk != nil) {
            [peripheral writeValue:nextChunk
                 forCharacteristic:characteristic
                              type:CBCharacteristicWriteWithResponse];
            nextChunk = [payloadSender nextChunk];
        }
    });
    
}

- (void)pasteText:(NSString *)text toPeripheral:(CBPeripheral *)peripheral;
{
    [self sendPayload:[PBPasteboardPayloadSender payloadSenderWithString:text]
             toPeripheral:peripheral];
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
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPasteboardCentralControllerStatusDidChangeNotification
                                                        object:self
                                                      userInfo:nil];
    
    PBLog(@"centralManagerDidUpdateState: %li", central.state);
    
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
            [self reconnectPeripherals];
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
    
    CBUUID *peripheralUUID = [CBUUID UUIDWithCFUUID:peripheral.UUID];
    if (![self.registeredPeripheralsUUIDs containsObject:peripheralUUID]) {
        self.registeredPeripheralsUUIDs = [self.registeredPeripheralsUUIDs arrayByAddingObject:peripheralUUID];
    }

    peripheral.delegate = self;
    [peripheral discoverServices:@[ [PBPasteboardUUIDs serviceUUID] ]];
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
        
        // for now we are just trying to reconnect to devices
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [central connectPeripheral:peripheral options:nil];
        });
    }
    
    PBLog(@"didDisconnectPeripheral: %@ error: %@", peripheral.name, error);
}


#pragma mark CBPeripheralDelegate

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals;
{
    for (CBPeripheral *peripheral in peripherals) {
        [central connectPeripheral:peripheral options:nil];
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error;
{
    PBLog(@"peripheral: %@ didUpdateRSSI: %@", peripheral.name, peripheral.RSSI);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
{
    PBLog(@"peripheralDidDiscoverServices: %@ error: %@", peripheral.name, error);
    PBLog(@"services: %@", peripheral.services);
    
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[PBPasteboardUUIDs serviceUUID]]) {
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
        
        [self pasteText:@"I can see you!" toPeripheral:peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error;
{
    PBLog(@"peripheral:didWriteValueForDescriptor:");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
{
    PBLog(@"peripheral:didWriteValueForCharacteristic:");
}

@end
