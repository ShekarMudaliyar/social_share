import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SocialShare {
  static const MethodChannel _channel = const MethodChannel('social_share');

  static Future<String?> shareInstagramStory({
    required String appId,
    required String imagePath,
    String? backgroundTopColor,
    String? backgroundBottomColor,
    String? attributionURL,
    String? backgroundImagePath,
  }) async {
    return shareMetaStory(
      appId: appId,
      platform: "shareInstagramStory",
      imagePath: imagePath,
      backgroundTopColor: backgroundTopColor,
      backgroundBottomColor: backgroundBottomColor,
      attributionURL: attributionURL,
      backgroundImagePath: backgroundImagePath,
    );
  }

  static Future<String?> shareFacebookStory({
    required String appId,
    String? imagePath,
    String? backgroundTopColor,
    String? backgroundBottomColor,
    String? attributionURL,
    String? backgroundImagePath,
  }) async {
    return shareMetaStory(
      appId: appId,
      platform: "shareFacebookStory",
      imagePath: imagePath,
      backgroundTopColor: backgroundTopColor,
      backgroundBottomColor: backgroundBottomColor,
      attributionURL: attributionURL,
      backgroundImagePath: backgroundImagePath,
    );
  }

  static Future<String?> shareMetaStory({
    required String appId,
    required String platform,
    String? imagePath,
    String? backgroundTopColor,
    String? backgroundBottomColor,
    String? attributionURL,
    String? backgroundImagePath,
  }) async {
    var _imagePath = imagePath;
    var _backgroundImagePath = backgroundImagePath;

    if (Platform.isAndroid) {
      var stickerFilename = "stickerAsset.png";
      await reSaveImage(imagePath, stickerFilename);
      _imagePath = stickerFilename;
      if (backgroundImagePath != null) {
        var backgroundImageFilename = "backgroundAsset.jpg";
        await reSaveImage(backgroundImagePath, backgroundImageFilename);
        _backgroundImagePath = backgroundImageFilename;
      }
    }

    Map<String, dynamic> args = <String, dynamic>{
      "stickerImage": _imagePath,
      "backgroundTopColor": backgroundTopColor,
      "backgroundBottomColor": backgroundBottomColor,
      "attributionURL": attributionURL,
      "appId": appId
    };

    if (_backgroundImagePath != null) {
      args["backgroundImage"] = _backgroundImagePath;
    }

    final String? response = await _channel.invokeMethod(platform, args);
    return response;
  }

  static Future<String?> shareTwitter(
    String captionText, {
    List<String>? hashtags,
    String? url,
    String? trailingText,
  }) async {
    //Caption
    var _captionText = captionText;

    //Hashtags
    if (hashtags != null && hashtags.isNotEmpty) {
      final tags = hashtags.map((t) => '#$t ').join(' ');
      _captionText = _captionText + "\n" + tags.toString();
    }

    //Url
    String _url;
    if (url != null) {
      if (Platform.isAndroid) {
        _url = Uri.parse(url).toString().replaceAll('#', "%23");
      } else {
        _url = Uri.parse(url).toString();
      }
      _captionText = _captionText + "\n" + _url;
    }

    if (trailingText != null) {
      _captionText = _captionText + "\n" + trailingText;
    }

    Map<String, dynamic> args = <String, dynamic>{
      "captionText": _captionText + " ",
    };
    final String? version = await _channel.invokeMethod('shareTwitter', args);
    return version;
  }

  static Future<String?> shareSms(String message,
      {String? url, String? trailingText}) async {
    Map<String, dynamic>? args;
    if (Platform.isIOS) {
      if (url == null) {
        args = <String, dynamic>{
          "message": message,
        };
      } else {
        args = <String, dynamic>{
          "message": message + " ",
          "urlLink": Uri.parse(url).toString(),
          "trailingText": trailingText
        };
      }
    } else if (Platform.isAndroid) {
      args = <String, dynamic>{
        "message": message + (url ?? '') + (trailingText ?? ''),
      };
    }
    final String? version = await _channel.invokeMethod('shareSms', args);
    return version;
  }

  static Future<bool?> copyToClipboard(content) async {
    final Map<String, String> args = <String, String>{
      "content": content.toString()
    };
    final bool? response = await _channel.invokeMethod('copyToClipboard', args);
    return response;
  }

  static Future<bool?> shareOptions(String contentText,
      {String? imagePath}) async {
    Map<String, dynamic> args;

    var _imagePath = imagePath;
    if (Platform.isAndroid) {
      if (imagePath != null) {
        var stickerFilename = "stickerAsset.png";
        await reSaveImage(imagePath, stickerFilename);
        _imagePath = stickerFilename;
      }
    }
    args = <String, dynamic>{"image": _imagePath, "content": contentText};
    final bool? version = await _channel.invokeMethod('shareOptions', args);
    return version;
  }

  static Future<String?> shareWhatsapp(String content) async {
    final Map<String, dynamic> args = <String, dynamic>{"content": content};
    final String? version = await _channel.invokeMethod('shareWhatsapp', args);
    return version;
  }

  static Future<Map?> checkInstalledAppsForShare() async {
    final Map? apps = await _channel.invokeMethod('checkInstalledApps');
    return apps;
  }

  static Future<String?> shareTelegram(String content) async {
    final Map<String, dynamic> args = <String, dynamic>{"content": content};
    final String? version = await _channel.invokeMethod('shareTelegram', args);
    return version;
  }

// static Future<String> shareSlack() async {
//   final String version = await _channel.invokeMethod('shareSlack');
//   return version;
// }

  //Utils
  static Future<bool> reSaveImage(String? imagePath, String filename) async {
    if (imagePath == null) {
      return false;
    }
    final tempDir = await getTemporaryDirectory();

    File file = File(imagePath);
    Uint8List bytes = file.readAsBytesSync();
    var stickerData = bytes.buffer.asUint8List();
    String stickerAssetName = filename;
    final Uint8List stickerAssetAsList = stickerData;
    final stickerAssetPath = '${tempDir.path}/$stickerAssetName';
    file = await File(stickerAssetPath).create();
    file.writeAsBytesSync(stickerAssetAsList);
    return true;
  }
}
