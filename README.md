# social_share

A new flutter plugin project.

## Introduction

This plugin is only for IOS yet!
It provides you with most of the popular sharing options
With this plugin you can share on instagram stories and facebook stories and also copy to clipboard

## Usage

# Add this to your `Info.plist`

```
<key>LSApplicationQueriesSchemes</key>
	<array>
	<string>instagram-stories</string>
	<string>facebook-stories</string>
	<string>facebook</string>
	<string>instagram</string>
	</array>
```

# shareInstagramStory

```
SocialShare.shareInstagramStory(imageFile.path, "#ffffff",
                              "#000000", "https://deep-link-url")
```

# shareFacebookStory

```
SocialShare.shareFacebookStory(image.path,"#ffffff","#000000",
                              "https://deep-link-url","facebook-app-id")
```

# copyToClipboard

```
SocialShare.copyToClipboard("This is Social Share plugin",)
```

## InProgress

# share on slack

# share on twitter

# share on whatsapp

# share on telegram

# share on sms

# more options for share
