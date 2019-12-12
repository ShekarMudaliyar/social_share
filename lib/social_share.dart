import 'dart:async';
import 'package:flutter/services.dart';

class SocialShare {
  static const MethodChannel _channel = const MethodChannel('social_share');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> shareInstagramStory(stickerImage, backgroundTopColor,
      backgroundBottomColor, attributionURL) async {
    final Map<String, dynamic> args = <String, dynamic>{
      "stickerImage": stickerImage,
      "backgroundTopColor": backgroundTopColor,
      "backgroundBottomColor": backgroundBottomColor,
      "attributionURL": attributionURL
    };

    final bool commit =
        await _channel.invokeMethod('shareInstagramStory', args);

    return commit;
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

  static Future<String> shareFacebook() async {
    final String version = await _channel.invokeMethod('shareFacebook');
    return version;
  }

  static Future<String> shareSlack() async {
    final String version = await _channel.invokeMethod('shareSlack');
    return version;
  }

  static Future<bool> copyLink(text) async {
    return true;
  }
}
