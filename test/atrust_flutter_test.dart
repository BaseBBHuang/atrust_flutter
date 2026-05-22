import 'package:atrust_flutter/atrust_flutter.dart';
import 'package:atrust_flutter/atrust_flutter_method_channel.dart';
import 'package:atrust_flutter/atrust_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAtrustFlutterPlatform
    with MockPlatformInterfaceMixin
    implements AtrustFlutterPlatform {
  @override
  Future<Map<String, dynamic>> authenticate(
          String url, String username, String password) =>
      Future.value(<String, dynamic>{});

  @override
  Future<Map<String, dynamic>> commonHttpsRequest(
          String url, String type, String value) =>
      Future.value(<String, dynamic>{});

  @override
  Future<void> initSDK() => Future.value();

  @override
  Future<void> logout() => Future.value();

  @override
  Future<int> getSocks5ProxyPort() => Future.value(0);

  @override
  Future<String> getTunnelStatus() => Future.value('UNKNOWN');

  @override
  Future<void> startTunnel() => Future.value();

  @override
  Future<Map<String, dynamic>> startTunnelAndWait({int timeoutMs = 15000}) =>
      Future.value(<String, dynamic>{'success': true});
}

void main() {
  final AtrustFlutterPlatform initialPlatform = AtrustFlutterPlatform.instance;

  test('$MethodChannelAtrustFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAtrustFlutter>());
  });

  test('getPlatformVersion', () async {
    MockAtrustFlutterPlatform fakePlatform = MockAtrustFlutterPlatform();
    AtrustFlutterPlatform.instance = fakePlatform;

    await AtrustFlutter.initSDK();
  });
}
