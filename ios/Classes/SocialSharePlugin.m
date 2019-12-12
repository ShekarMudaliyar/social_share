#import "SocialSharePlugin.h"

@implementation SocialSharePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"social_share"
            binaryMessenger:[registrar messenger]];
  SocialSharePlugin* instance = [[SocialSharePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }else if([@"shareInstagramStory" isEqualToString:call.method]){
      NSString *stickerImage = call.arguments[@"stickerImage"];

      NSURL *myImgUrl = [NSURL URLWithString:stickerImage];
      NSData * imageData = [[NSData alloc] initWithContentsOfURL: myImgUrl];
      NSFileManager *fileManager = [NSFileManager defaultManager];
      BOOL isFileExist = [fileManager fileExistsAtPath: stickerImage];
      UIImage *imgShare;
      if (isFileExist) {
//           imgShare = [[UIImage alloc] initWithData:imageData];
          imgShare = [[UIImage alloc] initWithContentsOfFile:stickerImage];
      }
      NSURL *urlScheme = [NSURL URLWithString:@"instagram-stories://share"];
       if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {

             // Assign background image asset and attribution link URL to pasteboard
             NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.stickerImage" : imgShare}];
             if (@available(iOS 10.0, *)) {
             NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
             // This call is iOS 10+, can use 'setItems' depending on what versions you support
             [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
                 
               [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
                 result([NSNumber numberWithBool:YES]);
           } else {
result([NSNumber numberWithBool:NO]);
               
           }
       } else {
result([NSNumber numberWithBool:NO]);
           
       }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
