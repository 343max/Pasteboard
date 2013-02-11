//
//  PBPasteboardPayload.m
//  PasteboardConnectionController
//
//  Created by Max Winde on 10.02.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import "PBPasteboardPayloadReceiver.h"

@interface PBPasteboardPayloadReceiver ()

@property (strong) NSMutableData *mutableData;

@end


@implementation PBPasteboardPayloadReceiver

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
        NSUInteger blockOffset = sizeof(_payloadType) + sizeof(uint16_t) + 2;
        if (data.length < blockOffset) {
            NSLog(@"block is to short to be a initial block - ignoring");
            return NO;
        }

        NSData *handshake = [data subdataWithRange:NSMakeRange(0, 2)];
        NSString *handshakeString = [[NSString alloc] initWithData:handshake encoding:NSUTF8StringEncoding];
        if (![handshakeString isEqualToString:@"mw"]) {
            NSLog(@"invalid hadshake - ignoring");
            return NO;
        }
        
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
