# social_share

Flutter plugin to share images on social media. Such as sharing on Instagram, Facebook story ,Twitter, Sms and other popular sharing options.

## This plugin is iOS only Android is still in progress

## Introduction

This plugin is only for iOS yet!
It provides you with most of the popular sharing options
With this plugin you can share on instagram stories and facebook stories and also copy to clipboard

## Usage

#### Add this to your `Info.plist` to use share on instagram and facebook story

```
<key>LSApplicationQueriesSchemes</key>
	<array>
	<string>instagram-stories</string>
	<string>facebook-stories</string>
	<string>facebook</string>
	<string>instagram</string>
	</array>
```

### Add this if you are using share on facebook. For this you have to create an app on https://developers.facebook.com/ and get the App ID

```
<key>FacebookAppID</key>
<string>xxxxxxxxxxxxxxx</string>
```

#### shareInstagramStory

```
SocialShare.shareInstagramStory(imageFile.path, "#ffffff",
                              "#000000", "https://deep-link-url");
```

#### shareInstagramStorywithBackground

```
 SocialShare.shareInstagramStorywithBackground(image.path, "https://deep-link-url",
                              backgroundImagePath: backgroundimage.path);
```

#### shareFacebookStory

```
SocialShare.shareFacebookStory(image.path,"#ffffff","#000000",
                              "https://deep-link-url","facebook-app-id");
```

#### copyToClipboard

```
SocialShare.copyToClipboard("This is Social Share plugin");
```

#### shareTwitter

```
//without hashtags
SocialShare.shareTwitter("This is Social Share plugin");

//with hashtags
SocialShare.shareTwitter(
                              "This is Social Share twitter example",
                              hashtags: ["hello", "world", "foo", "bar"]);
```

#### shareSms

```
//without url link in message
SocialShare.shareSms("This is Social Share Sms example");

//with url link in message
SocialShare.shareSms("This is Social Share Sms example",url: "https://micro.volvmedia.com/");
```

#### shareOptions

```
SocialShare.shareOptions(image.path, "Hello world");
```

## InProgress

- share on slack
- share on whatsapp
- share on telegram
- more options for share
