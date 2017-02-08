//
//  AppDelegate.m
//  VKTemplateForiPhone
//
//  Created by Vescky on 14-9-3.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "AppDelegate.h"
#import "AppsLocationManager.h"
#import "UserSessionCenter.h"
#import "CacheManager.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"

#import "static.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"


#define UsingJPush

#import "JPUSHService.h"
#import <AdSupport/AdSupport.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
// 这里是iOS10需要用到的框架
#import <UserNotifications/UserNotifications.h>

static NSString *JPushAppKey  = @"1864cf7d3099f6cb04b618f1";
static NSString *JPushChannel = @"Publish channel";
// static BOOL JPushIsProduction = NO;
#ifdef DEBUG
// 开发 极光FALSE为开发环境
static BOOL const JPushIsProduction = FALSE;
#else
// 生产 极光TRUE为生产环境
static BOOL const JPushIsProduction = TRUE;
#endif
#endif

//ViewControllers
#import "HomePageViewController.h"
#import "MicroMallViewController.h"
#import "HeathyProjectViewController.h"
#import "UserCenterViewController.h"
#import "LoginPageViewController.h"
#import "EvaluateDoctorViewController.h"
#import "SplashViewController.h"
#import "NotificationsListViewController.h"

#import "SingleChatViewController.h"


#import "HomePageViewController.h"

//IM
#import "MessageManager.h"
#import "UMSocialSinaSSOHandler.h"
#import "MyAlertView.h"
#define AppKey @"553773b9e0f55ae0a9000f16"

@interface AppDelegate()<MessageManagerDelegate,WXApiDelegate,UITabBarControllerDelegate,MyAlertViewDelegate,JPUSHRegisterDelegate> {
    MessageManager *imManager;
    SplashViewController *splashVc;
    MyAlertView *myAlertView;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    [UMSocialData setAppKey:AppKey];
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:SHARE_WECHAT_APPID appSecret:SHARE_WECHAT_SECRECT url:Social_Share_Link];
    //设置手机QQ 的AppId，Appkey，和分享URL，需要#import "UMSocialQQHandler.h"
    [UMSocialQQHandler setQQWithAppId:SHARE_QQ_APPID appKey:SHARE_WECHAT_SECRECT url:Social_Share_Link];
    //打开新浪微博的SSO开关，设置新浪微博回调地址，这里必须要和你在新浪微博后台设置的回调地址一致。需要 #import "UMSocialSinaSSOHandler.h"
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"696405511" secret:@"38f06c3052098d65aeaa4efa343d7eb7" RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
//    [TestinAgent init:@"7616a4702d3a22a742779d0421ea89d0"];
//    [TestinAgent setUserInfo:@"user"];
    
    if (isValidDictionary(launchOptions)) {
        [[CacheManager defaultManager] setNeedToJumpToNotificationList:launchOptions];
    }
    
    ///清除临时登陆
    [[UserSessionCenter shareSession] setIfIsTmpLogin:NO];
    [[UserSessionCenter shareSession] destroyTmpAccountDetailInfo];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [self initApp];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
//    self.companyId = @"1";
    
#ifdef UsingJPush
    //JPush Required
    // 启动极光推送
    // Required
    // - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions { }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) // iOS10
    {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = (UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound);
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
#endif
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        // categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    else
    {
        // categories nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    // Required
    // [JPUSHService setupWithOption:launchOptions]
    // pushConfig.plist appKey
    // 有广告符标识IDFA（尽量不用，避免上架审核被拒）
    /*
     NSString *JPushAdvertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
     [JPUSHService setupWithOption:JPushOptions
     appKey:JPushAppKey
     channel:JPushChannel
     apsForProduction:JPushIsProduction
     advertisingIdentifier:JPushAdvertisingId];
     */
    // 或无广告符标识IDFA（尽量不用，避免上架审核被拒）
    [JPUSHService setupWithOption:launchOptions
                           appKey:JPushAppKey
                          channel:JPushChannel
                 apsForProduction:JPushIsProduction];
    
    
    // 2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0)
        {
            // iOS10获取registrationID放到这里了, 可以存到缓存里, 用来标识用户单独发送推送
            NSLog(@"registrationID获取成功：%@",registrationID);
            [[NSUserDefaults standardUserDefaults] setObject:registrationID forKey:@"registrationID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
#endif
    
    //初始化IM
    imManager = [MessageManager defaultManager];
    imManager.delegate = self;
    
    //向微信注册
    [WXApi registerApp:WXPay_APP_ID withDescription:@"jiankangzhushou"];
    
    return YES;
}




- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    
    //暂停IM机制，此时靠推送接收消息
    [imManager haveA_Break];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    self.enterFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    self.enterFromBackground = NO;
    
    //清除计数
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    //启动IM机制
    [imManager startUpByUserId:[[UserSessionCenter shareSession] getUserId]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
     BOOL result = [UMSocialSnsService handleOpenURL:url];
    
    //支付宝返回结果
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
             NSLog(@"result = %@", resultDic);
             [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Alipay_Result_Notification object:[self resultFromAlipayURL:url]];
         }];
    }
    
    //微信支付
    if ([sourceApplication isEqualToString:@"com.tencent.xin"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}

#pragma mark - init
- (void)initApp {
    //init Amap Key
    //    [MAMapServices sharedServices].apiKey = MAP_KEY;
    //init update user location
    [[AppsLocationManager sharedManager] startUpdate];
    
    [self initTabBarController];
    
    if (![[UserSessionCenter shareSession] isAutoLoginDisable]) {
        //自动登陆
        [self loginOnBackground:nil password:nil];
    }
    else {
        [[UserSessionCenter shareSession] removeUserId];
    }
    
    [self performSelector:@selector(checkIfNeedToShowSplashView) withObject:nil afterDelay:0.1];
    [self checkUncommentDoctor];
}

- (void)initTabBarController {
    //init tabbarcontroller
    HomePageViewController *vc1 = [[HomePageViewController alloc] init];
    MicroMallViewController *vc2 = [[MicroMallViewController alloc] init];
    HeathyProjectViewController *vc3 = [[HeathyProjectViewController alloc] init];
    UserCenterViewController *vc4 = [[UserCenterViewController alloc] init];
    
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    self.navController = nav1;
    
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:vc3];
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:vc4];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[nav1,nav2,nav3,nav4];
    self.tabBarController.delegate = self;
    //    self.tabBarController.viewControllers = @[vc1,vc2,vc3,vc4];
    //    self.tabBarController.hidesBottomBarWhenPushed = YES;
    
    //    self.navController = [[UINavigationController alloc] initWithRootViewController:self.tabBarController];
    
//    self.window.rootViewController = self.tabBarController;
    
    
    HomePageViewController *hVC = [[HomePageViewController alloc]init];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:hVC];
    self.window.rootViewController = [HomePageViewController new];
    self.window.rootViewController = navi;
    
    UITabBarItem *tabBarItem1 = [self.tabBarController.tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [self.tabBarController.tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [self.tabBarController.tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [self.tabBarController.tabBar.items objectAtIndex:3];
    
    tabBarItem1.title = @"首页";
    tabBarItem2.title = @"微信商城";
    tabBarItem3.title = @"健康计划";
    tabBarItem4.title = @"个人中心";
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
        [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_item1_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_item1_off.png"]];
        [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_item2_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_item2_off.png"]];
        [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_item3_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_item3_off.png"]];
        [tabBarItem4 setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_item4_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_item4_off.png"]];
    } else {
        tabBarItem1.selectedImage = [[UIImage imageNamed:@"tabbar_item1_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        tabBarItem1.image = [[UIImage imageNamed:@"tabbar_item1_off.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        
        tabBarItem2.selectedImage = [[UIImage imageNamed:@"tabbar_item2_on.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        tabBarItem2.image = [[UIImage imageNamed:@"tabbar_item2_off.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        
        tabBarItem3.selectedImage = [[UIImage imageNamed:@"tabbar_item3_on.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        tabBarItem3.image = [[UIImage imageNamed:@"tabbar_item3_off.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        
        tabBarItem4.selectedImage = [[UIImage imageNamed:@"tabbar_item4_on.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        tabBarItem4.image = [[UIImage imageNamed:@"tabbar_item4_off.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    }
    //    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:GetColorWithRGB(0, 230, 22), NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
}

//检查是否需要显示splash view
//- (void)checkIfNeedToShowSplashView {
//    NSUserDefaults *usd = [NSUserDefaults standardUserDefaults];
//    if ([usd objectForKey:@"SplashViewShown"]) {
//        [usd setObject:@1 forKey:@"SplashViewShown"];
//        [usd synchronize];
//        SplashViewController *splashVc = [[SplashViewController alloc] init];
//        [self.window addSubview:splashVc.view];
//    }
//}

#pragma mark - Private

//检查是否需要显示splash view
- (void)checkIfNeedToShowSplashView {
    NSUserDefaults *usd = [NSUserDefaults standardUserDefaults];
    if (![usd objectForKey:@"SplashViewShown1"]) {
        [usd setObject:@1 forKey:@"SplashViewShown1"];
        [usd synchronize];
        splashVc = [[SplashViewController alloc] init];
        [KEY_WINDOW addSubview:splashVc.view];
    }
}



- (void)showAlertWithTitle:(NSString*)t message:(NSString*)msg cancelString:(NSString*)cString sureString:(NSString*)sString  tag:(NSInteger)g {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:t message:msg delegate:self cancelButtonTitle:sString otherButtonTitles:cString, nil];
//    alert.tag = g;
//    [alert show];
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    if (isValidString(cString)) {
        [buttons addObject:cString];
    }
    if (isValidString(sString)) {
        [buttons addObject:sString];
    }
    
    myAlertView = [[MyAlertView alloc] initWithTitle:t alertContent:msg defaultStyleWithButtons:buttons];
    myAlertView.delegate = self;
    myAlertView.tag = g;
    [myAlertView show];
}

#ifdef UsingJPush
#pragma mark - 推送相关
//注册
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [JPUSHService registerDeviceToken:deviceToken];
    NSLog(@"注册成功");
}

//注册失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificwationsWithError:(NSError *)error
{
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

//接收
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
   
    [self handleRemoteNotification:userInfo];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    NSLog(@"========%@=======",userInfo);
    self.messageM = [[NSMutableDictionary alloc]init];
//    [self.messageM dictionaryWithDictionary:userInfo];
    [self.messageM addEntriesFromDictionary:userInfo];
     NSLog(@"========%@====11===",self.messageM);
    NotificationsListViewController *vc = [NotificationsListViewController new];
    vc.messagelist = [userInfo objectForKey:@"aps"];
    NSLog(@"%@123324444rwefewfeferg",vc.messagelist);
    
    //JPush Required
    [JPUSHService handleRemoteNotification:userInfo];

}

//处理通知

/** iOS10以下版本时 **/
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"2-1 didReceiveRemoteNotification remoteNotification = %@", userInfo);
    
    // apn 内容获取：
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
    NSLog(@"2-2 didReceiveRemoteNotification remoteNotification = %@", userInfo);
    if ([userInfo isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = userInfo[@"aps"];
        NSString *content = dict[@"alert"];
        NSLog(@"content = %@", content);
    }
    
    if (application.applicationState == UIApplicationStateActive)
    {
        // 程序当前正处于前台
    }
    else if (application.applicationState == UIApplicationStateInactive)
    {
        // 程序处于后台
    }
}
/** iOS10及以上版本时 **/
#pragma mark - iOS10: 收到推送消息调用(iOS10是通过Delegate实现的回调)
#pragma mark- JPUSHRegisterDelegate

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
//        [rootViewController addNotificationCount];
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif

////此方法在ios7以上的机，会覆盖上面的方法
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    [self handleRemoteNotification:userInfo];
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
//    NSLog(@"========%@=======",userInfo);
//    self.messageM = [[NSMutableDictionary alloc]init];
//     [self.messageM addEntriesFromDictionary:userInfo];
//    
//    
//    NotificationsListViewController *vc = [NotificationsListViewController new];
//    vc.messagelist = [userInfo objectForKey:@"aps"];
//    NSLog(@"%@123324444rwefewfeferg",vc.messagelist);
//     NSLog(@"========%@==11=====",self.messageM);
//    
//    //JPush IOS 7 Support Required
//    [APService handleRemoteNotification:userInfo];
//    completionHandler(UIBackgroundFetchResultNewData);
//     }

- (void)setTagsAndAliasCallback {
    NSLog(@"set tag/alias success!");
}

#endif

- (bool)isCharMessage:(NSDictionary*)notification {
    if ([[notification objectForKey:@"msg_src_type"] integerValue] == 1) {
        return YES;
    }
    return NO;
}

///处理从通知栏点进来的推送
- (void)handleRemoteNotificationFromBackground:(NSDictionary*)pushInfo {
    NSLog(@"push_info_from_background:%@",pushInfo);
    UIViewController *vc = [self.navController.viewControllers lastObject];
    if ([self isCharMessage:pushInfo]) {
        bool needToJump = YES;
        if ([vc isKindOfClass:NSClassFromString(@"SingleChatViewController")]) {
            SingleChatViewController *currentVc = (SingleChatViewController*)vc;
            if ([currentVc.conversationId isEqualToString:[pushInfo objectForKey:@"conversation_id"]]) {
                needToJump = NO;
            }
        }
        //不是同一个会话，就跳转
        if (needToJump) {
            SingleChatViewController *sVc = [[SingleChatViewController alloc] init];
            sVc.conversationId = [pushInfo objectForKey:@"conversation_id"];
            [self.navController pushViewController:sVc animated:YES];
        }
    }
    else if (![vc isKindOfClass:NSClassFromString(@"NotificationsListViewController")]) {
        NotificationsListViewController *nVc = [[NotificationsListViewController alloc] init];
        [self.navController pushViewController:nVc animated:YES];
    }
}

///custom methor
- (void)handleRemoteNotification:(NSDictionary*)pushInfo {
    
    //从通知栏点击进入
    if (self.enterFromBackground) {
        [self handleRemoteNotificationFromBackground:pushInfo];
        return;
    }
    
    ///App前台运行中收到推送
    //判断消息类型，处理消息
    switch ([[pushInfo objectForKey:@"msg_src_type"] integerValue]) {
        case 1://聊天
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationDidRecieveNewChatMessage object:pushInfo];
            NSLog(@"recieve chat message");
            [imManager saveNewChatMessage:pushInfo];
            break;
//        case 2://申请监护人
//            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Did_Recieve_Remote_Notification object:pushInfo];
//            [[MessageManager defaultManager] saveNewChatMessage:pushInfo];
//            break;
//        case 3://系统回复
//            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationDidRecieveNewChatMessage object:pushInfo];
//            [[MessageManager defaultManager] saveNewChatMessage:pushInfo];
//            break;
        case 5://亲人申请登录
            [self handleFamilyLoginRequest:pushInfo];
            break;
        case 6://登录申请答复
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationDidRecieveFamilyLoginAnswer object:pushInfo];
            break;
        default://其他，2-申请监护人；3-系统回复
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Did_Recieve_Remote_Notification object:pushInfo];
            [[CacheManager defaultManager] savePushMessageInfo:pushInfo];
            break;
    }
}

///回复亲人登录请求
- (void)handleFamilyLoginRequest:(NSDictionary*)aInfo {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[aInfo objectForKey:@"message_id"],@"message_id", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getFamilyApplyLoginItemByUser.action" param:params onCompletion:^(id jsonResponse) {
        NSArray *arr = [jsonResponse objectForKey:@"rows"];
        if (isValidArray(arr)) {
            self.familyAskLoginInfo = [arr firstObject];
            [self showAlertWithTitle:@"提示" message:[self.familyAskLoginInfo objectForKey:@"msg_content"]  cancelString:@"同意" sureString:@"拒绝"  tag:7776];
        }
    } onError:^(NSError *error) {
        
    } defaultErrorAlert:NO isCacheNeeded:nil method:nil];
}

//    NSDictionary * userInfo = [notification userInfo];
//    NSString *content = [userInfo valueForKey:@"content"];
//    NSDictionary *extras = [userInfo valueForKey:@"extras"];
//    NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //自定义参数，key是自己定义的
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    [self messageMenagerDidRecieveNewMessages:nil];
}

#pragma mark - MessageManager Delegate
- (void)messageMenagerDidRecieveNewMessages:(NSArray*)messages {
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationDidRecieveNewChatMessage object:messages];
}

#pragma mark - Globle Methors
- (bool)checkIfVIP {
    return [[UserSessionCenter shareSession] isVip];
}

//查询是否有未评价的医生
- (void)checkUncommentDoctor {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getNotEvalCommentSessionByUser.action" param:params onCompletion:^(id jsonResponse) {
        if ([[jsonResponse objectForKey:@"conversation_id"] integerValue] > 0) {
            self.notCommentConversationId = [jsonResponse objectForKey:@"conversation_id"];
            [self showAlertWithTitle:@"提示" message:[jsonResponse objectForKey:@"tip"] cancelString:@"我知道了" sureString:nil tag:7777];
        }
    } onError:^(NSError *error) {
        
    } defaultErrorAlert:NO isCacheNeeded:NO method:nil];
}

//登录相关
- (bool)checkIfLogin {
    return isValidString([[UserSessionCenter shareSession] getUserId]);
}

- (void)presentLoginViewIn:(UIViewController*)pVc {
    LoginPageViewController *lgVc = [[LoginPageViewController alloc] init];
    UINavigationController *loginNav =[[UINavigationController alloc] initWithRootViewController:lgVc];
    [pVc presentViewController:loginNav animated:YES completion:^{
        NSLog(@"present login vc");
    }];
}

- (void)loginOnBackground:(NSString*)userPhone password:(NSString*)userPassword {

    if (!isValidString(userPhone)) {
        userPhone = [[UserSessionCenter shareSession] getUserPhoneNumber];
    }
    if (!isValidString(userPassword)) {
        userPassword = [[UserSessionCenter shareSession] getUserPassword];
    }

    if (!isValidString(userPassword) || !isValidString(userPhone)) {
        //没有相应信息
        NSLog(@"当前身份：游客");
        //注册游客的JPush标签
//        [APService setTags:[NSSet setWithObject:@"guest"] alias:nil callbackSelector:@selector(setTagsAndAliasCallback) object:nil];
        return;
    }

    NSString *latStr = [NSString stringWithFormat:@"%lf",[[[AppsLocationManager sharedManager] currentLocation] coordinate].latitude];
    NSString *lonStr = [NSString stringWithFormat:@"%lf",[[[AppsLocationManager sharedManager] currentLocation] coordinate].longitude];

    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userPhone,@"user_login_name",userPassword,@"user_login_pwd",@2,@"plat_type",lonStr,@"earth_x",latStr,@"earth_y",@"0",@"earth_y", nil];

    [[AppsNetWorkEngine shareEngine] submitRequest:@"appCLoginToSystem.action" param:params onCompletion:^(id jsonResponse) {
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            //登陆成功
            [[UserSessionCenter shareSession] saveAccountDetailInfo:[jsonResponse objectForKey:@"resultInfos"]];//保存用户信息
            self.sessionId = [jsonResponse objectForKey:@"sessionid"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Login_Success object:nil];
            
            //注册用户的JPush别名
            [JPUSHService setTags:nil alias:[[[UserSessionCenter shareSession] getAccountDetailInfo] objectForKey:@"user_code"] callbackSelector:@selector(setTagsAndAliasCallback) object:nil];
        }
    } onError:^(NSError *error) {

    } defaultErrorAlert:NO isCacheNeeded:0 method:nil];
}

- (void)showRecievedMessageAlert:(NSDictionary*)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Did_Recieve_Remote_Notification object:nil];
    if (!self.shouldIgnoreMessage) {
        NSDictionary *apsDic = [userInfo objectForKey:@"aps"];
        
        [self showAlertWithTitle:@"收到一条通知" message:[apsDic objectForKey:@"alert"] cancelString:@"忽略" sureString:@"马上查看" tag:9999];
    }
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController  {
    UINavigationController *nav = (UINavigationController*)viewController;
    if ([[nav.viewControllers firstObject] isKindOfClass:NSClassFromString(@"HeathyProjectViewController")]) {
        if (![self checkIfLogin]) {
            //未登录
            [self presentLoginViewIn:self.tabBarController];
            return NO;
        }
//        else if(![self checkIfVIP]) {
//            [self showAlertWithTitle:@"提示" message:@"注册成为VIP会员，享受更多服务哦！"  cancelString:nil sureString:String_Sure tag:0];
//            return NO;
//        }
    }
    else if ([[nav.viewControllers firstObject] isKindOfClass:NSClassFromString(@"UserCenterViewController")]) {
        if (![self checkIfLogin]) {
            //未登录
            [self presentLoginViewIn:self.tabBarController];
            return NO;
        }
    }
    
    self.navController = nav;
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    ///未评价的医生
    if (alertView.tag == 7777) {
        EvaluateDoctorViewController *eVc = [[EvaluateDoctorViewController alloc] init];
        eVc.conversationId = self.notCommentConversationId;
        [self.navController pushViewController:eVc animated:YES];
    }
    ///回复亲人登录申请
    if (alertView.tag == 7776) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[self.familyAskLoginInfo objectForKey:@"message_id"],@"message_id",@(buttonIndex?2:1),@"result", nil];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"replyFamilyApplyLoginRequest.action" param:params onCompletion:^(id jsonResponse) {
            NSLog(@"%@",jsonResponse);
        } onError:^(NSError *error) {
            NSLog(@"%@",error);
        } defaultErrorAlert:NO isCacheNeeded:NO method:nil];
    }
}

#pragma mark - 解析支付宝返回结果
- (NSString *)resultFromAlipayURL:(NSURL *)url {
    if (url != nil && [[url host] compare:@"safepay"] == 0) {
        NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return query;
    }
    return nil;
}

#pragma mark - 微信支付回调
-(void) onResp:(BaseResp*)resp
{
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    NSString *strTitle;
    
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
//        strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
//        [SVProgressHUD showSuccessWithStatus:@"分享成功"];
    }
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_WechatPay_Result_Notification object:resp];
        
        strTitle = [NSString stringWithFormat:@"支付结果"];
        switch (resp.errCode) {
            case WXSuccess:
                strMsg = @"支付成功！";
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                break;
                
            default:
                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                NSLog(@"支付错误，请联系我们的工作人员!\nretcode = %d, retstr = %@", resp.errCode,resp.errStr);
                [self showAlertWithTitle:strTitle message:@"支付失败!" cancelString:@"好的"  sureString:nil tag:0];
                break;
        }
    }
}
+(AppDelegate *)sharedDelegate{
    return [UIApplication sharedApplication].delegate;
}

@end
