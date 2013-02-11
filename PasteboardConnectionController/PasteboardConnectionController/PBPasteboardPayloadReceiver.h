//
//  PBPasteboardPayload.h
//  PasteboardConnectionController
//
//  Created by Max Winde on 10.02.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint16_t, PBPasteboardPayloadType) {
    PBPasteboardPayloadTypeString
};

@interface PBPasteboardPayloadReceiver : NSObject

- (id)initWithStartBlock:(NSData *)data;
- (BOOL)appendData:(NSData *)data;
- (NSString *)stringValue;

@property (assign, readonly) NSUInteger payloadSize;
@property (assign, readonly) PBPasteboardPayloadType payloadType;
@property (readonly, nonatomic) NSData *data;
@property (readonly, assign) BOOL isComplete;

@end
