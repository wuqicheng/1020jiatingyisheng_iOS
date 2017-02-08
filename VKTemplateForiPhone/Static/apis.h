//
//  apis.h
//  NanShaZhiChuang
//
//  Created by vescky.luo on 14-9-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#ifndef NanShaZhiChuang_apis_h
#define NanShaZhiChuang_apis_h


//服务器ip
#define IP @"http://124.173.70.97:8089/nsproject/"

//#define IP @"http://192.168.10.222:8082/nsproject/"

//请求图片
#define IP_Image @"http://124.173.70.97:8089/nsproject"

//#define Base_URL @"http://192.168.10.222:8082/nsproject/"

//用户注册
#define Register_URL @"system/admin!addUser.action?"

//用户登录
#define Login_URL @"system/admin!userLogin.action"

//首页图片接口
#define HomeImage_URL @"news/newsimg!getNewsImgs.action"

//新闻类表
#define News_URL @"news/news!getAllNews.action"

//新闻详情
#define NewsDetails_URL @"news/news!getNewsInfo.action?"

//获取所有的赛区列表
#define GameArea_URL @"qgmatch/match_area!getAllMatchArea.action"

//获取所有的赛事类表
#define Game_URL @"qgmatch/matchs!getAllMatchs.action"

//获取参赛歌手列表
#define Singer_URL @"qgmatch/superstar!getSuperstars.action"

//选手详情
#define SingerDetails_URL @"qgmatch/superstar!getSuperStar.action"

//评论详情
#define CommentDetails_URL @"qgmatch/review!getPingLun.action"

//投票
#define Vote_URL @"qgmatch/praise!toupiao.action?"

//点赞
#define Attention_URL @"qgmatch/praise!fav.action?"

//投诉建议
#define Idea_URL @"system/proposals!tousu.action"

//获取最新版本
#define  Version_URL @"system/aiversion!getNewVerion.action"

//修改昵称
#define ChangeNick_URL @"system/admin!changeName.action"

//修改生日
#define ChangeBirthday_URL @"system/admin!changeBirth.action"

//修改密码
#define ChangePassword_URL @"system/admin!changePassword.action"

//修改头像
#define ChangeHead_URL @"system/admin!changeImg.action"

//评论
#define Comment_URL @"qgmatch/review!addReview.action"



#endif
