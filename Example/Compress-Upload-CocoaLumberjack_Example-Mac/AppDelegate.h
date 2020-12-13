//
//  AppDelegate.h
//  Compress-Upload-CocoaLumberjack_Example-Mac
//
//  Created by James on 13/12/2020.
//  Copyright © 2020 jamesstout. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <Compress-Upload-CocoaLumberjack/CompressingAndUploadingLogFileManager.h>

extern const DDLogLevel ddLogLevel;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) DDFileLogger *fileLogger;
@property (strong, nonatomic) CompressingAndUploadingLogFileManager *logFileManager;

- (void)writeLogMessages:(NSTimer *)aTimer;

@end

