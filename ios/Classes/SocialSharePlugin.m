//
//  Created by Shekar Mudaliyar on 12/12/19.
//  Copyright © 2019 Shekar Mudaliyar. All rights reserved.
//

#import "SocialSharePlugin.h"
#include <objc/runtime.h>

@implementation SocialSharePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"social_share" binaryMessenger:[registrar messenger]];
  SocialSharePlugin* instance = [[SocialSharePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"shareInstagramStory" isEqualToString:call.method] || [@"shareFacebookStory" isEqualToString:call.method]) {

        NSString *appID = call.arguments[@"appId"];

        // Updated to reflect that Docs on Facebook/Instagram now show a different url scheme vs instagram, i.e FB does no longer take source_application queryParam
        // FB Docs: https://developers.facebook.com/docs/sharing/sharing-to-stories/ios-developers
        // Insta Docs: https://developers.facebook.com/docs/instagram/sharing-to-stories 
        NSString *destination;
        NSURL *urlScheme;
        if ([@"shareInstagramStory" isEqualToString:call.method]) {
            destination = @"com.instagram.sharedSticker";
            urlScheme = [NSURL URLWithString:[NSString stringWithFormat:@"instagram-stories://share?source_application=%@", appID]]; 
        } else {
            destination = @"com.facebook.sharedSticker";
            urlScheme = [NSURL URLWithString:@"facebook-stories://share"];
        }

        NSString *stickerImagePath = call.arguments[@"stickerImagePath"];
        NSString *backgroundTopColor = call.arguments[@"backgroundTopColor"];
        NSString *backgroundBottomColor = call.arguments[@"backgroundBottomColor"];
        NSString *attributionURL = call.arguments[@"attributionURL"];
        NSString *backgroundImagePath = call.arguments[@"backgroundImagePath"];
        NSString *backgroundVideoPath = call.arguments[@"backgroundVideoPath"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSMutableDictionary *pasteboardItemsDictionary = [[NSMutableDictionary alloc]initWithDictionary: @{}];

         // if you have a sticker image path then get sticker image file and add it to the pastboard items
        NSData *stickerImage;
        if (![stickerImagePath isKindOfClass:[NSNull class]] && [fileManager fileExistsAtPath: stickerImagePath]) {
            stickerImage = [[NSData alloc] initWithContentsOfFile:stickerImagePath];
            [pasteboardItemsDictionary setObject:stickerImage forKey:[NSString stringWithFormat:@"%@.stickerImage", destination]];
        }

        // if you have a background image path then get background image file and add it to the pastboard items
        NSData *backgroundImage;
        if (![backgroundImagePath isKindOfClass:[NSNull class]] && [fileManager fileExistsAtPath: backgroundImagePath]) {
            backgroundImage = [[NSData alloc] initWithContentsOfFile:backgroundImagePath];
            [pasteboardItemsDictionary setObject:backgroundImage forKey:[NSString stringWithFormat:@"%@.backgroundImage", destination]];
        }
        // if you have a background video path then get background video file and add it to the pastboard items
        NSData *backgroundVideo;
        if (![backgroundVideoPath isKindOfClass:[NSNull class]] && [fileManager fileExistsAtPath: backgroundVideoPath]) {
            backgroundVideo = [[NSData alloc] initWithContentsOfFile:backgroundVideoPath options:NSDataReadingMappedIfSafe error:nil];
            [pasteboardItemsDictionary setObject:backgroundVideo forKey:[NSString stringWithFormat:@"%@.backgroundVideo", destination]];
        }
        
        // if you have a background top color and add it to the pastboard items
        if (![backgroundTopColor isKindOfClass:[NSNull class]]) {
            [pasteboardItemsDictionary setObject:backgroundTopColor forKey:[NSString stringWithFormat:@"%@.backgroundTopColor", destination]];
        }
        
        // if you have a background bottom color and add it to the pastboard items
        if (![backgroundBottomColor isKindOfClass:[NSNull class]]) {
            [pasteboardItemsDictionary setObject:backgroundBottomColor forKey:[NSString stringWithFormat:@"%@.backgroundBottomColor", destination]];
        }
        
        // if you have an attribution url and add it to the pastboard items
        if (![attributionURL isKindOfClass:[NSNull class]]) {
            [pasteboardItemsDictionary setObject:attributionURL forKey:[NSString stringWithFormat:@"%@.contentURL", destination]];
        }

        // Facebook requires an additional appID key in the pasteboard items array. Not required for Instagram, because Instagram attaches it to the queryParam in the urlScheme
        if ([@"shareFacebookStory" isEqualToString:call.method]) {
            [pasteboardItemsDictionary setObject:appID forKey:[NSString stringWithFormat:@"%@.appID", destination]];
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {

        // Attach the pasteboard items based on platform
        NSArray *pasteboardItems = @[pasteboardItemsDictionary];
        
        NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
        // This call is iOS 10+, can use 'setItems' depending on what versions you support
        [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
    
        [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
        result(@"success");
        } else {
            result(@"error");
        }
} else if ([@"copyToClipboard" isEqualToString:call.method]) {
        
        NSString *content = call.arguments[@"content"];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        //assigning content to pasteboard
         if (![content isKindOfClass:[NSNull class]]) {
            pasteboard.string = content;
        }
        //assigning image to pasteboard
        NSString *image = call.arguments[@"image"];
        UIImage *imageData;
        if ([[NSFileManager defaultManager] fileExistsAtPath: image]) {
            imageData = [[UIImage alloc] initWithContentsOfFile:image];
            pasteboard.image = imageData;
        }
        
        result(@"success");
        
    } else if ([@"shareTwitter" isEqualToString:call.method]) {
        NSString *captionText = call.arguments[@"captionText"];
        
        NSString *urlSchemeTwitter = [NSString stringWithFormat:@"twitter://post?message=%@",captionText];
        NSString* urlTextEscaped = [urlSchemeTwitter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *urlSchemeSend = [NSURL URLWithString:urlTextEscaped];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:urlSchemeSend options:@{} completionHandler:nil];
            result(@"success");
        } else {
            result(@"error");
        }
    
    } else if ([@"shareSms" isEqualToString:call.method]) {
        NSString *msg = call.arguments[@"message"];
        NSString *urlstring = call.arguments[@"urlLink"];
        NSString *trailingText = call.arguments[@"trailingText"];

        NSURL *urlScheme = [NSURL URLWithString:@"sms://"];

        NSString* urlTextEscaped = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString: urlTextEscaped];
        //check if it contains a link
        if ( [ [url absoluteString]  length] == 0 ) {
            //if it doesn't contains a link
            NSString *urlSchemeSms = [NSString stringWithFormat:@"sms:?&body=%@",msg];
            NSURL *urlScheme = [NSURL URLWithString:urlSchemeSms];
            if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
                    result(@"success");
                } else {
                    result(@"error");
                }
            } else {
                result(@"error");
            }
        } else {
            //if it does contains a link
            //check if trailing text equals null
            if ( [ trailingText   length] == 0 ) {
                //if trailing text is null
                //url scheme with normal text message
                NSString *urlSchemeSms = [NSString stringWithFormat:@"sms:?&body=%@",msg];
                //appending url with normal text and url scheme
                NSString *urlWithLink = [urlSchemeSms stringByAppendingString:[url absoluteString]];
                //final urlscheme
                NSURL *urlSchemeMsg = [NSURL URLWithString:urlWithLink];
                if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:urlSchemeMsg options:@{} completionHandler:nil];
                        result(@"success");
                    } else {
                        result(@"error");
                    }
                } else {
                    result(@"error");
                }
            } else {
                //if trailing text is not null
                NSString *urlSchemeSms = [NSString stringWithFormat:@"sms:?&body=%@",msg];
                //appending url with normal text and url scheme
                NSString *urlWithLink = [urlSchemeSms stringByAppendingString:[url absoluteString]];
                NSString *finalUrl = [urlWithLink stringByAppendingString:trailingText];

                //final urlscheme
                NSURL *urlSchemeMsg = [NSURL URLWithString:finalUrl];
                if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:urlSchemeMsg options:@{} completionHandler:nil];
                        result(@"success");
                    } else {
                        result(@"error");
                    }
                } else {
                    result(@"error");

                }
            }
        
        }
    } else if ([@"shareSlack" isEqualToString:call.method]) {
        //NSString *content = call.arguments[@"content"];
        result([NSNumber numberWithBool:YES]);
    } else if ([@"shareWhatsapp" isEqualToString:call.method]) {
        NSString *content = call.arguments[@"content"];
        NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",content];
        NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
            [[UIApplication sharedApplication] openURL: whatsappURL];
            result(@"success");
        } else {
            result(@"error");
        }
        result([NSNumber numberWithBool:YES]);
    } else if ([@"shareTelegram" isEqualToString:call.method]) {
        NSString *content = call.arguments[@"content"];
        NSString * urlScheme = [NSString stringWithFormat:@"tg://msg?text=%@",content];
        NSURL * telegramURL = [NSURL URLWithString:[urlScheme stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if ([[UIApplication sharedApplication] canOpenURL: telegramURL]) {
            [[UIApplication sharedApplication] openURL: telegramURL];
            result(@"success");
        } else {
            result(@"error");
        }
        result([NSNumber numberWithBool:YES]);
    } else if ([@"shareOptions" isEqualToString:call.method]) {
        NSString *content = call.arguments[@"content"];
        NSString *image = call.arguments[@"image"];
        //checking if it contains image file
        if ([image isEqual:[NSNull null]] || [ image  length] == 0 ) {
            //when image is not included
            NSArray *objectsToShare = @[content];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            UIViewController *controller =[UIApplication sharedApplication].keyWindow.rootViewController;
            [controller presentViewController:activityVC animated:YES completion:nil];
            result([NSNumber numberWithBool:YES]);
        } else {
            //when image file is included
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
        }
    } else if ([@"checkInstalledApps" isEqualToString:call.method]) {
        NSMutableDictionary *installedApps = [[NSMutableDictionary alloc] init];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram-stories://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"instagram"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"instagram"];
        }

        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"facebook-stories://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"facebook"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"facebook"];
        }

        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"twitter"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"twitter"];
        }

        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"sms"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"sms"];
        }

        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"whatsapp://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"whatsapp"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"whatsapp"];
        }

        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tg://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"telegram"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"telegram"];
        }
        result(installedApps);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
