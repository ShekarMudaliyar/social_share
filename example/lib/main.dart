import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:screenshot/screenshot.dart';
import 'package:social_share/social_share.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String facebookId = "xxxxxxxx";

  var imageBackground = "image-background.jpg";
  var videoBackground = "video-background.mp4";
  String imageBackgroundPath = "";
  String videoBackgroundPath = "";

  @override
  void initState() {
    super.initState();
    copyBundleAssets();
  }

  Future<void> copyBundleAssets() async {
    imageBackgroundPath = await copyImage(imageBackground);
    videoBackgroundPath = await copyImage(videoBackground);
  }

  Future<String> copyImage(String filename) async {
    final tempDir = await getTemporaryDirectory();
    ByteData bytes = await rootBundle.load("assets/$filename");
    final assetPath = '${tempDir.path}/$filename';
    File file = await File(assetPath).create();
    await file.writeAsBytes(bytes.buffer.asUint8List());
    return file.path;
  }

  Future<String?> pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    var path = file?.path;
    if (path == null) {
      return null;
    }
    return file?.path;
  }

  Future<String?> screenshot() async {
    var data = await screenshotController.capture();
    if (data == null) {
      return null;
    }
    final tempDir = await getTemporaryDirectory();
    final assetPath = '${tempDir.path}/temp.png';
    File file = await File(assetPath).create();
    await file.writeAsBytes(data);
    return file.path;
  }

  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Social Share'),
        ),
        body: Screenshot(
          controller: screenshotController,
          child: Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Instagram",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 40),
                      ElevatedButton(
                        child: Icon(Icons.gradient),
                        onPressed: () async {
                          var path = await pickImage();
                          if (path == null) {
                            return;
                          }
                          SocialShare.shareInstagramStory(
                            appId: facebookId,
                            imagePath: path,
                            backgroundTopColor: "#ffffff",
                            backgroundBottomColor: "#000000",
                          ).then((data) {
                            print(data);
                          });
                        },
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        child: Icon(Icons.image),
                        onPressed: () async {
                          var path = await pickImage();
                          if (path == null) {
                            return;
                          }
                          SocialShare.shareInstagramStory(
                            appId: facebookId,
                            imagePath: path,
                            backgroundResourcePath: imageBackgroundPath,
                          ).then((data) {
                            print(data);
                          });
                        },
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        child: Icon(Icons.videocam),
                        onPressed: () async {
                          var path = await screenshot();
                          if (path == null) {
                            return;
                          }
                          SocialShare.shareInstagramStory(
                            appId: facebookId,
                            imagePath: path,
                            backgroundResourcePath: videoBackgroundPath,
                          ).then((data) {
                            print(data);
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Facebook",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 40),
                      ElevatedButton(
                        child: Icon(Icons.gradient),
                        onPressed: () async {
                          var path = await pickImage();
                          if (path == null) {
                            return;
                          }
                          SocialShare.shareFacebookStory(
                            appId: facebookId,
                            imagePath: path,
                            backgroundTopColor: "#ffffff",
                            backgroundBottomColor: "#000000",
                          ).then((data) {
                            print(data);
                          });
                        },
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        child: Icon(Icons.image),
                        onPressed: () async {
                          var path = await pickImage();
                          if (path == null) {
                            return;
                          }
                          SocialShare.shareFacebookStory(
                            appId: facebookId,
                            imagePath: path,
                            backgroundResourcePath: imageBackgroundPath,
                          ).then((data) {
                            print(data);
                          });
                        },
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        child: Icon(Icons.videocam),
                        onPressed: () async {
                          var path = await screenshot();
                          if (path == null) {
                            return;
                          }
                          await SocialShare.shareFacebookStory(
                            appId: facebookId,
                            imagePath: path,
                            backgroundResourcePath: videoBackgroundPath,
                          ).then((data) {
                            print(data);
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Twitter",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 40),
                      ElevatedButton(
                        child: Icon(Icons.text_fields),
                        onPressed: () async {
                          SocialShare.shareTwitter(
                            "This is Social Share twitter example with link.  ",
                            hashtags: [
                              "SocialSharePlugin",
                              "world",
                              "foo",
                              "bar"
                            ],
                            url: "https://google.com/hello",
                            trailingText: "cool!!",
                          ).then((data) {
                            print(data);
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Clipboard",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 40),
                      ElevatedButton(
                        child: Icon(Icons.image),
                        onPressed: () async {
                          SocialShare.copyToClipboard(
                            image: await screenshot(),
                          ).then((data) {
                            print(data);
                          });
                        },
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        child: Icon(Icons.text_fields),
                        onPressed: () async {
                          SocialShare.copyToClipboard(
                            text: "This is Social Share plugin",
                          ).then((data) {
                            print(data);
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "SMS",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 40),
                      ElevatedButton(
                        child: Icon(Icons.text_fields),
                        onPressed: () async {
                          SocialShare.shareSms(
                            "This is Social Share Sms example",
                            url: "https://google.com/",
                            trailingText: "\nhello",
                          ).then((data) {
                            print(data);
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Share Options",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 40),
                      ElevatedButton(
                        child: Icon(Icons.text_fields),
                        onPressed: () async {
                          SocialShare.shareOptions("Hello world").then((data) {
                            print(data);
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Whatsapp",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 40),
                      ElevatedButton(
                        onPressed: () async {
                          SocialShare.shareWhatsapp(
                            "Hello World \n https://google.com",
                          ).then((data) {
                            print(data);
                          });
                        },
                        child: Icon(Icons.text_fields),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Telegram",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 40),
                      ElevatedButton(
                        onPressed: () async {
                          SocialShare.shareTelegram(
                            "Hello World \n https://google.com",
                          ).then((data) {
                            print(data);
                          });
                        },
                        child: Icon(Icons.text_fields),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Get all Apps",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 40),
                      ElevatedButton(
                        child: Icon(Icons.text_fields),
                        onPressed: () async {
                          SocialShare.checkInstalledAppsForShare().then((data) {
                            print(data.toString());
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
