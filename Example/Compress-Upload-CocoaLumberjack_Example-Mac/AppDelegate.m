//
//  AppDelegate.m
//  Compress-Upload-CocoaLumberjack_Example-Mac
//
//  Created by James on 13/12/2020.
//  Copyright © 2020 jamesstout. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()


@end

const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@implementation AppDelegate

@synthesize fileLogger, logFileManager;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.example.com/logFile.php"]];
    [request setHTTPMethod:@"POST"];

    logFileManager = [[CompressingAndUploadingLogFileManager alloc] initWithUploadRequest:request];

    logFileManager.doUpload = YES;

    fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];

    // set to 1 min and 1kB so they roll quickly
    fileLogger.maximumFileSize  = 1024 * 100;  // 1 KB
    fileLogger.rollingFrequency =   60 * 1;  // 1 Minute

    fileLogger.logFileManager.maximumNumberOfLogFiles = 4;



    [DDLog addLogger:[DDOSLogger sharedInstance]];
    [DDLog addLogger:fileLogger];

    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(writeLogMessages:)
                                   userInfo:nil
                                    repeats:YES];



}

- (void)writeLogMessages:(NSTimer *)aTimer
{
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");
    DDLogVerbose(@"I like cheese");

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
