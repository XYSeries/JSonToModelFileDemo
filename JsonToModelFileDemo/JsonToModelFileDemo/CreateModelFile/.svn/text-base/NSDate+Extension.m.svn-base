//
//  NSDate+Extension.m
//  JsonToModelFileDemo
//
//  Created by 刘学阳 on 2017/9/21.
//  Copyright © 2017年 刘学阳. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)
+ (NSString *) stringWithFormat: (NSString *) format
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone]; // 获得系统的时区
    NSTimeInterval time = [zone secondsFromGMTForDate:date];
    NSDate *localDate = [date dateByAddingTimeInterval:time];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = format;
    return [formatter stringFromDate:localDate];
}

@end
