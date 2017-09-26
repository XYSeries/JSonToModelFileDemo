//
//  CreateModel.m
//  JsonToModelFileDemo
//
//  Created by 刘学阳 on 2017/9/20.
//  Copyright © 2017年 刘学阳. All rights reserved.
//

#import "CreateModel.h"
@interface CreateModel ()
//json 只读的 如果传入的json为格式化的格式 可获取原来的json
@property (nonatomic, copy) NSString *json;
//格式化json串后的数据
@property (nonatomic, strong) NSString *formatJson;
//存放多级model 的数组
@property (nonatomic, strong) NSMutableArray *mutiModelArray;
/**
 * 处理数据
 * @param obj 字典或数组 key是字典情况下用
 * @return NSDictionary @{@"allProperty":@[],@"objInArr":@[]}
 */
- (NSDictionary *)handleDateEngine:(id)obj key:(NSString *)key;
/**
 * 处理数据 实现多层model分离
 * @param obj 字典或数组 key是字典情况下用 outerModel 外层model
 * @return NSDictionary @{@"allProperty":@[],@"objInArr":@[]}
 */
- (NSDictionary *)handleDateEngine:(id)obj key:(NSString *)key outerModel:(MutiModelAttribute *)outerModel;
/**
 * 下面是实首字母大写的方法
 * @param className 类名 作用用来大写类名的首字母
 */
- (NSString *)upperFirstLetter:(NSString *)className;
/**
 * 下面是去除关键字的方法
 */
- (NSString *)takeOutKeyWord:(NSString *)string;
/**
 * 下面是将所有属性连接成字符串的方法
 */
inline NSString * getPropertyString(NSArray *propertys);
/**
 * 下面是将所有的键值对拼接的方法
 */
inline NSString * getAllKeyValueString(NSArray *objInArr);
/**
 * 创建文件
 */
- (BOOL)createFileAtPath:(NSString *)filePath;
@end
@implementation CreateModel
#pragma mark - Lazy loading -
- (NSMutableArray *)mutiModelArray
{
    if (!_mutiModelArray) {
        _mutiModelArray = [[NSMutableArray alloc]init];
    }
    return _mutiModelArray;
}
- (NSMutableString *)headerString
{
    if (!_headerString) {
        _headerString = [[NSMutableString alloc]init];
        
    }
    return _headerString;
}
- (NSMutableString *)sourceString
{
    if (!_sourceString) {
        _sourceString = [[NSMutableString alloc]init];
    }
    return _sourceString;
}

#pragma mark - publick method -
/**
 * 格式化字符串
 * @param json json
 */
- (BOOL)formatJson:(NSString *)json
{
    NSError *error = nil;
    NSData  * jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    if (error)
    {
        __block NSString *formatStr = json;
        NSArray *beReplaceStrs = @[@";",@"(",@")"];
        NSArray *replaceStrs = @[@",",@"[",@"]"];
        for (NSInteger i = 0; i < replaceStrs.count; i++)
        {
            formatStr = [formatStr stringByReplacingOccurrencesOfString:beReplaceStrs[i] withString:replaceStrs[i]];
        }
        formatStr = [self replaceUnicode:formatStr];
        // format key
        NSRegularExpression *regkey = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z0-9_]+[ \r\n]{0,}[=]{1,1}?" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matchkey = [regkey matchesInString:formatStr options:NSMatchingReportProgress range:NSMakeRange(0, formatStr.length)];
        [matchkey enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSTextCheckingResult *result = obj;
            NSRange range = result.range;
            NSString *key = [formatStr substringWithRange:range];
            
            if (![key hasPrefix:@"http:"]&&![key hasPrefix:@"https:"]&&![key hasPrefix:@"file:"]&&![key hasPrefix:@"email:"]&&![key hasPrefix:@"tel:"])
            {
                NSRegularExpression *regkey = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z0-9_]+" options:NSRegularExpressionCaseInsensitive error:nil];
                
                NSString *replaceStr = [regkey stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, key.length) withTemplate:@"\"$0\""];
                
                formatStr = [formatStr stringByReplacingCharactersInRange:range withString:replaceStr];
                
            }
            
        }];
        // format value
        NSError *err = nil;
        NSString *pattern = @"[=][a-zA-Z0-9._ \\r\"\",~`:\\/!@#$%^&*()+=?\\u4e00-\\u9fa5]{1,}[,]{1,1}?";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&err];
        NSArray *matchValue = [regex matchesInString:formatStr options:NSMatchingCompleted range:NSMakeRange(0, formatStr.length)];
        
        NSString *regNumber=@"-?[0-9.?]+";
        NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regNumber];
        
        NSString *regStr = @"^[\"][a-zA-Z0-9._ \r"",~`:/!@#$%^&*()+=?\u4e00-\u9fa5]{0,}[\"]{1,1}$";
        NSPredicate *strPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regStr];
        NSPredicate *datePre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[0-9]{2}:[0-9]{2}"];
        [matchValue enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSTextCheckingResult *result = obj;
            NSRange range = result.range;
            NSString *value = [formatStr  substringWithRange:NSMakeRange(range.location + 1 , range.length - 2)];
            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if (![value isEqualToString:@"\"\""]&&![numberPre evaluateWithObject:value]&&![strPre evaluateWithObject:value]&&![datePre evaluateWithObject:value])
            {
                formatStr = [formatStr stringByReplacingCharactersInRange:NSMakeRange(range.location + 1, range.length - 2) withString:[NSString stringWithFormat:@"\"%@\"",value]];
            }
            formatStr = [formatStr stringByReplacingOccurrencesOfString:@"=" withString:@":"];
            self.json = formatStr;
            
        }];
        _formatJson = self.json;
        NSError *erro = nil;
        jsonData = [_json dataUsingEncoding:NSUTF8StringEncoding];
        dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&erro];
        if (erro) {
            _errorMsg = erro.userInfo[@"NSDebugDescription"];
            return NO;
            
        }
    }else{
        self.json = json;
        _formatJson = dict.description;
    }
    
    return YES;
}
- (NSString *)replaceUnicode:(NSString *)unicodeStr {
    
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:nil error:nil];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}
/**
 * 创建出model
 * @param json json数据
 * @return BOOL 成功为YES json结构出错 会失败 返回NO allowMuti 允许多级
 */
- (BOOL)createModelWithJson:(NSString *)json allowMuti:(BOOL)allowMuti
{
    if (json == nil || json.length == 0)
    {
        return NO;
    }
    
    NSError *error = nil;
    NSData  * jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    if (error)
    {
        return NO;
    }
    
    [self.headerString setString:@""];
    [self.sourceString setString:@""];
    
    if (_className == nil || _className.length == 0)
    {
        _className = k_DEFAULT_CLASS_NAME;
    }
    
    NSString *dateStr = [NSDate stringWithFormat:@"yyyy/MM/dd"];
    NSString *dateStr2 = [NSDate stringWithFormat:@"yyyy"];
    
    [self.headerString appendFormat:k_HEADINFO('h'),_className,dateStr,dateStr2];
    [self.sourceString appendFormat:k_HEADINFO('m'),_className,dateStr,dateStr2,_className];
    
    NSDictionary *propertyAndKeyValue = [self handleDateEngine:dict key:@""];
    NSString *property = getPropertyString(propertyAndKeyValue[@"allProperty"]);
    [self.headerString appendFormat:k_CLASS,_className,property];
    NSString *keyValue = getAllKeyValueString(propertyAndKeyValue[@"objInArr"]);
    [self.sourceString appendFormat:k_CLASS_M,_className,METHODIMP(keyValue)];
    
    [self.mutiModelArray removeAllObjects];
    if (allowMuti == YES) {
        MutiModelAttribute *firstModelAtt = [[MutiModelAttribute alloc]initWithClassName:_className];
        NSDictionary *mutiPropAndKeyValue = [self handleDateEngine:dict key:@"" outerModel:firstModelAtt];
        NSString *mutiProp= getPropertyString(mutiPropAndKeyValue[@"allProperty"]);
        [firstModelAtt.headString appendFormat:k_CLASS,_className,mutiProp];
        NSString *mutikeyValue = getAllKeyValueString(mutiPropAndKeyValue[@"objInArr"]);
        [firstModelAtt.sourceString appendFormat:k_CLASS_M,_className,METHODIMP(mutikeyValue)];
        [self.mutiModelArray addObject:firstModelAtt];
    }
    NSLog(@"self.mutiModelArray:%@",self.mutiModelArray);
    return YES;
}
/**
 * 生成文件并存放到指定的目录下
 * @param muti 多级情况
 * @return 成功为YES 失败为NO
 */
- (BOOL)generateFileAllowMuti:(BOOL)muti;

{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *dirPath = [paths[0] stringByAppendingPathComponent:@"ClassFiles"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:dirPath error:nil];
    BOOL dir = NO;
    BOOL exis = [fm fileExistsAtPath:dirPath isDirectory:&dir];
    if (!exis && !dir)
    {
        [fm createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    BOOL headFileFlag = NO;
    BOOL sourceFileFlag = NO;
    NSString *headFilePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h",_className]];
    NSString *sourceFilePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m",_className]];
    
    if (!muti) {
        headFileFlag = [self.headerString writeToFile:headFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        
        sourceFileFlag =  [self.sourceString writeToFile:sourceFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        
        if (headFileFlag && sourceFileFlag)
        {
            return YES;
        }
        return NO;
    }else{
        NSInteger i = 0;
        for (i = 0; i < self.mutiModelArray.count; i++)
        {
            MutiModelAttribute *modelAtt = self.mutiModelArray[i];
            headFilePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h",modelAtt.className]];
            sourceFilePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m",modelAtt.className]];
            
            headFileFlag = [modelAtt.headString writeToFile:headFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
            
            sourceFileFlag =  [modelAtt.sourceString writeToFile:sourceFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
            
            if (headFileFlag && sourceFileFlag)
            {
                continue;
            }
            break;
            
        }
        if (i == self.mutiModelArray.count)
        {
            return YES;
        }
    }
    return NO;
}

#pragma  mark - private method -
/**
 * 处理数据
 * @param obj 字典或数组 key是字典情况下用
 * @return NSDictionary @{@"allProperty":@[],@"objInArr":@[]}
 */
- (NSDictionary *)handleDateEngine:(id)obj key:(NSString *)key
{
    
    if (!obj || [obj isEqual:[NSNull null]])
    {
        return nil;
    }
    
    NSMutableArray *propertyArr = [[NSMutableArray alloc]init];
    NSMutableArray *objInArr = [[NSMutableArray alloc]init];
    if ([obj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic = (NSDictionary *)obj;
        NSArray *allKeys = [dic allKeys];
        for (NSInteger i = 0; i < allKeys.count; i++)
        {
            id subObj = dic[allKeys[i]];
            if ([subObj isKindOfClass:[NSDictionary class]])
            {
                
                NSDictionary *classContent = [self handleDateEngine:subObj key:allKeys[i]];
                NSString *className = [self upperFirstLetter:allKeys[i]];
                NSString *curKey = [self takeOutKeyWord:allKeys[i]];
                NSString *property = [NSString stringWithFormat:k_PROPERTY('s'),className,curKey];
                [propertyArr addObject:property];
                
                NSString *curAllProperty = getPropertyString(classContent[@"allProperty"]);
                NSString *allKeyValue = getAllKeyValueString(classContent[@"objInArr"]);
                [self.headerString appendFormat:k_CLASS,className,curAllProperty];
                [self.sourceString appendFormat:k_CLASS_M, className,METHODIMP(allKeyValue)];
                
            }else if ([subObj isKindOfClass:[NSArray class]]){
                
                NSString *className = [self upperFirstLetter:allKeys[i]];
                NSString *curKey = [self takeOutKeyWord:allKeys[i]];
                NSString *property = [NSString stringWithFormat:k_PROPERTY('s'),[NSString stringWithFormat:@"NSArray <%@ *>",className],curKey];
                [propertyArr addObject:property];
                
                NSString * keyValue = [NSString stringWithFormat:@"@\"%@\" : @\"%@\"",curKey,className];
                [objInArr addObject:keyValue];
                
                NSDictionary * classContent = [self handleDateEngine:subObj key:allKeys[i] ];
                NSString *curAllProperty = getPropertyString(classContent[@"allProperty"]);
                NSString *allKeyValue = getAllKeyValueString(classContent[@"objInArr"]);
                [self.headerString appendFormat:k_CLASS,className,curAllProperty];
                [self.sourceString appendFormat:k_CLASS_M,className,METHODIMP(allKeyValue)];
                
            }else if ([subObj isKindOfClass:[NSString class]]){
                NSString *curKey = [self takeOutKeyWord:allKeys[i]];
                NSString *property = [NSString stringWithFormat:k_PROPERTY('c'),@"NSString",curKey];
                [propertyArr addObject:property];
            }else if ([subObj isKindOfClass:[NSNumber class]]){
                NSString *curKey = [self takeOutKeyWord:allKeys[i]];
                NSString *property = [NSString stringWithFormat:k_PROPERTY('c'),@"NSNumber",curKey];
                [propertyArr addObject:property];
            }else{
                if (subObj == nil || [subObj isEqual:[NSNull null]])
                {
                    NSString *curKey = [self takeOutKeyWord:allKeys[i]];
                    NSString *property = [NSString stringWithFormat:k_PROPERTY('c'),@"NSString",curKey];
                    [propertyArr addObject:property];
                }
            }
        }
    }else if ([obj isKindOfClass:[NSArray class]]){
        NSArray *dicArray = (NSArray *)obj;
        if (dicArray.count > 0)
        {
            id tempObj = dicArray[0];
            for (NSInteger i = 1; i < dicArray.count; i++)
            {
                id subObj = dicArray[i];
                if([subObj isKindOfClass:[NSDictionary class]]){
                    if(((NSDictionary *)subObj).count > ((NSDictionary *)tempObj).count)
                    {
                        tempObj = subObj;
                    }
                }
            }
            NSDictionary *classContent = [self handleDateEngine:tempObj key:key];
            NSString *property = getPropertyString(classContent[@"allProperty"]);
            [propertyArr addObject:property];
        }
    }else{
        NSLog(@"obj 是NSString 或 NSNumber key = %@",key);
    }
    return @{@"allProperty" : propertyArr, @"objInArr" : objInArr};
}
/**
 * 处理数据 实现多层model分离
 * @param obj 字典或数组 key是字典情况下用 outerModel 外层model
 * @return NSDictionary @{@"allProperty":@[],@"objInArr":@[]}
 */
- (NSDictionary *)handleDateEngine:(id)obj key:(NSString *)key outerModel:(MutiModelAttribute *)outerModel
{
    if (!obj || [obj isEqual:[NSNull null]])
    {
        return nil;
    }
    
    NSMutableArray *propertyArr = [[NSMutableArray alloc]init];
    NSMutableArray *objInArr = [[NSMutableArray alloc]init];
    if ([obj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic = (NSDictionary *)obj;
        NSArray *allKeys = [dic allKeys];
        for (NSInteger i = 0; i < allKeys.count; i++)
        {
            id subObj = dic[allKeys[i]];
            if ([subObj isKindOfClass:[NSDictionary class]])
            {
                
                NSString *className = [self upperFirstLetter:allKeys[i]];
                NSString *curKey = [self takeOutKeyWord:allKeys[i]];
                NSString *property = [NSString stringWithFormat:k_PROPERTY('s'),className,curKey];
                [propertyArr addObject:property];
                
                [outerModel.headString appendFormat:k_AT_CLASS,className];
                MutiModelAttribute *modelAtt = [[MutiModelAttribute alloc]initWithClassName:className];
                NSDictionary *classContent = [self handleDateEngine:subObj key:allKeys[i] outerModel:modelAtt];
                NSString *curAllProperty = getPropertyString(classContent[@"allProperty"]);
                NSString *allKeyValue = getAllKeyValueString(classContent[@"objInArr"]);
                [modelAtt.headString appendFormat:k_CLASS,className,curAllProperty];
                [modelAtt.sourceString appendFormat:k_CLASS_M, className,METHODIMP(allKeyValue)];
                [self.mutiModelArray addObject:modelAtt];
                
            }else if ([subObj isKindOfClass:[NSArray class]]){
                
                NSString *className = [self upperFirstLetter:allKeys[i]];
                NSString *curKey = [self takeOutKeyWord:allKeys[i]];
                NSString *property = [NSString stringWithFormat:k_PROPERTY('s'),[NSString stringWithFormat:@"NSArray <%@ *>",className],curKey];
                [propertyArr addObject:property];
                
                NSString * keyValue = [NSString stringWithFormat:@"@\"%@\" : @\"%@\"",curKey,className];
                [objInArr addObject:keyValue];
                
                [outerModel.headString appendFormat:k_AT_CLASS,className];
                MutiModelAttribute *modelAtt = [[MutiModelAttribute alloc]initWithClassName:className];
                NSDictionary *classContent = [self handleDateEngine:subObj key:allKeys[i] outerModel:modelAtt];
                NSString *curAllProperty = getPropertyString(classContent[@"allProperty"]);
                NSString *allKeyValue = getAllKeyValueString(classContent[@"objInArr"]);
                
                [modelAtt.headString appendFormat:k_CLASS,className,curAllProperty];
                [modelAtt.sourceString appendFormat:k_CLASS_M, className,METHODIMP(allKeyValue)];
                [self.mutiModelArray addObject:modelAtt];
                
            }else if ([subObj isKindOfClass:[NSString class]]){
                NSString *curKey = [self takeOutKeyWord:allKeys[i]];
                NSString *property = [NSString stringWithFormat:k_PROPERTY('c'),@"NSString",curKey];
                [propertyArr addObject:property];
            }else if ([subObj isKindOfClass:[NSNumber class]]){
                NSString *curKey = [self takeOutKeyWord:allKeys[i]];
                NSString *property = [NSString stringWithFormat:k_PROPERTY('c'),@"NSNumber",curKey];
                [propertyArr addObject:property];
            }else{
                if (subObj == nil || [subObj isEqual:[NSNull null]])
                {
                    NSString *curKey = [self takeOutKeyWord:allKeys[i]];
                    NSString *property = [NSString stringWithFormat:k_PROPERTY('c'),@"NSString",curKey];
                    [propertyArr addObject:property];
                    
                }
            }
        }
    }else if ([obj isKindOfClass:[NSArray class]]){
        NSArray *dicArray = (NSArray *)obj;
        if (dicArray.count > 0)
        {
            id tempObj = dicArray[0];
            for (NSInteger i = 1; i < dicArray.count; i++)
            {
                id subObj = dicArray[i];
                if([subObj isKindOfClass:[NSDictionary class]]){
                    if(((NSDictionary *)subObj).count > ((NSDictionary *)tempObj).count)
                    {
                        tempObj = subObj;
                    }
                }
            }
            NSDictionary *classContent = [self handleDateEngine:tempObj key:key outerModel:outerModel];
            NSString *property = getPropertyString(classContent[@"allProperty"]);
            [propertyArr addObject:property];
            
        }
    }else{
        NSLog(@"key = %@",key);
    }
    return @{@"allProperty" : propertyArr, @"objInArr" : objInArr};
    
}
/**
 * 下面是实首字母大写的方法
 * @param className 类名 作用用来大写类名的首字母
 */
- (NSString *)upperFirstLetter:(NSString *)className
{
    NSString *capStr = [className capitalizedStringWithLocale:[NSLocale currentLocale]];
    if ([capStr hasSuffix:@"es"])
    {
        capStr = [capStr substringToIndex:capStr.length - 2];
    }else if ([capStr hasSuffix:@"s"]){
        capStr = [capStr substringToIndex:capStr.length - 1];
    }
    return capStr;
}
/**
 * 下面是去除关键字的方法
 */
- (NSString *)takeOutKeyWord:(NSString *)string
{
    NSString *str = string;
    NSArray *keyWords = @[@"id",@"description"];
    for (NSInteger i = 0; i < keyWords.count; i++)
    {
        if ([string isEqualToString:keyWords[i]])
        {
            str = [string uppercaseString];
            break;
        }
        
    }
    return str;
}
/**
 * 下面是将所有属性连接成字符串的方法
 */
inline NSString * getPropertyString(NSArray *propertys)
{
    NSString *propertyStr = [propertys componentsJoinedByString:@"\n"];
    return propertyStr;
}
/**
 * 下面是将所有的键值对拼接的方法
 */
inline NSString * getAllKeyValueString(NSArray *objInArr)
{
    NSString *allKeyValue = [objInArr componentsJoinedByString:@","];
    return allKeyValue;
}
/**
 * 创建文件
 */
- (BOOL)createFileAtPath:(NSString *)filePath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL sc = NO;
    if ([fm fileExistsAtPath:filePath])
    {
        return YES;
    }else{
        sc = [fm createFileAtPath:filePath contents:nil attributes:nil];
    }
    return sc;
}
@end
