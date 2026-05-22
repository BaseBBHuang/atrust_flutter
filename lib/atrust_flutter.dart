import 'atrust_flutter_platform_interface.dart';

class AtrustFlutter {
  /// 初始化SDK
  static Future<void> initSDK() async {
    return AtrustFlutterPlatform.instance.initSDK();
  }

  /// 用户认证
  static Future<Map<String, dynamic>> authenticate(
      String url, String username, String password) async {
    return AtrustFlutterPlatform.instance.authenticate(url, username, password);
  }

  static Future<Map<String, dynamic>> commonHttpsRequest(
      String url, String type, String value) async {
    return AtrustFlutterPlatform.instance.commonHttpsRequest(url, type, value);
  }

  /// 注销
  static Future<void> logout() async {
    return AtrustFlutterPlatform.instance.logout();
  }

  /// 获取 SDK 本地 SOCKS5 代理端口
  /// 业务网络库需通过 127.0.0.1:port 走 SOCKS5 才会经过零信任隧道
  static Future<int> getSocks5ProxyPort() {
    return AtrustFlutterPlatform.instance.getSocks5ProxyPort();
  }

  /// 隧道状态：INIT / ONLINE / OFFLINE
  static Future<String> getTunnelStatus() {
    return AtrustFlutterPlatform.instance.getTunnelStatus();
  }

  /// 手动启动隧道
  static Future<void> startTunnel() {
    return AtrustFlutterPlatform.instance.startTunnel();
  }

  /// 启动隧道并等待上线，返回 {success: bool, message: String, status: String}
  static Future<Map<String, dynamic>> startTunnelAndWait(
      {int timeoutMs = 15000}) {
    return AtrustFlutterPlatform.instance
        .startTunnelAndWait(timeoutMs: timeoutMs);
  }
}
