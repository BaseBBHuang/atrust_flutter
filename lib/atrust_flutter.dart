import 'atrust_flutter_platform_interface.dart';

class AtrustFlutter {
  /// 初始化SDK
  static Future<void> initSDK() async {
    return AtrustFlutterPlatform.instance.initSDK();
  }

  /// 用户认证
  static Future<void> authenticate(
      String url, String username, String password) async {
    return AtrustFlutterPlatform.instance.authenticate(url, username, password);
  }

  /// 注销
  static Future<void> logout() async {
    return AtrustFlutterPlatform.instance.logout();
  }
}
