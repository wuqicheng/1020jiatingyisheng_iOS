//
//  BaseDao.m
//  SQLiteSample
//
//  Created by wang xuefeng on 10-12-29.
//  Copyright 2010 www.5yi.com. All rights reserved.
//
#define INDEX @"index"

#import "DB.h"
#import "BaseDao.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"


@implementation BaseDao

@synthesize db;

#pragma mark - Private

- (NSString *)filterParamsCount:(NSInteger)paramsCount {
    NSString *params = @"";
    for(int i = 0;i < paramsCount; i++){
        if([params isEqualToString:@""]){
            params = [params stringByAppendingFormat:@"?"];
        }else{
            params = [params stringByAppendingFormat:@",?"];
        }
    }
    return params;
}

- (NSArray *)filterColumsFromDictionary:(NSMutableDictionary *)columnsAndValues {
    NSArray *keys = [columnsAndValues allKeys];
    NSString *columns = @"";
    NSMutableArray *values = [NSMutableArray array];
    for(NSString *key in keys){
        if([columns isEqualToString:@""]){
            columns = [columns stringByAppendingFormat:@"%@",key];
        }else{
            columns = [columns stringByAppendingFormat:@",%@",key];
        }
        [values addObject:[columnsAndValues objectForKey:key]];
    }
    if([columns isEqualToString:@""]){
        return nil;
    }
    return [NSArray arrayWithObjects:columns,values,nil];
}

- (NSArray *)filterUpdateColumsFromDictionary:(NSMutableDictionary *)columnsAndValues {
    NSArray *keys = [columnsAndValues allKeys];
    NSString *columns = @"";
    NSMutableArray *values = [NSMutableArray array];
    for(NSString *key in keys){
        if([columns isEqualToString:@""]){
            columns = [columns stringByAppendingFormat:@"%@ = ?",key];
        }else{
            columns = [columns stringByAppendingFormat:@",%@ = ?",key];
        }
        [values addObject:[columnsAndValues objectForKey:key]];
    }
    if([columns isEqualToString:@""]){
        return nil;
    }
    return [NSArray arrayWithObjects:columns,values,nil];
}

- (NSArray *)filterUpdateWhereParmaFromDictionary:(NSMutableDictionary *)columnsAndValues {
    NSArray *keys = [columnsAndValues allKeys];
    NSString *columns = @"";
    NSMutableArray *values = [NSMutableArray array];
    for(NSString *key in keys){
        if([columns isEqualToString:@""]){
            columns = [columns stringByAppendingFormat:@"%@ = ?",key];
        }else{
            columns = [columns stringByAppendingFormat:@"AND %@ = ?",key];
        }
        [values addObject:[columnsAndValues objectForKey:key]];
    }
    if([columns isEqualToString:@""]){
        return nil;
    }
    return [NSArray arrayWithObjects:columns,values,nil];
}


- (NSString *)filterColumns:(NSMutableArray *)columns {
    NSString *columnsStr = @"";
    for(int i = 0;i < [columns count]; i++){
        NSString *column = [columns objectAtIndex:i];
        if([columnsStr isEqualToString:@""]){
            columnsStr = [columnsStr stringByAppendingFormat:@"%@",column];
        }else{
            columnsStr = [columnsStr stringByAppendingFormat:@",%@",column];
        }
    }
    return columnsStr;
}

- (NSString *)filterUpdateColumns:(NSMutableArray *)columns {
    NSString *columnsStr = @"";
    for(int i = 0;i < [columns count]; i++){
        NSString *column = [columns objectAtIndex:i];
        if([columnsStr isEqualToString:@""]){
            columnsStr = [columnsStr stringByAppendingFormat:@"%@ = ?",column];
        }else{
            columnsStr = [columnsStr stringByAppendingFormat:@",%@ = ?",column];
        }
    }
    return columnsStr;
}

#pragma mark - Public

- (NSString *)SQL:(NSString *)sql inTable:(NSString *)table inColumn:(NSString *)column {
	return [NSString stringWithFormat:sql, table,column];
}

- (NSString *)SQL:(NSString *)sql inTable:(NSString *)table {
	return [NSString stringWithFormat:sql, table];
}

- (NSString *)SQL:(NSString *)sql {
	return [NSString stringWithFormat:sql];
}

- (void)insert:(NSMutableArray *)columns values:(NSMutableArray *)values inTable:(NSString *)table {
    NSString *columnsStr = [self filterColumns:columns];
    NSString *paramsAttributes = [self filterParamsCount:[columns count]];
    [db executeUpdate:[self SQL:[NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",table,columnsStr,paramsAttributes]] withArgumentsInArray:values];
	if([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
	}
}

- (void)insert:(NSMutableDictionary *)columnsAndValues inTable:(NSString *)table {
    NSArray *params = [self filterColumsFromDictionary:columnsAndValues];
    NSString *paramsAttributes = [self filterParamsCount:[columnsAndValues count]];
    if(params){
        [db executeUpdate:[self SQL:[NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",table,[params objectAtIndex:0],paramsAttributes]] withArgumentsInArray:[params objectAtIndex:1]];
        if([db hadError]) {
            NSLog(@"Err %d: %@ ", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
}

- (void)update:(NSMutableDictionary *)columnsAndValues where:(NSString *)where is:(id)value inTable:(NSString *)table {
    NSArray *params = [self filterUpdateColumsFromDictionary:columnsAndValues];
    if(params){
        NSString *columnsStr = [params objectAtIndex:0];
        NSMutableArray *values = [params objectAtIndex:1];
        [values addObject:value];
        [db executeUpdate:[self SQL:[NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?",table,columnsStr,where]] withArgumentsInArray:values];
        if([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
}

- (void)update:(NSMutableDictionary *)columnsAndValues where:(NSMutableDictionary *)whereValue inTable:(NSString *)table {
    NSArray *params = [self filterUpdateColumsFromDictionary:columnsAndValues];
    NSArray *whereParams = [self filterUpdateWhereParmaFromDictionary:whereValue];
    if(params){
        NSString *columnsStr = [params objectAtIndex:0];
        NSString *whereStr = [whereParams objectAtIndex:0];
        NSMutableArray *values = [params objectAtIndex:1];
        NSMutableArray *whereValues = [whereParams objectAtIndex:1];
        [values addObjectsFromArray:whereValues];
        [db executeUpdate:[self SQL:[NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",table,columnsStr,whereStr]] withArgumentsInArray:values];
        if([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
}

- (BOOL)remove:(NSString *)where is:(id)value inTable:(NSString *)table {
	[db executeUpdate:[self SQL:@"DELETE FROM %@ WHERE %@ = ?" inTable:table inColumn:where],value];
	if([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return NO;
	}
    return YES;
}

- (NSMutableArray *)queryAll:(NSString *)table {
    NSMutableArray *result = [NSMutableArray array];
	FMResultSet *rs = [db executeQuery:[self SQL:@"SELECT * FROM %@" inTable:table]];
	while([rs next]) {
		[result addObject:[rs resultDict]];
	}
	[rs close];	
	return result;
}

- (NSMutableArray *)query:(NSString *)table currentPage:(NSInteger)currentPage pageSize:(NSInteger)pageSize {
    NSMutableArray *result = [NSMutableArray array];
	FMResultSet *rs = [db executeQuery:[self SQL:@"SELECT * FROM %@ limit 0,10" inTable:table],[NSNumber numberWithInt:currentPage * pageSize],[NSNumber numberWithInt:pageSize]];
	while([rs next]) {
		[result addObject:[rs resultDict]];
	}
	[rs close];	
	return result;
}

- (NSMutableArray *)queryByConfition:(NSString *)condition {
    NSMutableArray *result = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:condition];
	while([rs next]) {
		[result addObject:[rs resultDict]];
	}
	[rs close];	
    return result;
}

- (NSMutableArray *)queryByConfition:(NSString *)condition currentPage:(NSInteger)currentPage pageSize:(NSInteger)pageSize {
    NSMutableArray *result = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"%@ limit ?,?",condition],[NSNumber numberWithInt:currentPage],[NSNumber numberWithInt:pageSize]];
//    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"%@ limit %d,%d",condition],[NSNumber numberWithInt:currentPage * pageSize],[NSNumber numberWithInt:pageSize]];
	while([rs next]) {
		[result addObject:[rs resultDict]];
	}
	[rs close];	
    return result;
}

- (id)init{
	if(self = [super init])
	{
		db = [[[DB alloc] getDatabase] retain];
	}
	
	return self;
}

- (void)dealloc {
	[db release];
	[super dealloc];
}

@end