#
# Be sure to run `pod lib lint Compress-Upload-CocoaLumberjack.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Compress-Upload-CocoaLumberjack'
  s.version          = '0.1.1'
  s.summary          = 'Remote logging via NSURLSession transfer to upload compressed CocoaLumberjack logs to an HTTP server.'

  s.description      = <<-DESC
  A mashup of the example CompressingLogFileManager in CocoaLumberjack and 
  BackgroundUpload-CocoaLumberjack: https://github.com/pushd/BackgroundUpload-CocoaLumberjack.
  When the log file is rolled/archived, it's compressed, then uploaded to an HTTP server, and finally deleted.
                       DESC

  s.homepage         = 'https://github.com/jamesstout/Compress-Upload-CocoaLumberjack'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jamesstout' => 'stoutyhk@gmail.com' }
  s.source           = { :git => 'https://github.com/jamesstout/Compress-Upload-CocoaLumberjack.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/stoutyhk'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Compress-Upload-CocoaLumberjack/Classes/**/*'
  
  s.ios.deployment_target = '8.0'
  
  s.source_files = 'Compress-Upload-CocoaLumberjack/Classes/**/*'
  s.public_header_files = 'Compress-Upload-CocoaLumberjack/Classes/**/*.h'
  
  s.dependency 'CocoaLumberjack'
end
