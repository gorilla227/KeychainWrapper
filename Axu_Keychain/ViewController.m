//
//  ViewController.m
//  Axu_Keychain
//
//  Created by Andy Xu on 15/7/30.
//  Copyright (c) 2015年 Andy Xu. All rights reserved.
//

#import "ViewController.h"
#import "KeychainWrapper.h"

@interface ViewController ()
@property IBOutlet UITextView *displayView;
@property IBOutlet UIToolbar *toolBar;
@property IBOutlet UITextField *tf_Account;
@property IBOutlet UITextField *tf_Services;
@property IBOutlet UITextField *tf_Identifier;
@property IBOutlet UITextField *tf_Data;
@property IBOutlet UIPickerView *pv_KeychainItems;
@end

@implementation ViewController {
    NSMutableArray *keychainItems;
}
@synthesize displayView, toolBar, tf_Account, tf_Data, tf_Identifier, tf_Services, pv_KeychainItems;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setToolbarItems:toolBar.items];
    keychainItems = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return keychainItems.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSNumber numberWithInteger:row].stringValue;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    KeychainWrapper *selectedKeychainItem = [keychainItems objectAtIndex:row];
    [displayView setText:[NSString stringWithFormat:@"%@\n%@", selectedKeychainItem.keychainAttributes, [NSString stringWithUTF8String:selectedKeychainItem.keychainData.bytes]]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)btn_Add_OnClicked:(id)sender {
    if (tf_Identifier.text && tf_Account.text && tf_Services.text && tf_Data.text) {
        NSMutableDictionary *newKeychainItemData = [NSMutableDictionary new];
        [newKeychainItemData setObject:[tf_Identifier.text dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrGeneric];
        [newKeychainItemData setObject:tf_Account.text forKey:(__bridge id)kSecAttrAccount];
        [newKeychainItemData setObject:tf_Services.text forKey:(__bridge id)kSecAttrService];
        [newKeychainItemData setObject:[tf_Data.text dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        KeychainWrapper *newKeychainItem = [[KeychainWrapper alloc] initWithNewKeychain:newKeychainItemData];
        if (newKeychainItem) {
            [keychainItems addObject:newKeychainItem];
            
            [pv_KeychainItems reloadAllComponents];
            [pv_KeychainItems selectRow:keychainItems.count - 1 inComponent:0 animated:YES];
            [displayView setText:[NSString stringWithFormat:@"%@\n%@", newKeychainItem.keychainAttributes, [NSString stringWithUTF8String:newKeychainItem.keychainData.bytes]]];
        }
    }
}

- (IBAction)btn_Edit_OnClicked:(id)sender {
    KeychainWrapper *keychain = [keychainItems objectAtIndex:[pv_KeychainItems selectedRowInComponent:0]];
    NSDictionary *updateData = @{(__bridge id)kSecAttrAccount : tf_Account.text,
                                 (__bridge id)kSecAttrService : tf_Services.text, 
                                 (__bridge id)kSecValueData : [tf_Data.text dataUsingEncoding:NSUTF8StringEncoding]};
    if ([keychain changeKeychain:updateData]) {
        [displayView setText:[NSString stringWithFormat:@"%@\n%@", keychain.keychainAttributes, [NSString stringWithUTF8String:keychain.keychainData.bytes]]];
    }
}

- (IBAction)btn_Delete_OnClicked:(id)sender {    if (keychainItems.count) {
        KeychainWrapper *deleteKeychain = [keychainItems objectAtIndex:[pv_KeychainItems selectedRowInComponent:0]];
        if ([deleteKeychain deleteKeychain]) {
            [keychainItems removeObject:deleteKeychain];
            
            [pv_KeychainItems reloadAllComponents];
            [displayView setText:nil];
        }
    }
}

- (IBAction)btn_View_OnClicked:(id)sender {    NSArray *attributesOfKeychains = [KeychainWrapper retriveKeychainsByAttributes:tf_Identifier.text];
    keychainItems = [NSMutableArray new];
    for (NSDictionary *attributes in attributesOfKeychains) {
        KeychainWrapper *keychain = [[KeychainWrapper alloc] initWithAttributes:attributes];
        if (keychain) {
            [keychainItems addObject:keychain];
        }
    }

    [pv_KeychainItems reloadAllComponents];
    [pv_KeychainItems selectRow:0 inComponent:0 animated:YES];
    KeychainWrapper *firstKeychain = keychainItems.firstObject;
    if (firstKeychain) {
        [displayView setText:[NSString stringWithFormat:@"%@\n%@", firstKeychain.keychainAttributes, [NSString stringWithUTF8String:firstKeychain.keychainData.bytes]]];
    }
    else {
        [displayView setText:nil];
    }
}

- (IBAction)btn_Clear_OnClicked:(id)sender {
    if (tf_Identifier.text) {
        if ([KeychainWrapper clearKeychains:tf_Identifier.text]) {
            [keychainItems removeAllObjects];
            
            [pv_KeychainItems reloadAllComponents];
            [displayView setText:nil];
        }
    }
}

@end
