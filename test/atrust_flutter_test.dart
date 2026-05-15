import 'package:atrust_flutter/atrust_flutter.dart';
import 'package:atrust_flutter/atrust_flutter_method_channel.dart';
import 'package:atrust_flutter/atrust_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAtrustFlutterPlatform
    with MockPlatformInterfaceMixin
    implements AtrustFlutterPlatform {
  @override
  Future<void> authenticate(String url, String username, String password) =>
      Future.value();

  @override
  Future<void> initSDK() => Future.value();

  @override
  Future<void> logout() => Future.value();
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
