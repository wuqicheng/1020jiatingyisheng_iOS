//
//  ShareManager.m
//  GolfFriend
//
//  Created by Vescky on 14-5-18.
//  Copyright (c) 2014年 vescky.org. All rights reserved.
//

//    UMSResponseCodeBaned              = 505,        //用户被封禁
//    UMSResponseCodeFaild              = 510,        //发送失败（由于内容不符合要求或者其他原因）
//    UMSResponseCodeEmptyContent       = 5007,       //发送内容为空
//    UMSResponseCodeShareRepeated      = 5016,       //分享内容重复
//    UMSResponseCodeGetNoUidFromOauth  = 5020,       //授权之后没有得到用户uid
//    UMSResponseCodeAccessTokenExpired = 5027,       //token过期
//    UMSResponseCodeNetworkError       = 5050,       //网络错误
//    UMSResponseCodeGetProfileFailed   = 5051,       //获取账户失败
//    UMSResponseCodeCancel             = 5052,        //用户取消授权
//    UMSResponseCodeNoApiAuthority

#import "ShareManager.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"

#import "ShareMenuItemCollectionViewCell.h"

#define SnsConfig [NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQzone,nil]

#define Share_Words @"系统化、绿色优先、高性价比，最懂你的人是1020家庭医生。"
#define Share_Image [UIImage imageNamed:@"icon.png"]

@implementation ShareManager

+ (id)shareManeger {
    static ShareManager *shareManagerInstance = nil;
    static dispatch_once_t shareManagerPredicate;
    dispatch_once(&shareManagerPredicate, ^{
        shareManagerInstance = [[self alloc] init];
        [UMSocialData setAppKey:UMSHARE_KEY];
    });
    return shareManagerInstance;
}

- (void)presentShareViewIn:(UIViewController*)mainVc withContent:(NSString*)sContent image:(UIImage*)sImage shareUrl:(NSString*)shareUrl {
    if (!sImage) {
        sImage = Share_Image;
    }
    
    //[UMSocialConfig hiddenNotInstallPlatforms:SnsConfig];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:SHARE_WECHAT_APPID appSecret:SHARE_WECHAT_SECRECT url:shareUrl];
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:SHARE_QQ_APPID appKey:SHARE_QQ_KEY url:shareUrl];
    
    [UMSocialSnsService presentSnsIconSheetView:mainVc
                                         appKey:UMSHARE_KEY
                                      shareText:sContent
                                     shareImage:sImage
                                shareToSnsNames:SnsConfig
                                       delegate:nil];
}

- (void)presentShareAppDownloadLinkViewIn:(UIViewController*)mainVc {
    [self presentShareViewIn:mainVc withContent:Share_Words image:nil shareUrl:Social_Share_Link];
}

- (void)presentCustomerShareViewIn:(UIViewController*)mainVc {
    parrentVc = mainVc;
    self.view.frame = AppKeyWindow.bounds;
    [AppKeyWindow addSubview:self.view];
    
    maskView = [[UIView alloc] initWithFrame:self.view.frame];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0.4;
    [self.view addSubview:maskView];
    
    customerPannel = [[UIView alloc] initWithFrame:CGRectMake(10.f, self.view.frame.size.height, 300.f, 265.f)];
    customerPannel.layer.cornerRadius = 1.f;
    customerPannel.backgroundColor = GetColorWithRGB(239, 239, 239);
    [self.view addSubview:customerPannel];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    menuView = [[UICollectionView alloc] initWithFrame:CGRectMake(40, 0, 220, 200) collectionViewLayout:flowLayout];
    menuView.dataSource = self;
    menuView.delegate = self;
    menuView.backgroundColor = [UIColor clearColor];
    menuView.scrollEnabled = NO;
    [customerPannel addSubview:menuView];
    
    [menuView registerNib:[UINib nibWithNibName:@"ShareMenuItemCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ShareMenuItemCollectionViewCell"];
    [menuView reloadData];
    
    
    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(10.f, menuView.frame.origin.y+menuView.frame.size.height+10.f, 280.f, 45.f)];
    [btnCancel setBackgroundImage:[UIImage imageNamed:@"share_cancel_button.png"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:GetColorWithRGB(110, 110, 110) forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [customerPannel addSubview:btnCancel];
    
    [UIView animateWithDuration:0.3 animations:^{
        setViewFrameOriginY(customerPannel, self.view.frame.size.height - customerPannel.frame.size.height);
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        setViewFrameOriginY(customerPannel, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
        
        [maskView removeFromSuperview];
        [customerPannel removeFromSuperview];
    }];
}

#pragma mark - 结果回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        //        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"分享到%@成功!",[[response.data allKeys] objectAtIndex:0]]];
    }
    else if (response.responseCode == UMSResponseCodeBaned) {
        [SVProgressHUD showErrorWithStatus:@"分享失败，您的账户已被封禁！"];
    }
    else if (response.responseCode == UMSResponseCodeShareRepeated) {
        [SVProgressHUD showErrorWithStatus:@"分享失败：发送内容为空！"];
    }
    else if (response.responseCode == UMSResponseCodeGetNoUidFromOauth) {
        [SVProgressHUD showErrorWithStatus:@"分享失败：分享内容重复！"];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"分享失败"];
    }
    
    NSLog(@"%d",response.responseCode);
}


#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reusedIdentify = @"ShareMenuItemCollectionViewCell";
    ShareMenuItemCollectionViewCell *cell = (ShareMenuItemCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reusedIdentify forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:reusedIdentify owner:self options:nil] objectAtIndex:0];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    NSInteger flag = indexPath.section*100 + indexPath.row;
    switch (flag) {
        case 0:
            cell.title = @"微信好友";
            cell.img = [UIImage imageNamed:@"share_wechat_friend.png"];
            break;
        case 1:
            cell.title = @"微信朋友圈";
            cell.img = [UIImage imageNamed:@"share_wechat_timeline.png"];
            break;
        case 100:
            cell.title = @"新浪微博";
            cell.img = [UIImage imageNamed:@"share_weibo.png"];
            break;
        case 101:
            cell.title = @"QQ空间";
            cell.img = [UIImage imageNamed:@"share_qzone.png"];
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(98, 98);
}
//定义每个UICollectionViewCell 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger flag = indexPath.section*100 + indexPath.row;
    if (flag == 100) {
        flag = 2;
    }
    if (flag == 101) {
        flag = 3;
    }
    if (flag >= SnsConfig.count) {
        return;
    }
    
    NSString *snsName = SnsConfig[flag];
    NSString *shareTitle = @"1020家庭医生";
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:SHARE_WECHAT_APPID appSecret:SHARE_WECHAT_SECRECT url:Social_Share_Link];
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:SHARE_QQ_APPID appKey:SHARE_QQ_KEY url:Social_Share_Link];
    
//    [[UMSocialControllerService defaultControllerService] setShareText:Share_Words shareImage:[UIImage imageNamed:@"icon_ios7.png"] socialUIDelegate:self];
    
    UMSocialData *socialData = [[UMSocialData alloc] initWithIdentifier:@"iosShare"];
    socialData.title = shareTitle;
    socialData.shareText = Share_Words;
    socialData.shareImage = Share_Image;
//    socialData.commentText = @"comment text";
    
    switch (flag) {
        case 0://微信好友
            socialData.extConfig.wechatSessionData.title = shareTitle;
            socialData.extConfig.wechatSessionData.url = Social_Share_Link;
            break;
        case 1://微信朋友圈
            socialData.extConfig.wechatTimelineData.title = shareTitle;
            socialData.extConfig.wechatTimelineData.url = Social_Share_Link;
            break;
        case 2://新浪微博
            socialData.urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:Social_Share_Link];
            break;
        case 3://qq空间
            socialData.extConfig.qzoneData.title = shareTitle;
            socialData.extConfig.qzoneData.url = Social_Share_Link;
            break;
        default:
            break;
    }
    [[UMSocialControllerService defaultControllerService] setSocialData:socialData];
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsName];
    snsPlatform.snsClickHandler(parrentVc,[UMSocialControllerService defaultControllerService],YES);
    
    [self dismiss];
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
@end
