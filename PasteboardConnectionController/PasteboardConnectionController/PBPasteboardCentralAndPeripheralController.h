//
//  PBPasteboardCentralAndPeripheralController.h
//  PasteboardConnectionController
//
//  Created by Max Winde on 25.01.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import "PBPasteboardCentralController.h"

extern NSString * const PBPasteboardDidReceiveTextNotification;
extern NSString * const PBPasteboardPeripheralKey;
extern NSString * const PBPasteboardValueKey;

@interface PBPasteboardCentralAndPeripheralController : PBPasteboardCentralController <CBPeripheralManagerDelegate>

@end
