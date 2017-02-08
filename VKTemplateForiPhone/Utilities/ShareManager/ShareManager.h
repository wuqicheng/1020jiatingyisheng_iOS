//
//  ShareManager.h
//  GolfFriend
//
//  Created by Vescky on 14-5-18.
//  Copyright (c) 2014年 vescky.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMSocial.h"

@interface ShareManager : UIViewController<UMSocialUIDelegate,UICollectionViewDataSource,UICollectionViewDelegate> {
    UIView *customerPannel,*maskView;
    UICollectionView *menuView;
    UIViewController *parrentVc;
}

+ (id)shareManeger;

//- (void)shareToSocialPlatformWithUrl:(NSString*)_url title:(NSString*)_stitle text:(NSString*)_text image:(UIImage*)_image parrentViewController:(UIViewController*)parrentVc;

- (void)presentShareViewIn:(UIViewController*)mainVc withContent:(NSString*)sContent image:(UIImage*)sImage shareUrl:(NSString*)shareUrl;

- (void)presentShareAppDownloadLinkViewIn:(UIViewController*)mainVc;

- (void)presentCustomerShareViewIn:(UIViewController*)mainVc;

@end
