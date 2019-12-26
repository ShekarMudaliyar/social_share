import 'package:flutter/material.dart';
import 'dart:async';
import 'package:screenshot/screenshot.dart';
import 'package:social_share/social_share.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Screenshot(
          controller: screenshotController,
          child: Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Running on: $_platformVersion\n',
                  textAlign: TextAlign.center,
                ),
                RaisedButton(
                  onPressed: () async {
                    await screenshotController.capture().then((image) async {
                      SocialShare.shareInstagramStory(image.path, "#ffffff",
                              "#000000", "https://deep-link-url")
                          .then((data) {
                        print(data);
                      });
                    });
                  },
                  child: Text("Share On Instagram Story"),
                ),
                RaisedButton(
                  onPressed: () async {
                    await screenshotController.capture().then((image) async {
                      SocialShare.shareInstagramStorywithBackground(image.path,
                              "#ffffff", "#000000", "https://deep-link-url",
                              backgroundImagePath: image.path)
                          .then((data) {
                        print(data);
                      });
                    });
                  },
                  child: Text("Share On Instagram Story with background"),
                ),
                RaisedButton(
                  onPressed: () async {
                    await screenshotController.capture().then((image) async {
                      SocialShare.shareFacebookStory(image.path, "#ffffff",
                              "#000000", "https://google.com")
                          .then((data) {
                        print(data);
                      });
                    });
                  },
                  child: Text("Share On Facebook Story"),
                ),
                RaisedButton(
                  onPressed: () async {
                    SocialShare.copyToClipboard(
                      "This is Social Share plugin",
                    ).then((data) {
                      print(data);
                    });
                  },
                  child: Text("Copy to clipboard"),
                ),
                RaisedButton(
                  onPressed: () async {
                    SocialShare.shareTwitter(
                            "This is Social Share twitter example",
                            hashtags: ["hello", "world", "foo", "bar"],
                            url: "https://micro.volvmedia.com/#/story/222")
                        .then((data) {
                      print(data);
                    });
                  },
                  child: Text("Share on twitter"),
                ),
                RaisedButton(
                  onPressed: () async {
                    SocialShare.shareSms("This is Social Share Sms example",
                            url: "https://google.com/")
                        .then((data) {
                      print(data);
                    });
                  },
                  child: Text("Share on Sms"),
                ),
                RaisedButton(
                  onPressed: () async {
                    await screenshotController.capture().then((image) async {
                      SocialShare.shareOptions("Hello world",
                              imagePath: image.path)
                          .then((data) {
                        print(data);
                      });
                    });
                  },
                  child: Text("Share Options"),
                ),
                RaisedButton(
                  onPressed: () async {
                    await screenshotController.capture().then((image) async {
                      SocialShare.shareWhatsapp("Hello World").then((data) {
                        print(data);
                      });
                    });
                  },
                  child: Text("Share on Whatsapp"),
                ),
                RaisedButton(
                  onPressed: () async {
                    await screenshotController.capture().then((image) async {
                      SocialShare.checkInstalledAppsForShare().then((data) {
                        print(data.toString());
                      });
                    });
                  },
                  child: Text("Get all Apps"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
