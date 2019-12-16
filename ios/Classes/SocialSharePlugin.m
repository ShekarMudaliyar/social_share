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
    if([@"shareInstagramStory" isEqualToString:call.method]){
      NSString *stickerImage = call.arguments[@"stickerImage"];
      NSString *backgroundTopColor = call.arguments[@"backgroundTopColor"];
      NSString *backgroundBottomColor = call.arguments[@"backgroundBottomColor"];
      NSString *attributionURL = call.arguments[@"attributionURL"];

      NSFileManager *fileManager = [NSFileManager defaultManager];
      BOOL isFileExist = [fileManager fileExistsAtPath: stickerImage];
      UIImage *imgShare;
      if (isFileExist) {
          imgShare = [[UIImage alloc] initWithContentsOfFile:stickerImage];
      }
      NSURL *urlScheme = [NSURL URLWithString:@"instagram-stories://share"];
       if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {

             // Assign background image asset and attribution link URL to pasteboard
             NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.stickerImage" : imgShare,
                                            @"com.instagram.sharedSticker.backgroundTopColor" : backgroundTopColor,
                                            @"com.instagram.sharedSticker.backgroundBottomColor" : backgroundBottomColor,
                                            @"com.instagram.sharedSticker.contentURL" : attributionURL
             }];
             if (@available(iOS 10.0, *)) {
             NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
             // This call is iOS 10+, can use 'setItems' depending on what versions you support
             [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
                 
               [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
                 result(@"sharing");
           } else {
               result(@"this only supports iOS 10+");
           }
       } else {
           result(@"not supported or no facebook installed");
       }
  }else if([@"shareFacebookStory" isEqualToString:call.method]){
      NSString *stickerImage = call.arguments[@"stickerImage"];
      NSString *backgroundTopColor = call.arguments[@"backgroundTopColor"];
      NSString *backgroundBottomColor = call.arguments[@"backgroundBottomColor"];
      NSString *attributionURL = call.arguments[@"attributionURL"];
      NSString *appID = call.arguments[@"appID"];

           NSFileManager *fileManager = [NSFileManager defaultManager];
           BOOL isFileExist = [fileManager fileExistsAtPath: stickerImage];
           UIImage *imgShare;
           if (isFileExist) {
               imgShare = [[UIImage alloc] initWithContentsOfFile:stickerImage];
           }
           NSURL *urlScheme = [NSURL URLWithString:@"facebook-stories://share"];
            if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {

                  // Assign background image asset and attribution link URL to pasteboard
                 NSArray *pasteboardItems = @[@{@"com.facebook.sharedSticker.stickerImage" : imgShare,
                                                @"com.facebook.sharedSticker.backgroundTopColor" : backgroundTopColor,
                                                @"com.facebook.sharedSticker.backgroundBottomColor" : backgroundBottomColor,
                                                @"com.facebook.sharedSticker.contentURL" : attributionURL,
                                                @"com.facebook.sharedSticker.appID" : appID}];
                  if (@available(iOS 10.0, *)) {
                  NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
                  // This call is iOS 10+, can use 'setItems' depending on what versions you support
                  [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
                      
                    [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
                      result(@"sharing");
                } else {
                    result(@"this only supports iOS 10+");
                }
            } else {
                result(@"not supported or no facebook installed");
            }
  }else if([@"copyToClipboard" isEqualToString:call.method]){
      NSString *content = call.arguments[@"content"];
      UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
      pasteboard.string = content;
      result([NSNumber numberWithBool:YES]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
