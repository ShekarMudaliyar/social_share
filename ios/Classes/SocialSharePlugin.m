//
//  Created by Shekar Mudaliyar on 12/12/19.
//  Copyright © 2019 Shekar Mudaliyar. All rights reserved.
//


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
        NSString *backgroundImage = call.arguments[@"backgroundImage"];

      NSFileManager *fileManager = [NSFileManager defaultManager];
      BOOL isFileExist = [fileManager fileExistsAtPath: stickerImage];
      UIImage *imgShare;
      if (isFileExist) {
          imgShare = [[UIImage alloc] initWithContentsOfFile:stickerImage];
      }
      NSURL *urlScheme = [NSURL URLWithString:@"instagram-stories://share"];
        
       if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
           if ( [ backgroundImage  length] == 0 ){
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
           
       }else{
           NSFileManager *fileManager = [NSFileManager defaultManager];
           BOOL isFileExist = [fileManager fileExistsAtPath: backgroundImage];
           UIImage *imgBackgroundShare;
           if (isFileExist) {
               imgBackgroundShare = [[UIImage alloc] initWithContentsOfFile:backgroundImage];
           }
               NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.backgroundImage" : imgBackgroundShare,
                                                @"com.instagram.sharedSticker.stickerImage" : imgShare,
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
           }
       } else {
           result(@"not supported or no facebook installed");
       }
  }else if([@"shareFacebookStory" isEqualToString:call.method]){
      NSString *stickerImage = call.arguments[@"stickerImage"];
      NSString *backgroundTopColor = call.arguments[@"backgroundTopColor"];
      NSString *backgroundBottomColor = call.arguments[@"backgroundBottomColor"];
      NSString *attributionURL = call.arguments[@"attributionURL"];
      NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
      NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
      NSString *appID = [dict objectForKey:@"FacebookAppID"];
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
  }else if([@"shareTwitter" isEqualToString:call.method]){
//      NSString *assetImage = call.arguments[@"assetImage"];
      NSString *captionText = call.arguments[@"captionText"];
      
      NSString *urlSchemeTwitter = [NSString stringWithFormat:@"twitter://post?message=%@",captionText];
      NSURL *urlScheme = [NSURL URLWithString:urlSchemeTwitter];
      if (@available(iOS 10.0, *)) {
          [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
          result(@"sharing");
      } else {
          result(@"this only supports iOS 10+");
      }

  }else if([@"shareSms" isEqualToString:call.method]){
        NSString *msg = call.arguments[@"message"];
        NSString *urlstring = call.arguments[@"urlLink"];
        NSString* urlTextEscaped = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString: urlTextEscaped];
        if ( [ [url absoluteString]  length] == 0 ){
        NSString *urlSchemeSms = [NSString stringWithFormat:@"sms:?&body=%@",msg];
        NSURL *urlScheme = [NSURL URLWithString:urlSchemeSms];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
            result(@"sharing");
        } else {
            result(@"this only supports iOS 10+");
        }
    }else{
        NSString *urlSchemeSms = [NSString stringWithFormat:@"sms:?&body=%@",msg];
        NSString *urlWithLink = [urlSchemeSms stringByAppendingString:[url absoluteString]];
               NSURL *urlScheme = [NSURL URLWithString:urlWithLink];
               if (@available(iOS 10.0, *)) {
                   [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
                   result(@"sharing");
               } else {
                   result(@"this only supports iOS 10+");
               }
    }
      }else if([@"shareSlack" isEqualToString:call.method]){
      //      NSString *content = call.arguments[@"content"];
           
            result([NSNumber numberWithBool:YES]);
        }else if([@"shareWhatsapp" isEqualToString:call.method]){
        //      NSString *content = call.arguments[@"content"];
             
              result([NSNumber numberWithBool:YES]);
          }else if([@"shareTelegram" isEqualToString:call.method]){
          //      NSString *content = call.arguments[@"content"];
               
                result([NSNumber numberWithBool:YES]);
            }
          else if([@"shareOptions" isEqualToString:call.method]){
            NSString *content = call.arguments[@"content"];
              NSString *image = call.arguments[@"image"];
              NSFileManager *fileManager = [NSFileManager defaultManager];
                        BOOL isFileExist = [fileManager fileExistsAtPath: image];
                        UIImage *imgShare;
                        if (isFileExist) {
                            imgShare = [[UIImage alloc] initWithContentsOfFile:image];
                        }
               NSArray *objectsToShare = @[content, imgShare];
               UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
              UIViewController *controller =[UIApplication sharedApplication].keyWindow.rootViewController;
               [controller presentViewController:activityVC animated:YES completion:nil];
                result([NSNumber numberWithBool:YES]);
            }else {
    result(FlutterMethodNotImplemented);
  }
}

@end
