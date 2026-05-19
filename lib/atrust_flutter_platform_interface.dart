import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'atrust_flutter_method_channel.dart';

abstract class AtrustFlutterPlatform extends PlatformInterface {
  /// Constructs a AtrustFlutterPlatform.
  AtrustFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static AtrustFlutterPlatform _instance = MethodChannelAtrustFlutter();

  /// The default instance of [AtrustFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelAtrustFlutter].
  static AtrustFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AtrustFlutterPlatform] when
  /// they register themselves.
  static set instance(AtrustFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 初始化SDK
  Future<void> initSDK() async {
    throw UnimplementedError('initSDK() has not been implemented.');
  }

  /// 用户认证
  Future<void> authenticate(
      String url, String username, String password) async {
    throw UnimplementedError('authenticate() has not been implemented.');
  }

  Future<Map<String, dynamic>> commonHttpsRequest(
      String url, String type, String value) async {
    throw UnimplementedError('commonHttpsRequest() has not been implemented.');
  }

  /// 注销
  Future<void> logout() async {
    throw UnimplementedError('requestResource() has not been implemented.');
  }
}
