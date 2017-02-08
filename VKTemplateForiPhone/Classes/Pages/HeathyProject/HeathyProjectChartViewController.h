//
//  HeathyProjectChartViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/22.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeathyProjectChartViewController : AppsBaseViewController {
    IBOutlet UIScrollView *scView,*coordinatesDataView;
    IBOutlet UIView *chartView,*coordinatesView;
    IBOutlet UILabel *labelDate;
}

@end
