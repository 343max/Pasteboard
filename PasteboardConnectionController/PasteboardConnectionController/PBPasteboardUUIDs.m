//
//  PBPasteboardUUIDs.m
//  PasteboardConnectionController
//
//  Created by Max Winde on 10.02.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif

#import "PBPasteboardUUIDs.h"

@implementation PBPasteboardUUIDs

static CBUUID *serviceUUID;
static CBUUID *writeTextCharcteristicsUUID;


+ (CBUUID *)serviceUUID;
{
    if (serviceUUID == nil) {
        serviceUUID = [CBUUID UUIDWithString:@"d6f23f70-66ff-11e2-bcfd-0800200c9a66"];
    }
    
    return serviceUUID;
}

+ (CBUUID *)writeTextCharcteristicsUUID;
{
    if (writeTextCharcteristicsUUID == nil) {
        writeTextCharcteristicsUUID = [CBUUID UUIDWithString:@"9606d0b0-6c87-11e2-bcfd-0800200c9a66"];
    }
    
    return writeTextCharcteristicsUUID;
}

@end
