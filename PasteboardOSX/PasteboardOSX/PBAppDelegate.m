//
//  PBAppDelegate.m
//  PasteboardOSX
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import <IOBluetooth/IOBluetooth.h>
#import "PBAppDelegate.h"

@interface PBAppDelegate ()

@property (strong) CBCentralManager *centralManager;

- (void)startScan;

@end


@implementation PBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    [self startScan];
}

- (void)startScan;
{
    CBUUID *serviceUUID = [CBUUID UUIDWithString:@"d6f23f70-66ff-11e2-bcfd-0800200c9a66"];
//    NSDictionary *scanningOptions = @{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES };
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}


#pragma mark CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
{
    NSLog(@"centralManagerDidUpdateState: %li", central.state);
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI;
{
    NSLog(@"RSSI: %@", RSSI);
    NSLog(@"discovered: %@, %@", peripheral.name, peripheral.UUID);
    NSLog(@"advertismentData: %@", advertisementData);
    NSLog(@"services: %@", peripheral.services);
    
    [central connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
{
    NSLog(@"didConnect");
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    NSLog(@"didDisconnect");
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals;
{
    NSLog(@"didRetreivePeriperals: %@", peripherals);
}

@end
