# social_share

Wide variety of sharing options you'll need to share directly to certain apps. This plugin includes share to Instagram-story, Facebook-story, Twitter, Sms, Copy to clipboard , and default option to share.

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
	<string>twitter</string>
	<string>whatsapp</string>
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

### shareWhatsapp

```
SocialShare.shareWhatsapp("Hello World");
```

#### shareOptions

This will open the default native share options

```
//without an image
SocialShare.shareOptions("Hello world");

//with an image
SocialShare.shareOptions("Hello world",imagePath: image.path);
```
