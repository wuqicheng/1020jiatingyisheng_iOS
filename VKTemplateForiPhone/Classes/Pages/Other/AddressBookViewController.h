//
//  AddressBookViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/2/28.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddressBookViewDelegate;

@interface AddressBookViewController : AppsBaseViewController {
    IBOutlet UITableView *tbView;
    IBOutlet UILabel *labelO;
    IBOutlet UITextField *tfDetail;
    IBOutlet UITableViewCell *cell1,*cell2;
    UIView *pickerContainer;
    UIPickerView *pickerViewCity;
}

@property (nonatomic) bool selectable;
@property (nonatomic,strong) NSDictionary *selectedInfo;
@property (nonatomic,assign) id <AddressBookViewDelegate> delegate;


@end


@protocol AddressBookViewDelegate <NSObject>

- (void)addressbookViewController:(AddressBookViewController*)abVc selectedInfo:(NSDictionary*)sInfo;

@end