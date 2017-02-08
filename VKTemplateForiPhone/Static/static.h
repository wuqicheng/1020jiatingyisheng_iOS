//
//  static.h
//  VKTemplateForiPhone
//
//  Created by Vescky on 14-9-4.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#ifndef VKTemplateForiPhone_static_h
#define VKTemplateForiPhone_static_h

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define Screen_Height [UIScreen mainScreen].bounds.size.height
#define Screen_Width [UIScreen mainScreen].bounds.size.width

#pragma mark - rgb颜色转换（16进制->10进制）
#define _ColorFromRGB_(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define _Color_(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define __weakSelf_(__self) __weak __typeof(&*self) __self = self
#define __weak_Obj_(obj, name) __weak __typeof(&*obj) name = obj
#define _LoadView_from_nib_(nibName) ([[NSBundle mainBundle] loadNibNamed:(nibName) owner:self options:nil][0])

#pragma mark - some keys
#define MAP_KEY @"efe68d23390bf4280cdc3b9bf3e4112e"
#define UMSHARE_KEY @"553773b9e0f55ae0a9000f16"
#define SHARE_WECHAT_APPID @"wxc2490a62cd76ce55"
#define SHARE_WECHAT_SECRECT @"90d75b62c14921ac60f2fe4c6b4deb38"
#define SHARE_QQ_APPID @"1104413267"
#define SHARE_QQ_KEY @"VQ0y8j9z46mYP5U3"

//支付宝配置
#define Alipay_Partner_ID   @""
#define Alipay_Saller_ID    @""
#define Alipay_Private_Key  @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAP40fCwwCucjYvI9nCDy79L4vNvO4wQYZfRieSFxgvWJk+1jkCHz/TcdivBHq4B3p0mT2mF7rlXrbtoHATU++epEDE/YZzaMYW8Bm8MxBrFJ1lAo9aqYxEeqBBJ+etfcP2eJ9BBhJVxGlfJNV+AK/q1V0ZQfTQ3X10qWtPGRax4lAgMBAAECgYBhUrDTrhUOhzLDsajLyJbe+9I6iYvKrpiiJu1fS3krDmAvO7Yb+bDRYCMoeRgFGEpY1h1+wv5s8LVBDft9aj39mnfYdt6ojhtoIDWJkKkos3rUahvyyoalVKue+7qsniYAbrNjpXcD8MFDUPZRyKj1xxoD7VRFwbuPXY1ecDk9BQJBAP/8hZfpHTfw78ZJtS7VKcNWzawhcWdTklns+q5vbuT0yvX21oLgsCznetyfcjOE7HCLGJtwrS7oae21hAKpSzMCQQD+N/BiBzNetDNocOZ4b+/Fjnp4AnGCEauJCGolbPS/OwlAdczH3cB6T4xyGf3N5dFXjKrsnJFou8U71HGCo7FHAkAnvU4H/Tp5+r9eawbjlFf9aTZYqIBwZ/rqVu27srTmelIfyQgYHUV8UxsxsNcLxHDoL8/MIbvg8levfWRW/W0dAkEAl+/U8rG9CRAIXZaEmFzGYDuMhKdpMcTf0bG+xwl8qcJeADGnp5ioTjG3Dgbswx9k47+F9I6K9Z6r/ds10E+HRwJBANL6EX/5PI4tCwcr0SrfAe/neS+SYqMGazuRigLCBCb//0ZyI57tWVmjqvUlf0v/7iz7BJ299qJeSrHqhnh0gj8="

//微信支付配置
#define WXPay_APP_ID    SHARE_WECHAT_APPID
#define WXPay_APP_SECRET   SHARE_WECHAT_SECRECT
#define WXPay_MCH_ID    @"1242019002"
#define WXPay_API_SECRECT   @"075536678088jkshzjszdywlkjyxgsmy"


///注释这行，去掉jpush
//#define UsingJPush

#pragma mark - define some notification name
#define Notification_Location_Updated @"Notification_Location_Updated"
#define Notification_Login_Success @"Notification_Login_Success"
#define Notification_Did_Selected_Car_ModelAndSeries @"Notification_Did_Selected_Car_ModelAndSeries"
#define Notification_Order_Did_Selected_Car @"Notification_Did_Selected_Order_Car"
#define Notification_Order_Did_Selected_Address @"Notification_Order_Did_Selected_Address"
#define Notification_Order_Did_Selected_Invoice @"Notification_Order_Did_Selected_Invoice"
#define Notification_Order_Did_Selected_UseCarTime @"Notification_Order_Did_Selected_UseCarTime"
#define Notification_Order_Did_Selected_Services @"Notification_Order_Did_Selected_Services"
#define Notification_Order_Did_Pay @"Notification_Order_Did_Pay"
#define Notification_Did_Recieve_Remote_Notification @"Notification_Did_Recieve_Remote_Notification"
//新聊天消息
#define NotificationDidRecieveNewChatMessage @"NotificationDidRecieveNewChatMessage"

///健康助手专属
#define NotificationDidRecieveFamilyLoginAnswer @"NotificationDidRecieveFamilyLoginAnswer"//亲人登陆申请答复

///支付通知
#define Notification_Alipay_Result_Notification @"Notification_Alipay_Result_Notification"
#define Notification_WechatPay_Result_Notification @"Notification_WechatPay_Result_Notification"

#pragma mark - Urls
//--测试服务器 120.24.70.253
//APP的正式服务器地址:         http://mobile.health1020.com:8080
//APP的开发测试服务器地址： http://mobile.health1020.com:9090
//#define SERVER_DATA @"mobile.health1020.com:8080/doctor"//定义服务器地址  mobile.health1020.com

//#define SERVER_DATA @"mobile.1020vip.com:8080/doctor"
#define SERVER_DATA @"mobile.health1020.com:9090/doctor"  //服务器地址
#define Social_Share_Link @"https://itunes.apple.com/cn/app/id995132346"//个人中心分享链接

#pragma mark - Resources
#define Defualt_Loading_Image [UIImage imageNamed:@"default_loading.png"]
#define Defualt_Avatar_Image [UIImage imageNamed:@"default_loading2.png"]
#define PRESET_DAY_ARRAY @[@"今天",@"明天",@"后天"]

#pragma mark - some flag
#define FLAG_SERVICE_INNER @"INTER"
#define FLAG_SERVICE_OUTER @"OUTER"
#define FLAG_SERVICE_OTHER @"OTHER"


#pragma mark - Some Strings
#define String_Loading @"正在加载..."
#define String_Saving @"正在保存..."
#define String_Submitting @"正在提交..."
#define String_Saved_Success @"保存成功!"
#define String_LoggingIn @"正在登录..."
#define String_Input_Wrong_Phone @"您输入的号码不正确，请重新输入!"
#define String_Getting_SMSCode @"正在获取验证码..."
#define String_SMSCode_Send @"验证码已发送，请注意查收!"
#define String_SMSCode_Send_Failed @"获取验证码失败!"

#define String_Has_Not_Modified @"没有任何修改!"
#define String_Device_Not_Supported_Camera @"您的设备不支持拍照!"

#define String_Feedback_Empty_Content @"反馈内容不能为空!"
#define String_Feedback_Success @"反馈成功"

#define String_Sure @"确定"
#define String_Cancel @"取消"

#define String_Cannot_Locate @"暂时无法定位到您当前的位置"

#define String_Searching @"正在搜索..."

#define RichContentHeader @"<style type=\"text/css\">td {border-style: solid;}</style>"
#define OptimizeHtmlString(_htmlString) [NSString stringWithFormat:@"%@%@",RichContentHeader,_htmlString]
#endif
