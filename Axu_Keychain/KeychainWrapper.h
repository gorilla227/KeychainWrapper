//
//  KeychainWrapper.h
//  Axu_Keychain
//
//  Created by Andy on 15/8/4.
//  Copyright (c) 2015年 Andy Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainWrapper : NSObject
@property (nonatomic, strong) NSMutableDictionary *keychainAttributes;//Save the attributes of keychainItem
@property (nonatomic, strong) NSData *keychainData;//Save the data of keychainItem

- (id)initWithAttributes:(NSDictionary *)attributes;//Retrieve existed keychainItem
- (id)initWithNewKeychain:(NSDictionary *)keychainCriteria;//Create new keychainItem

- (BOOL)retriveKeychainAttritubes;//Retrieve existed keychainItem's attributes
- (BOOL)retriveKeychainData;//Retrieve existed keychainItem's data
- (BOOL)deleteKeychain;//Delete existed keychainItem
- (BOOL)changeKeychain:(NSDictionary *)keychainCriteria;//Change keychainItem attributes or data

+ (NSArray *)retriveKeychainsByAttributes:(NSString *)identifier;//Retrive all keychainItems' attirbutes of specified identifier
+ (BOOL)clearKeychains:(NSString *)identifier;//Delete all keychainItems of specified identifier
@end
