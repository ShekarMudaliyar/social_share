import 'package:flutter/material.dart';
import 'dart:async';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/services.dart';
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
    try {
      platformVersion = await SocialShare.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Running on: $_platformVersion\n',
                textAlign: TextAlign.center,
              ),
              RaisedButton(
                onPressed: () async {
                  await screenshotController.capture().then((image) async {
                    SocialShare.shareInstagramStory(image.path, "", "", "")
                        .then((data) {
                      print(data);
                    });
                  });
                },
                child: Text("Share On Instagrams"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
