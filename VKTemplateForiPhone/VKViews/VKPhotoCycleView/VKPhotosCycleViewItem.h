//
//  VKPhotosCycleViewItem.h
//  test
//
//  Created by vescky.luo on 14-9-9.
//  Copyright (c) 2014年 vescky.luo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VKPhotosCycleViewItem : NSObject {
    
}

@property (nonatomic,strong) NSString *imageUrl;
@property (nonatomic,strong) NSString *title;
@property (nonatomic) int tag;
@property (nonatomic,strong) NSDictionary *ext;

- (id)initVKPhotosCycleViewItemWithTitle:(NSString*)_title ImageUrl:(NSString*)_imageUrl Tag:(int)_tag;

- (id)initVKPhotosCycleViewItemWithTitle:(NSString*)_title ImageUrl:(NSString*)_imageUrl Tag:(int)_tag ext:(NSDictionary*)_ext;

@end
