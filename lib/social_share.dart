import 'dart:async';
import 'package:flutter/services.dart';

class SocialShare {
  static const MethodChannel _channel = const MethodChannel('social_share');

  static Future<String> shareInstagramStory(
      String stickerImage,
      String backgroundTopColor,
      String backgroundBottomColor,
      String attributionURL) async {
    final Map<String, dynamic> args = <String, dynamic>{
      "stickerImage": stickerImage,
      "backgroundTopColor": backgroundTopColor,
      "backgroundBottomColor": backgroundBottomColor,
      "attributionURL": attributionURL
    };

    final String response =
        await _channel.invokeMethod('shareInstagramStory', args);

    return response;
  }

  static Future<String> shareFacebookStory(
      String stickerImage,
      String backgroundTopColor,
      String backgroundBottomColor,
      String attributionURL,
      String appID) async {
    final Map<String, dynamic> args = <String, dynamic>{
      "stickerImage": stickerImage,
      "backgroundTopColor": backgroundTopColor,
      "backgroundBottomColor": backgroundBottomColor,
      "attributionURL": attributionURL,
      "appID": appID
    };

    final String response =
        await _channel.invokeMethod('shareFacebookStory', args);
    return response;
  }

  static Future<String> shareWhatsapp() async {
    final String version = await _channel.invokeMethod('shareWhatsapp');
    return version;
  }

  static Future<String> shareTelegram() async {
    final String version = await _channel.invokeMethod('shareTelegram');
    return version;
  }

  static Future<String> shareTwitter() async {
    final String version = await _channel.invokeMethod('shareTwitter');
    return version;
  }

  static Future<String> shareSms() async {
    final String version = await _channel.invokeMethod('shareSms');
    return version;
  }

  static Future<String> shareSlack() async {
    final String version = await _channel.invokeMethod('shareSlack');
    return version;
  }

  static Future<bool> copyToClipboard(content) async {
    final Map<String, String> args = <String, String>{
      "content": content.toString()
    };
    final bool response = await _channel.invokeMethod('copyToClipboard', args);
    return response;
  }
}
