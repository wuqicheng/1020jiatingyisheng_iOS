//
//  WebAppViewController.h
//  aixiche
//
//  Created by Vescky on 14-10-24.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebAppViewController : AppsBaseViewController<UIWebViewDelegate> {
    
}

@property (nonatomic,strong) IBOutlet UIWebView *wView;
@property (nonatomic,strong) NSString *webAppLink;
@property (nonatomic,strong) NSString *htmlContent;

@end
