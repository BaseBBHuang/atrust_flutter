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
  Future<Map<String, dynamic>> authenticate(
      String url, String username, String password) async {
    try {
      final result = await methodChannel.invokeMapMethod<String, dynamic>(
        'authenticate',
        {'url': url, 'username': username, 'password': password},
      );
      return result ?? <String, dynamic>{};
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

  @override
  Future<int> getSocks5ProxyPort() async {
    try {
      final port = await methodChannel.invokeMethod<int>('getSocks5ProxyPort');
      return port ?? 0;
    } on PlatformException catch (e) {
      throw Exception("获取SOCKS5代理端口失败: ${e.message}");
    }
  }

  @override
  Future<String> getTunnelStatus() async {
    try {
      final s = await methodChannel.invokeMethod<String>('getTunnelStatus');
      return s ?? 'UNKNOWN';
    } on PlatformException catch (e) {
      throw Exception("获取隧道状态失败: ${e.message}");
    }
  }

  @override
  Future<void> startTunnel() async {
    try {
      await methodChannel.invokeMethod('startTunnel');
    } on PlatformException catch (e) {
      throw Exception("启动隧道失败: ${e.message}");
    }
  }

  @override
  Future<Map<String, dynamic>> startTunnelAndWait(
      {int timeoutMs = 15000}) async {
    try {
      final r = await methodChannel.invokeMapMethod<String, dynamic>(
        'startTunnelAndWait',
        {'timeoutMs': timeoutMs},
      );
      return r ?? <String, dynamic>{};
    } on PlatformException catch (e) {
      throw Exception("启动隧道失败: ${e.message}");
    }
  }
}
