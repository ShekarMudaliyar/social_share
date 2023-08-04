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

        NSString *destination;
        NSString *stories;
        if ([@"shareInstagramStory" isEqualToString:call.method]) {
            destination = @"com.instagram.sharedSticker";
            stories = @"instagram-stories";
        } else {
            destination = @"com.facebook.sharedSticker";
            stories = @"facebook-stories";
        }

        NSString *stickerImage = call.arguments[@"stickerImage"];
        NSString *backgroundTopColor = call.arguments[@"backgroundTopColor"];
        NSString *backgroundBottomColor = call.arguments[@"backgroundBottomColor"];
        NSString *attributionURL = call.arguments[@"attributionURL"];
        NSString *backgroundImage = call.arguments[@"backgroundImage"];
        NSString *backgroundVideo = call.arguments[@"backgroundVideo"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];

        NSString *appId = call.arguments[@"appId"];
        if ([backgroundTopColor isKindOfClass:[NSNull class]]) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
            appId = [dict objectForKey:@"FacebookAppID"];
        }
        
        NSData *imgShare;
        if ( [fileManager fileExistsAtPath: stickerImage]) {
           imgShare = [[NSData alloc] initWithContentsOfFile:stickerImage];
        }
        
        // Assign background image asset and attribution link URL to pasteboard
        NSMutableDictionary *pasteboardItems = [[NSMutableDictionary alloc]initWithDictionary: @{[NSString stringWithFormat:@"%@.stickerImage",destination] : imgShare}];
        
        if (![backgroundTopColor isKindOfClass:[NSNull class]]) {
            [pasteboardItems setObject:backgroundTopColor forKey:[NSString stringWithFormat:@"%@.backgroundTopColor",destination]];
        }
        
        if (![backgroundBottomColor isKindOfClass:[NSNull class]]) {
            [pasteboardItems setObject:backgroundBottomColor forKey:[NSString stringWithFormat:@"%@.backgroundBottomColor",destination]];
        }
        
        if (![attributionURL isKindOfClass:[NSNull class]]) {
            [pasteboardItems setObject:attributionURL forKey:[NSString stringWithFormat:@"%@.contentURL",destination]];
        }
        
        if (![appId isKindOfClass:[NSNull class]] && [@"shareFacebookStory" isEqualToString:call.method]) {
            [pasteboardItems setObject:appId forKey:[NSString stringWithFormat:@"%@.appID",destination]];
        }
        
        //if you have a background image
        NSData *imgBackgroundShare;
        if ([fileManager fileExistsAtPath: backgroundImage]) {
            imgBackgroundShare = [[NSData alloc] initWithContentsOfFile:backgroundImage];
            [pasteboardItems setObject:imgBackgroundShare forKey:[NSString stringWithFormat:@"%@.backgroundImage",destination]];
        }
        //if you have a background video
        NSData *videoBackgroundShare;
        if ([fileManager fileExistsAtPath: backgroundVideo]) {
            videoBackgroundShare = [[NSData alloc] initWithContentsOfFile:backgroundVideo options:NSDataReadingMappedIfSafe error:nil];
            [pasteboardItems setObject:videoBackgroundShare forKey:[NSString stringWithFormat:@"%@.backgroundVideo",destination]];
        }

        NSURL *urlScheme = [NSURL URLWithString:[NSString stringWithFormat:@"%@://share?source_application=%@", stories,appId]];
        
        if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {

            if (@available(iOS 10.0, *)) {
            NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
            // This call is iOS 10+, can use 'setItems' depending on what versions you support
            [[UIPasteboard generalPasteboard] setItems:@[pasteboardItems] options:pasteboardOptions];

            [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
              result(@"success");
            } else {
                result(@"error");
            }
        } else {
            result(@"error");
        }
    }
    else if ([@"copyToClipboard" isEqualToString:call.method]) {
        
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
            NSArray *objectsToShare = @[imgShare];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            UIViewController *controller =[UIApplication sharedApplication].keyWindow.rootViewController;
            [controller presentViewController:activityVC animated:YES completion:nil];
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
