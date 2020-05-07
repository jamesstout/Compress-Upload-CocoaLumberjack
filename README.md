# Compress-Upload-CocoaLumberjack

A mashup of the example [CompressingLogFileManager](https://github.com/CocoaLumberjack/CocoaLumberjack/tree/master/Demos/LogFileCompressor) in [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) and [BackgroundUpload-CocoaLumberjack](https://github.com/pushd/BackgroundUpload-CocoaLumberjack).

When the log file is rolled/archived, it's compressed, then uploaded to an HTTP server, and finally deleted.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

A Web server endpoint capable of accepting `.gz` files.

## Installation

Compress-Upload-CocoaLumberjack is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Compress-Upload-CocoaLumberjack'
```

## Author

jamesstout, stoutyhk@gmail.com

### Inspiration
And a load of the code from [BackgroundUpload-CocoaLumberjack](https://github.com/pushd/BackgroundUpload-CocoaLumberjack).

## License

Compress-Upload-CocoaLumberjack is available under the MIT license. See the LICENSE file for more info.
