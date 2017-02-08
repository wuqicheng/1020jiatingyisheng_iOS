//
//  KeyBoard.m
//  WeiZaZhi
//
//  Created by ADUU on 15/12/10.
//  Copyright © 2015年 aduu. All rights reserved.
//

#import "KeyBoardObserver.h"
@interface KeyBoardObserver ()
@property (nonatomic, strong) KeyBoardBlock keyboardWillShowBlock;
@property (nonatomic, strong) KeyBoardBlock keyboardDidShowBlock;
@property (nonatomic, strong) KeyBoardBlock keyboardWillHideBlock;
@property (nonatomic, strong) KeyBoardBlock keyboardDidHideBlock;
@end

@implementation KeyBoardObserver
+ (id)shareInstance {
    static KeyBoardObserver *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KeyBoardObserver alloc] init];
    });
    return instance;
}

- (void)keyboardWillShow:(KeyBoardBlock)block {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNotif:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    _keyboardWillShowBlock = block;
}

- (void)keyboardDidShow:(KeyBoardBlock)block {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShowNotif:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    _keyboardDidShowBlock = block;
}

- (void)keyboardWillHide:(KeyBoardBlock)block {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotif:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    _keyboardWillHideBlock = block;
}

- (void)keyboardDidHide:(KeyBoardBlock)block {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHideNotif:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    _keyboardDidHideBlock = block;
}

#pragma  mark - KeyboardNotification
- (void)keyboardWillShowNotif:(NSNotification *)notif {
    _keyboardWillShowBlock ([[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height);
}

- (void)keyboardDidShowNotif:(NSNotification *)notif {
     _keyboardDidShowBlock ([[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height);
}

- (void)keyboardWillHideNotif:(NSNotification *)notif {
     _keyboardWillHideBlock ([[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height);
}

- (void)keyboardDidHideNotif:(NSNotification *)notif {
     _keyboardWillHideBlock ([[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height);
}

- (void)dealloc {
    [self removeObserver];
}

- (void)removeObserver {
    self.keyboardWillShowBlock = nil;
    self.keyboardWillHideBlock = nil;
    self.keyboardDidHideBlock = nil;
    self.keyboardDidShowBlock = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}
@end
