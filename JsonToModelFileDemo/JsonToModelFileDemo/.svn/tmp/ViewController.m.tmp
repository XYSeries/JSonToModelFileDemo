//
//  ViewController.m
//  JsonToModelFileDemo
//
//  Created by 刘学阳 on 2017/9/20.
//  Copyright © 2017年 刘学阳. All rights reserved.
//

#import "ViewController.h"
#import "CreateModel.h"

@interface ViewController ()
{
    NSString *_json;
}

@property (weak) IBOutlet NSButton *ForamtBtn;
@property (weak) IBOutlet NSButton *generateFileBtn;
@property (weak) IBOutlet NSTextField *classNameFiled;
@property (unsafe_unretained) IBOutlet NSTextView *jsonDataTextView;
@property (unsafe_unretained) IBOutlet NSTextView *headFileView;
@property (unsafe_unretained) IBOutlet NSTextView *sourceFileView;
@property (weak) IBOutlet NSButton *checkAllowBox;

@property (nonatomic, copy)NSString *json;
@property (nonatomic, strong)CreateModel *createModel;

//打开文件夹
- (void)openFolderWithAppleScriptBecauseTheSandboxIsTerrible:(NSString *)path;
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _jsonDataTextView.automaticQuoteSubstitutionEnabled = NO;
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
    
}


#pragma mark - event method -
//验证json
- (IBAction)verifyJsonAction:(id)sender {
}
- (IBAction)formatJsonAction:(id)sender
{
    [self formatJson];
    
}
- (BOOL)formatJson
{
    if (!_createModel) {
        _createModel = [[CreateModel alloc]init];
    }
    BOOL formatFlag = [_createModel formatJson:_jsonDataTextView.string];
    if (formatFlag) {
        _jsonDataTextView.string = _createModel.formatJson;
        _json = _createModel.json;
    }else{
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"格式化失败！";
        alert.informativeText = [NSString stringWithFormat:@"%@ %@",@"json数据不合法",_createModel.errorMsg];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return NO;
        
    }
    return YES;
    
}
- (IBAction)generateFileAction:(id)sender {
    
    BOOL formatFlag = [self formatJson];
    if (!formatFlag) {
        return;
    }
    _createModel.className = _classNameFiled.stringValue;
    BOOL result = [_createModel createModelWithJson:_json allowMuti:_checkAllowBox.state];
    if (result) {
        _headFileView.string = _createModel.headerString;
        _sourceFileView.string = _createModel.sourceString;
    }else{
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"转换失败！";
        alert.informativeText = @"json数据不合法";
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return;
    }
    
    BOOL sc = [_createModel generateFileAllowMuti:_checkAllowBox.state];
    if (sc) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"文件生成成功！";
        alert.informativeText = @"查看文件目录？";
        [alert addButtonWithTitle:@"确定"];
        [alert addButtonWithTitle:@"取消"];
        
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            if(returnCode == NSAlertFirstButtonReturn)
            {
                [self openFolerAction:nil];
            }
        }];
        
    }else{
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"生成文件失败！";
        alert.informativeText = @"生成文件失败！文件目录可能不存在？";
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        
    }
}

- (IBAction)openFolerAction:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths[0] stringByAppendingPathComponent:@"ClassFiles"];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL dir = NO;
    BOOL exis = [fm fileExistsAtPath:path isDirectory:&dir];
    if (!exis && !dir)
    {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"目录不存在！";
        alert.informativeText = @"目录不存在！请先生成文件";
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        
    }
    
    [[NSWorkspace sharedWorkspace]selectFile:nil inFileViewerRootedAtPath:path];
}

/*//打开文件夹
- (void)openFolderWithAppleScriptBecauseTheSandboxIsTerrible:(NSString *)path
{
    FSRef ref;
    bzero(&ref,sizeof(ref));
    if(FSPathMakeRef((UInt8 *)[path fileSystemRepresentation],&ref,NULL)!=noErr) return;
    
    static const OSType signature='MACS';
    AppleEvent event={typeNull,nil};
    AEBuildError builderror;
    
    AEDesc filedesc;
    AEInitializeDesc(&filedesc);
    if(AECoercePtr(typeFSRef,&ref,sizeof(ref),typeAlias,&filedesc)!=noErr) return;
    
    if(AEBuildAppleEvent(
                         kCoreEventClass,kAEOpenDocuments,
                         typeApplSignature,&signature,sizeof(OSType),
                         kAutoGenerateReturnID,kAnyTransactionID,
                         &event,&builderror,
                         "'----':(@)",&filedesc)!=noErr) return;
    
    AEDisposeDesc(&filedesc);
    
    AppleEvent reply={typeNull,nil};
    
    AESendMessage(&event,&reply,kAENoReply,kAEDefaultTimeout);
    
    AEDisposeDesc(&reply);
    AEDisposeDesc(&event);
    
    NSArray *apps=[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.finder"];
    [[apps objectAtIndex:0] activateWithOptions:0];
}*/


@end
