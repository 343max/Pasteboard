//
//  PBPasteboardPayload.h
//  PasteboardConnectionController
//
//  Created by Max Winde on 10.02.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint16_t, PBPasteboardPayloadType) {
    PBPasteboardPayloadTypeString,
    PBPasteboardPayloadTypeJSON
};

@interface PBPasteboardPayload : NSObject

+ (NSData *)encodedDataWithData:(NSData *)data ofType:(PBPasteboardPayloadType)type;
+ (NSData *)encodedDataWithString:(NSString *)string;

@end
