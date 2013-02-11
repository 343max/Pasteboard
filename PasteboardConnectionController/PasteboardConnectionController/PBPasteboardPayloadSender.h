//
//  PBPayloadSender.h
//  PasteboardIOS
//
//  Created by Max Winde on 11.02.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import "PBPasteboardPayloadReceiver.h"
#import <Foundation/Foundation.h>

@interface PBPasteboardPayloadSender : NSObject

@property (strong, readonly) NSData *data;

- (id)initWithData:(NSData *)data ofType:(PBPasteboardPayloadType)type;

+ (PBPasteboardPayloadSender *)payloadSenderWithData:(NSData *)data ofType:(PBPasteboardPayloadType)type;
+ (PBPasteboardPayloadSender *)payloadSenderWithString:(NSString *)string;

@end
