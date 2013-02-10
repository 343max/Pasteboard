//
//  PBPasteboardPayload.m
//  PasteboardConnectionController
//
//  Created by Max Winde on 10.02.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import "PBPasteboardPayload.h"

@implementation PBPasteboardPayload

+ (NSData *)encodedDataWithData:(NSData *)payloadData ofType:(PBPasteboardPayloadType)type;
{
    uint32_t payloadLength = (uint32_t)payloadData.length;
    
    NSMutableData *resultData = [[NSMutableData alloc] initWithCapacity:payloadData.length + sizeof(payloadLength) + sizeof(uint16_t)];
    
    [resultData appendBytes:&payloadLength length:sizeof(payloadLength)];
    [resultData appendBytes:&type length:sizeof(uint16_t)];
    [resultData appendData:payloadData];
    
    return [resultData copy];
}

+ (NSData *)encodedDataWithString:(NSString *)string;
{
    return [self encodedDataWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
                              ofType:PBPasteboardPayloadTypeString];
}

@end
