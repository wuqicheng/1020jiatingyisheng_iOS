//
//  SGFocusImageItem.h
//  ScrollViewLoop
//
//  Created by Vincent Tang on 13-7-18.
//  Copyright (c) 2013年 Vincent Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGFocusImageItem : NSObject

@property (nonatomic, retain) NSString  *title;
@property (nonatomic, retain) NSString  *image;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, retain) NSString  *imageURLStr;
@property (nonatomic, retain) NSString *imageID;

- (id)initWithTitle:(NSString *)title image:(NSString *)image tag:(NSInteger)tag imageURLStr:(NSString *)imageURLStr imageID:(NSString *)imageID;
- (id)initWithDict:(NSDictionary *)dict tag:(NSInteger)tag;

@end
