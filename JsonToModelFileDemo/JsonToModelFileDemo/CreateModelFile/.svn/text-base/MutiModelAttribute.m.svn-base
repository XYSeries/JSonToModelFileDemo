//
//  MutiModelAttribute.m
//  JsonToModelFileDemo
//
//  Created by 刘学阳 on 2017/9/20.
//  Copyright © 2017年 刘学阳. All rights reserved.
//

#import "MutiModelAttribute.h"

@implementation MutiModelAttribute
- (instancetype)initWithClassName:(NSString *)className
{
    self = [super init];
    if (self) {
        _className = className;
    }
    return self;
}
#pragma mark - Lazy loading -
- (NSMutableString *)headString
{
    if (!_headString) {
        _headString = [[NSMutableString alloc]init];
        
        NSString *dateStr = [NSDate stringWithFormat:@"yyyy/MM/dd"];
        NSString *dateStr2 = [NSDate stringWithFormat:@"yyyy"];
        [_headString appendFormat:k_HEADINFO('h'),_className,dateStr,dateStr2];
        
    }
    return _headString;
}
- (NSMutableString *)sourceString
{
    if (!_sourceString) {
        _sourceString = [[NSMutableString alloc]init];
        
        NSString *dateStr = [NSDate stringWithFormat:@"yyyy/MM/dd"];
        NSString *dateStr2 = [NSDate stringWithFormat:@"yyyy"];
        [_sourceString appendFormat:k_HEADINFO('m'),_className,dateStr,dateStr2,_className];
    }
    return _sourceString;
}
@end
