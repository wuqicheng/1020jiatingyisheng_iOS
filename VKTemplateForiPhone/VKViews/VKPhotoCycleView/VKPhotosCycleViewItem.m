//
//  VKPhotosCycleViewItem.m
//  test
//
//  Created by vescky.luo on 14-9-9.
//  Copyright (c) 2014年 vescky.luo. All rights reserved.
//

#import "VKPhotosCycleViewItem.h"

@implementation VKPhotosCycleViewItem

@synthesize imageUrl,title,tag,ext;

- (id)initVKPhotosCycleViewItemWithTitle:(NSString*)_title ImageUrl:(NSString*)_imageUrl Tag:(int)_tag {
    self = [super init];
    if (self) {
        self.title = _title;
        self.imageUrl = _imageUrl;
        self.tag = _tag;
    }
    
    return self;
}

- (id)initVKPhotosCycleViewItemWithTitle:(NSString*)_title ImageUrl:(NSString*)_imageUrl Tag:(int)_tag ext:(NSDictionary*)_ext {
    self = [self initVKPhotosCycleViewItemWithTitle:_title ImageUrl:_imageUrl Tag:_tag];
    self.ext = _ext;
    return self;
}

@end
