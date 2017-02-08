//
//  AppDelegate.h
//  VKTemplateForiPhone
//
//  Created by Vescky on 14-9-3.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

#import <UIKit/UIKit.h>
#import "CustomTabBarViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) UITabBarController *tabBarController;
@property (nonatomic,strong) UINavigationController *navController;
@property (assign) bool shouldIgnoreMessage,enterFromBackground;
@property (nonatomic,strong) NSString *sessionId,*companyId;
@property (nonatomic,strong) NSString *notCommentConversationId;
@property (nonatomic,strong) NSDictionary *familyAskLoginInfo;
@property (nonatomic, strong) NSMutableDictionary *messageM;

- (bool)checkIfLogin;
- (bool)checkIfVIP;
- (void)checkUncommentDoctor;
- (void)presentLoginViewIn:(UIViewController*)pVc;
- (void)loginOnBackground:(NSString*)userPhone password:(NSString*)userPassword;

- (void)handleFamilyLoginRequest:(NSDictionary*)aInfo;

- (bool)isCharMessage:(NSDictionary*)notification;
//处理推送
- (void)handleRemoteNotification:(NSDictionary*)notificationInfo;
///处理从通知栏点进来的推送
- (void)handleRemoteNotificationFromBackground:(NSDictionary*)notificationInfo;
+(AppDelegate *)sharedDelegate;
@end
