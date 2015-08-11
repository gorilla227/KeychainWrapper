//
//  KeychainWrapper.m
//  Axu_Keychain
//
//  Created by Andy on 15/8/4.
//  Copyright (c) 2015年 Andy Xu. All rights reserved.
//

#import "KeychainWrapper.h"

@implementation KeychainWrapper {
    NSData *keychainID;
    NSMutableDictionary *queryAttributes;
    NSMutableDictionary *queryData;
}
@synthesize keychainAttributes, keychainData;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        keychainID = [attributes objectForKey:(__bridge id)kSecAttrGeneric];
        keychainAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
        
        queryAttributes = [NSMutableDictionary new];
        [queryAttributes setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [queryAttributes setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
        [queryAttributes setObject:@YES forKey:(__bridge id)kSecReturnAttributes];
        [queryAttributes setObject:keychainID forKey:(__bridge id)kSecAttrGeneric];
        [queryAttributes setObject:@YES forKey:(__bridge id)kSecAttrSynchronizable];
        [queryAttributes setObject:[keychainAttributes objectForKey:(__bridge id)kSecAttrAccount] forKey:(__bridge id)kSecAttrAccount];
        [queryAttributes setObject:[keychainAttributes objectForKey:(__bridge id)kSecAttrService] forKey:(__bridge id)kSecAttrService];
        
        queryData = [NSMutableDictionary new];
        [queryData setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [queryData setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
        [queryData setObject:@YES forKey:(__bridge id)kSecReturnData];
        [queryData setObject:keychainID forKey:(__bridge id)kSecAttrGeneric];
        [queryData setObject:@YES forKey:(__bridge id)kSecAttrSynchronizable];
        [queryData setObject:[keychainAttributes objectForKey:(__bridge id)kSecAttrAccount] forKey:(__bridge id)kSecAttrAccount];
        [queryData setObject:[keychainAttributes objectForKey:(__bridge id)kSecAttrService] forKey:(__bridge id)kSecAttrService];
        
        [self retriveKeychainData];
    }
    return self;
}

- (id)initWithNewKeychain:(NSDictionary *)keychainCriteria {
    self = [super init];
    if (self) {
        keychainID = [keychainCriteria objectForKey:(__bridge id)kSecAttrGeneric];
        
        queryAttributes = [NSMutableDictionary new];
        [queryAttributes setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [queryAttributes setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
        [queryAttributes setObject:@YES forKey:(__bridge id)kSecReturnAttributes];
        [queryAttributes setObject:keychainID forKey:(__bridge id)kSecAttrGeneric];
        [queryAttributes setObject:@YES forKey:(__bridge id)kSecAttrSynchronizable];
        
        queryData = [NSMutableDictionary new];
        [queryData setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [queryData setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
        [queryData setObject:@YES forKey:(__bridge id)kSecReturnData];
        [queryData setObject:keychainID forKey:(__bridge id)kSecAttrGeneric];
        [queryData setObject:@YES forKey:(__bridge id)kSecAttrSynchronizable];
        
        NSMutableDictionary *addNewKeychain = [NSMutableDictionary dictionaryWithDictionary:keychainCriteria];
        [addNewKeychain setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [addNewKeychain setObject:@YES forKey:(__bridge id)kSecAttrSynchronizable];
        
        OSStatus queryErr = noErr;
        queryErr = SecItemAdd((__bridge CFDictionaryRef)addNewKeychain, NULL);
        if (queryErr == noErr) {
            [queryAttributes setObject:[keychainCriteria objectForKey:(__bridge id)kSecAttrAccount] forKey:(__bridge id)kSecAttrAccount];
            [queryAttributes setObject:[keychainCriteria objectForKey:(__bridge id)kSecAttrService] forKey:(__bridge id)kSecAttrService];
            [queryData setObject:[keychainCriteria objectForKey:(__bridge id)kSecAttrAccount] forKey:(__bridge id)kSecAttrAccount];
            [queryData setObject:[keychainCriteria objectForKey:(__bridge id)kSecAttrService] forKey:(__bridge id)kSecAttrService];
            [self retriveKeychainAttritubes];
            [self retriveKeychainData];
            return self;
        }
        else {
            NSLog(@"Add failed: %d", (int)queryErr);
            return nil;
        }
    }
    return self;
}

+ (NSArray *)retriveKeychainsByAttributes:(NSString *)identifier {
    NSMutableDictionary *allAttr = [NSMutableDictionary new];
    [allAttr setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [allAttr setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
    [allAttr setObject:[identifier dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrGeneric];
    [allAttr setObject:@YES forKey:(__bridge id)kSecReturnAttributes];
    [allAttr setObject:@YES forKey:(__bridge id)kSecAttrSynchronizable];
    
    OSStatus queryErr= noErr;
    CFArrayRef attributes = nil;
    queryErr = SecItemCopyMatching((__bridge CFDictionaryRef)allAttr, (CFTypeRef *)&attributes);
    if (queryErr == noErr) {
        NSArray *result = [NSArray arrayWithArray:(__bridge NSArray *)attributes];
        NSLog(@"%@", result);
        return result;
    }
    else {
        NSLog(@"Retrive failed: %d", (int)queryErr);
        return nil;
    }
}

- (BOOL)retriveKeychainAttritubes {
    OSStatus queryErr = noErr;
    CFDictionaryRef attributes = nil;
    
    queryErr = SecItemCopyMatching((__bridge CFDictionaryRef)queryAttributes, (CFTypeRef *)&attributes);
    if (queryErr == noErr) {
        keychainAttributes = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)attributes];
        [queryData setObject:[keychainAttributes objectForKey:(__bridge id)kSecAttrAccount] forKey:(__bridge id)kSecAttrAccount];
        [queryData setObject:[keychainAttributes objectForKey:(__bridge id)kSecAttrService] forKey:(__bridge id)kSecAttrService];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)retriveKeychainData {
    OSStatus queryErr= noErr;
    CFDataRef data = nil;
    
    queryErr = SecItemCopyMatching((__bridge CFDictionaryRef)queryData, (CFTypeRef *)&data);
    if (queryErr == noErr) {
        keychainData = [NSData dataWithData:(__bridge_transfer NSData *)data];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)deleteKeychain {
    NSMutableDictionary *deleteKeychain = [NSMutableDictionary new];
    [deleteKeychain setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [deleteKeychain setObject:keychainID forKey:(__bridge id)kSecAttrGeneric];
    [deleteKeychain setObject:@YES forKey:(__bridge id)kSecAttrSynchronizable];
    [deleteKeychain setObject:[keychainAttributes objectForKey:(__bridge id)kSecAttrAccount] forKey:(__bridge id)kSecAttrAccount];
    [deleteKeychain setObject:[keychainAttributes objectForKey:(__bridge id)kSecAttrService] forKey:(__bridge id)kSecAttrService];
    
    OSStatus queryErr = noErr;
    queryErr = SecItemDelete((__bridge CFDictionaryRef)deleteKeychain);
    if (queryErr == noErr) {
        return YES;
    }
    else {
        NSLog(@"Delete failed: %d", (int)queryErr);
        return NO;
    }
}

- (BOOL)changeKeychain:(NSDictionary *)keychainCriteria {
    NSMutableDictionary *updateQuery = [NSMutableDictionary dictionaryWithDictionary:keychainAttributes];
    [updateQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    OSStatus queryErr = noErr;
    queryErr = SecItemUpdate((__bridge CFDictionaryRef)updateQuery, (__bridge CFDictionaryRef)keychainCriteria);
    if (queryErr == noErr) {
        NSLog(@"%@", queryAttributes);
        if ([keychainCriteria.allKeys containsObject:(__bridge id)kSecAttrAccount]) {
            [queryAttributes setObject:[keychainCriteria objectForKey:(__bridge id)kSecAttrAccount] forKey:(__bridge id)kSecAttrAccount];
        }
        if ([keychainCriteria.allKeys containsObject:(__bridge id)kSecAttrService]) {
            [queryAttributes setObject:[keychainCriteria objectForKey:(__bridge id)kSecAttrService] forKey:(__bridge id)kSecAttrService];
        }
        NSLog(@"%@", queryAttributes);
        [self retriveKeychainAttritubes];
        [self retriveKeychainData];
        return YES;
    }
    else {
        NSLog(@"Change failed: %d", (int)queryErr);
        return NO;
    }
}

+ (BOOL)clearKeychains:(NSString *)identifier {
    NSMutableDictionary *clearKeychainDictionary = [NSMutableDictionary new];
    [clearKeychainDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [clearKeychainDictionary setObject:[identifier dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrGeneric];
    [clearKeychainDictionary setObject:@YES forKey:(__bridge id)kSecAttrSynchronizable];
    
    OSStatus queryErr = noErr;
    queryErr = SecItemDelete((__bridge CFDictionaryRef)clearKeychainDictionary);
    if (queryErr == noErr) {
        return YES;
    }
    else {
        NSLog(@"Clear failed: %d", (int)queryErr);
        return NO;
    }
}
@end
