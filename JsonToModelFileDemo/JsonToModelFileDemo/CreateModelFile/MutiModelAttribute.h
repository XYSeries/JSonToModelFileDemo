//
//  MutiModelAttribute.h
//  JsonToModelFileDemo
//
//  Created by 刘学阳 on 2017/9/20.
//  Copyright © 2017年 刘学阳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+Extension.h"
#define k_HEADINFO(h) ((h) == 'h' ? @("//\n//  %@.h\n//  这里是你的工程名，请自己修改\n//  Created by 你自己 on %@.\n// Copyright © %@年 你自己. All rights reserved.\n//\n\n#import <Foundation/Foundation.h>\n#import \"Masonry.h\" \n") :@("//\n//  %@.m\n//  这里是你的工程名，请自己修改\n//  Created by 你自己 on %@.\n//  Copyright © %@年 你自己. All rights reserved.\n//\n\n#import \"%@.h\"\n"))
#define k_DEFAULT_CLASS_NAME @("Model")
#define k_AT_CLASS @("@class %@;\n")
#define k_CLASS       @("\n@interface %@ :NSObject\n%@\n@end\n")
#define k_PROPERTY(s)    ((s) == 'c' ? @("@property (nonatomic , copy) %@ * %@;\n") : @("@property (nonatomic , strong) %@ * %@;\n"))

#define METHODIMP(keyValue) [NSString stringWithFormat:NSLocalizedString(@"method",nil),keyValue]
#define k_CLASS_M     @("\n\n@implementation %@\n\n%@\n@end\n")

@interface MutiModelAttribute : NSObject
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSMutableString *headString;
@property (nonatomic, strong) NSMutableString *sourceString;

- (instancetype)initWithClassName:(NSString *)className;
@end



