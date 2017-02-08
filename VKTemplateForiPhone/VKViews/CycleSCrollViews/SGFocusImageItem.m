//
//  SGFocusImageItem.m
//  ScrollViewLoop
//
//  Created by Vincent Tang on 13-7-18.
//  Copyright (c) 2013年 Vincent Tang. All rights reserved.
//

#import "SGFocusImageItem.h"

@implementation SGFocusImageItem
@synthesize title = _title;
@synthesize image = _image;
@synthesize tag = _tag;
@synthesize imageURLStr = _imageURLStr;
@synthesize imageID = _imageID;

- (void)dealloc
{
    self.title = nil;
    self.image = nil;
    self.imageURLStr = nil;
    self.imageID = nil;
}
- (id)initWithTitle:(NSString *)title image:(NSString *)image tag:(NSInteger)tag imageURLStr:(NSString *)imageURLStr imageID:(NSString *)imageID
{
    self = [super init];
    if (self) {
        self.title = title;
        self.image = image;
        self.tag = tag;
        self.imageURLStr = imageURLStr;
        self.imageID = imageID;
    }
    
    return self;
}


- (id)initWithDict:(NSDictionary *)dict tag:(NSInteger)tag
{
    self = [super init];
    if (self)
    {
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            self.title = [dict objectForKey:@"title"];
            self.image = [dict objectForKey:@"image"];
            self.imageURLStr = [dict objectForKey:@"imageURLStr"];
            self.imageID = [dict objectForKey:@"imageID"];
            //...
        }
    }
    return self;
}
@end
