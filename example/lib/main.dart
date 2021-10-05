import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:social_share/social_share.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: _appBar(),
        body: _body(),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(title: const Text('Plugin example app'));
  }

  Widget _body() {
    return Screenshot(
      controller: screenshotController,
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _title(),
            _toInstagramStory(),
            _toInstagramStoryWithBackground(),
            _toFacebookStory(),
            _copyToClipboard(),
            _toTwitter(),
            _toSms(),
            _shareOptions(),
            _toWhatsapp(),
            _toTelegram(),
            _getAllApps(),
          ],
        ),
      ),
    );
  }

  Widget _getAllApps() {
    return ElevatedButton(
      onPressed: () async {
        SocialShare.checkInstalledAppsForShare().then((data) {
          print(data.toString());
        });
      },
      child: Text("Get all Apps"),
    );
  }

  Widget _toTelegram() {
    return ElevatedButton(
      onPressed: () async {
        SocialShare.shareTelegram(
          "Hello World \n https://google.com",
        ).then((data) {
          print(data);
        });
      },
      child: Text("Share on Telegram"),
    );
  }

  Widget _toWhatsapp() {
    return ElevatedButton(
      onPressed: () async {
        SocialShare.shareWhatsapp(
          "Hello World \n https://google.com",
        ).then((data) {
          print(data);
        });
      },
      child: Text("Share on Whatsapp"),
    );
  }

  Widget _shareOptions() {
    return ElevatedButton(
      onPressed: () async {
        await screenshotController.capture().then((image) async {
          SocialShare.shareOptions("Hello world").then((data) {
            print(data);
          });
        });
      },
      child: Text("Share Options"),
    );
  }

  Widget _toSms() {
    return ElevatedButton(
      onPressed: () async {
        SocialShare.shareSms(
          "This is Social Share Sms example",
          url: "\nhttps://google.com/",
          trailingText: "\nhello",
        ).then((data) {
          print(data);
        });
      },
      child: Text("Share on Sms"),
    );
  }

  Widget _toTwitter() {
    return ElevatedButton(
      onPressed: () async {
        SocialShare.shareTwitter(
          "This is Social Share twitter example",
          hashtags: ["hello", "world", "foo", "bar"],
          url: "https://google.com/#/hello",
          trailingText: "\nhello",
        ).then((data) {
          print(data);
        });
      },
      child: Text("Share on twitter"),
    );
  }

  Widget _copyToClipboard() {
    return ElevatedButton(
      onPressed: () async {
        SocialShare.copyToClipboard(
          "This is Social Share plugin",
        ).then((data) {
          print(data);
        });
      },
      child: Text("Copy to clipboard"),
    );
  }

  Widget _toFacebookStory() {
    return ElevatedButton(
      onPressed: () async {
        await getTemporaryDirectory()
            .then((directory) =>
                screenshotController.captureAndSave(directory.path))
            .then((image) async {
          //facebook appId is mandatory for andorid or else share won't work
          defaultTargetPlatform == TargetPlatform.android
              ? SocialShare.shareFacebookStory(
                  image!,
                  "#ffffff",
                  "#000000",
                  "https://google.com",
                  appId: "xxxxxxxxxxxxx",
                ).then((data) {
                  print(data);
                })
              : SocialShare.shareFacebookStory(
                  image!,
                  "#ffffff",
                  "#000000",
                  "https://google.com",
                ).then((data) {
                  print(data);
                });
        });
      },
      child: Text("Share On Facebook Story"),
    );
  }

  Widget _toInstagramStoryWithBackground() {
    return ElevatedButton(
      onPressed: () async {
        getTemporaryDirectory()
            .then((directory) =>
                screenshotController.captureAndSave(directory.path))
            .then((image) async {
          SocialShare.shareInstagramStory(
            image!,
            backgroundTopColor: "#ffffff",
            backgroundBottomColor: "#000000",
            attributionURL: "https://deep-link-url",
            backgroundImagePath: image,
          ).then((data) {
            print(data);
          });
        });
      },
      child: Text("Share On Instagram Story with background"),
    );
  }

  Widget _toInstagramStory() {
    return ElevatedButton(
      onPressed: () async {
        final file = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );
        SocialShare.shareInstagramStory(
          file!.path,
          backgroundTopColor: "#ffffff",
          backgroundBottomColor: "#000000",
          attributionURL: "https://deep-link-url",
        ).then((data) {
          print(data);
        });
      },
      child: Text("Share On Instagram Story"),
    );
  }

  Text _title() {
    return Text(
      'Running on: ${describeEnum(defaultTargetPlatform)}',
      textAlign: TextAlign.center,
    );
  }
}
