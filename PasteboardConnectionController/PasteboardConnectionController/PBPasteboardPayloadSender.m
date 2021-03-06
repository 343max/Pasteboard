//
//  PBPayloadSender.m
//  PasteboardIOS
//
//  Created by Max Winde on 11.02.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import "PBPasteboardPayloadSender.h"

@implementation PBPasteboardPayloadSender

+ (PBPasteboardPayloadSender *)payloadSenderWithData:(NSData *)payloadData ofType:(PBPasteboardPayloadType)type;
{
    return [[PBPasteboardPayloadSender alloc] initWithData:payloadData ofType:type];
}

+ (PBPasteboardPayloadSender *)payloadSenderWithString:(NSString *)string;
{
    return [self payloadSenderWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                ofType:PBPasteboardPayloadTypeString];
}

- (id)initWithData:(NSData *)data ofType:(PBPasteboardPayloadType)type;
{
    self = [super init];
    
    if (self) {
        uint32_t payloadLength = (uint32_t)data.length;
        
        NSMutableData *resultData = [[NSMutableData alloc] initWithCapacity:data.length + sizeof(payloadLength) + sizeof(uint16_t) + 2];
        
        [resultData appendData:[@"mw" dataUsingEncoding:NSUTF8StringEncoding]];
        [resultData appendBytes:&payloadLength length:sizeof(payloadLength)];
        [resultData appendBytes:&type length:sizeof(uint16_t)];
        [resultData appendData:data];
        
        _data = [resultData copy];
    }
    
    return self;
}

- (void)resetOffset;
{
    _offset = 0;
}

- (NSData *)nextChunk;
{
    NSRange range = NSMakeRange(_offset, 18);
    
    if (NSMaxRange(range) > self.data.length) {
        range.length = MAX(self.data.length - range.location, 0);
    }
    
    if (range.length == 0) {
        return nil;
    }
    
    NSData *returnData = [self.data subdataWithRange:range];
    _offset = NSMaxRange(range);
    return returnData;
}

@end
