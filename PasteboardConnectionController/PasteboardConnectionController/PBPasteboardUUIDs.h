//
//  PBPasteboardUUIDs.h
//  PasteboardConnectionController
//
//  Created by Max Winde on 10.02.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBUUID;

@interface PBPasteboardUUIDs : NSObject

+ (CBUUID *)serviceUUID;
+ (CBUUID *)writeTextCharcteristicsUUID;

@end
