//
//  ViewController.m
//  DAT_Decoder
//
//  Created by Ralph007 on 16/9/12.
//  Copyright © 2016年 Ralph007. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()

@property (weak) IBOutlet NSTextField *input;
@property (weak) IBOutlet NSTextField *lable;
@property IBOutlet NSTextView *output;
@property (assign) BOOL isNeedFilter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

-(IBAction)openFile:(id)sender{
    NSOpenPanel *openDlg=[NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setTreatsFilePackagesAsDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    
    __weak ViewController* weakSelf = self;
    [openDlg beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        __strong ViewController* strongSelf = weakSelf;
        if (result == NSModalResponseOK) {
            for( NSURL* url in openDlg.URLs ){
                NSString* filePath = url.path;
                strongSelf.lable.stringValue = filePath;
                strongSelf.input.stringValue = filePath;
                break;
            }
        }
    }];
}

-(IBAction)fileterOutput:(NSButton*)sender{
    self.isNeedFilter = sender.state;
    [self filterString:self.output.string];
}

-(void)filterString:(NSString*)input{
    if (self.isNeedFilter && input.length>0) {
        self.output.string = [input stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        self.output.string = [self.output.string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        self.output.string = [self.output.string stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
}

-(IBAction)decodeFile:(id)sender{
    self.output.string = @"";
    NSData *data = [NSData dataWithContentsOfFile:self.input.stringValue];
    NSString *jsonStr = [[NSString alloc] initWithData:[self transform:data] encoding:NSUTF8StringEncoding];
    
    if (jsonStr.length > 0) {
        self.output.string = jsonStr;
        [self filterString:self.output.string];
    }
}

-(NSData *)transform:(NSData *)dataIn
{
    if (dataIn.length == 0) return dataIn;
    NSMutableData *dataOut = [NSMutableData data];
    char byte;
    static char key[] = {0x7a,0x72,0x79,0x7a,0x72,0x73,0x79,0x6a,0x73,0x79,0x73,0x7a,0x63,0x68,0x6c,0x6d,0x74,0x6c,0x78,0x78,0x66};
    int len = sizeof(key)/sizeof(key[0]);
    for(int n = 0; n < dataIn.length; ++n )
    {
        [dataIn getBytes:&byte range:NSMakeRange(n, 1)];
        byte ^= key[n%len];
        [dataOut appendBytes:&byte length:1];
    }
    return [dataOut copy];
}

-(void)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pb = [sender draggingPasteboard];
    
    if ( [pb.types containsObject:NSFilenamesPboardType] )
    {
        NSArray *filenames = [pb propertyListForType:NSFilenamesPboardType];
        NSInteger count = filenames.count;
        if (count > 0)
        {
            if (filenames.count == 1)
            {
                NSString *strPath = filenames[0];
                BOOL isDir;
                if ([[NSFileManager defaultManager] fileExistsAtPath:strPath isDirectory:&isDir])
                {
                    if (!isDir)
                    {
                        self.lable.stringValue = strPath.stringByDeletingLastPathComponent;
                    }
                }
            }
        }
    }
}

@end
