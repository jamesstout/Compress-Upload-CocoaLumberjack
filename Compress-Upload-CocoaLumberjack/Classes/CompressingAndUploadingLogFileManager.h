//
//  CompressingAndUploadingLogFileManager.h
//  LogFileCompressor
//
//  CocoaLumberjack Demos
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

/**
 Optional delegate to notify about uploads
 */
@protocol JCSBackgroundUploadLogFileManagerDelegate <NSObject>
@optional

/**
 called for each retry
 */
- (void)attemptingUploadForFilePath:(NSString *)logFilePath;

/**
 called once upon final success or failure
 */
- (void)uploadTaskForFilePath:(NSString *)logFilePath didCompleteWithError:(NSError *)error;

@end


@interface CompressingAndUploadingLogFileManager : DDLogFileManagerDefault<NSURLSessionDelegate,NSURLSessionTaskDelegate>
{
    BOOL upToDate;
    BOOL isCompressing;
}

@property (assign, nonatomic) BOOL doUpload;

- (id)initWithLogsDirectory:(NSString *)aLogsDirectory andUploadRequest:(NSURLRequest *)uploadRequest;
- (id)initWithUploadRequest:(NSURLRequest *)uploadRequest;

/**
 identifier to test before delegating call to application:handleEventsForBackgroundURLSession:completionHandler: method from your application delegate to handleEventsForBackgroundURLSession:
 */
- (NSString *)sessionIdentifier;

/**
 you must delegate calls to your application delegate's application:handleEventsForBackgroundURLSession:completionHandler: method to this if sessionIdentifier matches
 */
- (void)handleEventsForBackgroundURLSession:(void (^)(void))completionHandler;

@end
