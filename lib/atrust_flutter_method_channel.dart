import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'atrust_flutter_platform_interface.dart';

/// An implementation of [AtrustFlutterPlatform] that uses method channels.
class MethodChannelAtrustFlutter extends AtrustFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('atrust_flutter');

  /// 初始化SDK
  @override
  Future<void> initSDK() async {
    try {
      await methodChannel.invokeMethod('initSDK');
    } on PlatformException catch (e) {
      throw Exception("初始化失败: ${e.message}");
    }
  }

  /// 用户认证
  @override
  Future<void> authenticate(
      String url, String username, String password) async {
    try {
      await methodChannel.invokeMethod(
        'authenticate',
        {'url': url, 'username': username, 'password': password},
      );
    } on PlatformException catch (e) {
      throw Exception("认证失败: ${e.message}");
    }
  }

  @override
  Future<Map<String, dynamic>> commonHttpsRequest(
      String url, String type, String value) async {
    try {
      final result = await methodChannel.invokeMapMethod<String, dynamic>(
        'commonHttpsRequest',
        {'url': url, 'type': type, 'value': value},
      );
      return result ?? <String, dynamic>{};
    } on PlatformException catch (e) {
      throw Exception("通用HTTPS请求失败: ${e.message}");
    }
  }

  /// 访问受保护资源
  @override
  Future<void> logout() async {
    try {
      await methodChannel.invokeMethod('logout');
    } on PlatformException catch (e) {
      throw Exception("请求失败: ${e.message}");
    }
  }
}
