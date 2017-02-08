//
//  BaseDao.h
//  SQLiteSample
//
//  Created by wang xuefeng on 10-12-29.
//  Copyright 2010 www.5yi.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@class FMDatabase;


@interface BaseDao : NSObject {
	FMDatabase *db;
}

@property (nonatomic, retain) FMDatabase *db;

- (NSString *)SQL:(NSString *)sql;
- (NSString *)SQL:(NSString *)sql inTable:(NSString *)table;

- (void)insert:(NSMutableDictionary *)columnsAndValues inTable:(NSString *)table;

- (void)update:(NSMutableDictionary *)columnsAndValues where:(NSString *)where is:(id)value inTable:(NSString *)table;
- (void)update:(NSMutableDictionary *)columnsAndValues where:(NSMutableDictionary *)whereValue inTable:(NSString *)table;
- (BOOL)remove:(NSString *)where is:(id)value inTable:(NSString *)table;

- (NSMutableArray *)queryAll:(NSString *)table;

- (NSMutableArray *)query:(NSString *)table currentPage:(NSInteger)currentPage pageSize:(NSInteger)pageSize;

- (NSMutableArray *)queryByConfition:(NSString *)condition;

- (NSMutableArray *)queryByConfition:(NSString *)condition currentPage:(NSInteger)currentPage pageSize:(NSInteger)pageSize;

@end