/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Data model class for contact object in UnicornChat.
*/

#import "UCContact.h"
#import <Intents/Intents.h>

@implementation UCContact

- (INPerson *)inPerson {
    return [[INPerson alloc] initWithHandle:_unicornName displayName:_name contactIdentifier:_unicornName];
}

@end
