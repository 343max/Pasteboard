//
//  PBPasteboardPayload.m
//  PasteboardConnectionController
//
//  Created by Max Winde on 10.02.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import "PBPasteboardPayloadContainer.h"

@interface PBPasteboardPayloadContainer ()

@property (strong) NSMutableData *mutableData;

@end


@implementation PBPasteboardPayloadContainer

+ (NSData *)encodedDataWithData:(NSData *)payloadData ofType:(PBPasteboardPayloadType)type;
{
    uint32_t payloadLength = (uint32_t)payloadData.length;
    
    NSMutableData *resultData = [[NSMutableData alloc] initWithCapacity:payloadData.length + sizeof(payloadLength) + sizeof(uint16_t) + 2];
    
    [resultData appendData:[@"mw" dataUsingEncoding:NSUTF8StringEncoding]];
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

- (id)init;
{
    return [self initWithStartBlock:nil];
}

- (id)initWithStartBlock:(NSData *)data;
{
    self = [super init];
    
    if (self) {
        _mutableData = [[NSMutableData alloc] init];
        [self appendData:data];
    }
    
    return self;
}

- (NSData *)data;
{
    return [self.mutableData copy];
}

- (NSString *)stringValue;
{
    NSAssert(self.isComplete, @"we need a complete payload container to access its data");
    NSAssert(self.payloadType == PBPasteboardPayloadTypeString, @"payload container does not contain string");
    
    return [[NSString alloc] initWithData:self.mutableData encoding:NSUTF8StringEncoding];
}

- (BOOL)appendData:(NSData *)data;
{
    if (data.length == 0) {
        return self.isComplete;
    }
    
    if (self.mutableData.length != 0) {
        [self.mutableData appendData:data];
        _isComplete = (self.mutableData.length >= self.payloadSize);
    } else {
        NSData *handshake = [data subdataWithRange:NSMakeRange(0, 2)];
        NSString *handshakeString = [[NSString alloc] initWithData:handshake encoding:NSUTF8StringEncoding];
        if (![handshakeString isEqualToString:@"mw"]) {
            NSLog(@"invalid hadshake - ignoring");
            return NO;
        }
        
        NSUInteger blockOffset = sizeof(_payloadType) + sizeof(uint16_t) + 2;
        NSAssert(data.length >= blockOffset, @"firstBlock is to small");
        NSUInteger blockSize = data.length - blockOffset;
        [data getBytes:&_payloadSize range:NSMakeRange(2, sizeof(_payloadSize))];
        [data getBytes:&_payloadType range:NSMakeRange(sizeof(_payloadType) + 2, sizeof(uint16_t))];
        NSData *firstBlock = [data subdataWithRange:NSMakeRange(blockOffset, blockSize)];
        [self.mutableData appendData:firstBlock];
        _isComplete = (self.mutableData.length >= self.payloadSize);
    }
    
    return self.isComplete;
}

@end
