# atrust_flutter

这是深信服 Atrust SDK 的 Flutter 插件封装，支持 iOS 和 Android 平台。

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  atrust_flutter: ^latest_version
```

## iOS 配置

### 1. 配置权限

在 `ios/Runner/Info.plist` 中添加以下权限：

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>需要开启本地网络权限以保证应用可以正常连接网络</string>
<key>NSBonjourServices</key>
<array>
    <string>_lnp._tcp.</string>
</array>
<key>NSPhotoLibraryUsageDescription</key>
<string>截屏阻断需要相册权限</string>
```

### 2. 环境要求
- iOS 10.0 及以上版本
- 仅支持真机运行，不支持模拟器
- 仅支持 arm64 架构

## 使用示例

```dart
import 'package:atrust_flutter/atrust_flutter.dart';

// 初始化 SDK
await AtrustFlutter.initSDK();

// 认证
try {
  final result = await AtrustFlutter.authenticate(
    url: "https://your-vpn-url",
    username: "your-username",
    password: "your-password"
  );
  print("认证结果: ${result.toString()}");
} catch (e) {
  print("认证失败: ${e.toString()}");
}

// 注销
try {
  final result = await AtrustFlutter.logout();
  print("注销结果: ${result.toString()}");
} catch (e) {
  print("注销失败: ${e.toString()}");
}
```

## API 说明

### initSDK()
初始化 SDK，使用其他功能前必须先调用此方法。

### authenticate()
进行 VPN 认证。

参数：
- `url`: VPN 服务器地址
- `username`: 用户名
- `password`: 密码

返回值：
```dart
{
  "success": true/false,  // 是否成功
  "message": "提示信息",   // 成功或失败的提示信息
  "code": 0              // 状态码，0 表示成功
}
```

### logout()
注销当前登录。

返回值：
```dart
{
  "success": true/false,  // 是否成功
  "message": "提示信息",   // 成功或失败的提示信息
  "code": 0              // 状态码，0 表示成功
}
```

## 注意事项

1. iOS 端只支持真机运行，不支持模拟器
2. 使用前必须先调用 initSDK() 方法
3. 认证和注销操作都是异步的，建议使用 try-catch 处理可能的异常

## 常见问题

### Q: 运行时提示 "No such module 'SangforSDK'"
A: 检查是否已正确执行 `pod install`，并确保 Xcode 工程使用 `.xcworkspace` 打开。

### Q: 模拟器运行报错
A: SDK 仅支持真机运行，请使用真机测试。

### Q: 认证失败
A: 检查 URL 格式是否正确，用户名密码是否正确，网络是否正常。


