#import "AtrustFlutterPlugin.h"
#import <SangforSDK/SFUemSDK.h>

@interface AtrustFlutterPlugin () <SFAuthResultDelegate, SFLogoutDelegate, SFCommonHttpsRequestResultDelegate, SFTunnelStatusDelegate>
@property (nonatomic, strong) FlutterResult authResult;
@property (nonatomic, strong) FlutterResult commonHttpsRequestResult;
@property (nonatomic, strong) FlutterResult tunnelWaitResult;
@end

@implementation AtrustFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"atrust_flutter"
            binaryMessenger:[registrar messenger]];
  AtrustFlutterPlugin* instance = [[AtrustFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"initSDK" isEqualToString:call.method]) {
        SFSDKMode mode = SFSDKModeSupportMutable;
        [[SFUemSDK sharedInstance] initSDK:mode
                                         flags:SFSDKFlagsHostApplication
                                         extra:nil];
        [[SFUemSDK sharedInstance] setAuthResultDelegate:self];
        [[SFUemSDK sharedInstance] setCommonHttpsRequestResultDelegate:self];
        [[SFUemSDK sharedInstance] registerLogoutDelegate:self];
        result(nil);
    } else if ([@"authenticate" isEqualToString:call.method]) {
        self.authResult = result;
        NSDictionary *arguments = call.arguments;
        
        NSURL *vpnUrl = [NSURL URLWithString:arguments[@"url"]];
        NSString *username = arguments[@"username"];
        NSString *password = arguments[@"password"];

        /**
         * 开始用户名密码认证，认证结果会在认证回调onAuthSuccess,onAuthFailed,onAuthProgress中返回
         */
        [[SFUemSDK sharedInstance] startPasswordAuth:vpnUrl userName:username password:password];
    } else if ([@"commonHttpsRequest" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        NSString *urlString = arguments[@"url"];
        NSString *type = arguments[@"type"];
        NSString *value = arguments[@"value"];

        if (urlString.length == 0 || type.length == 0 || value == nil) {
            result([FlutterError errorWithCode:@"1002" message:@"url、type、value不能为空" details:nil]);
            return;
        }

        NSURL *url = [NSURL URLWithString:urlString];
        if (url == nil) {
            result([FlutterError errorWithCode:@"1003" message:@"url格式不正确" details:nil]);
            return;
        }

        self.commonHttpsRequestResult = result;
        [[SFUemSDK sharedInstance] commonHttpsRequest:url type:type value:value];
    } else if ([@"logout" isEqualToString:call.method]) {
        [[SFUemSDK sharedInstance] cancelAuth];
        result(nil);
    } else if ([@"getSocks5ProxyPort" isEqualToString:call.method]) {
        // iOS SDK 通过 NSURLProtocol/CFNetwork hook 自动拦截网络请求，
        // 不需要业务侧手动走 SOCKS5。返回 0 让上层 Dio 不开启代理。
        result(@(0));
    } else if ([@"getTunnelStatus" isEqualToString:call.method]) {
        NSString *name = @"UNKNOWN";
        @try {
            SFTunnelStatus s = [[SFUemSDK sharedInstance].tunnel getTunnelStatus];
            switch (s) {
                case SFTunnelStatus_INIT:    name = @"INIT";    break;
                case SFTunnelStatus_ONLINE:  name = @"ONLINE";  break;
                case SFTunnelStatus_OFFLINE: name = @"OFFLINE"; break;
                default: break;
            }
        } @catch (NSException *ex) {
            // 非 L3VPN 模式（HOST_APPLICATION + TCP）下 iOS SDK 会抛
            // 异常 "current mode do not support l3vpn."，此处吞掉返回 UNKNOWN
            NSLog(@"AtrustFlutterPlugin getTunnelStatus exception: %@", ex.reason);
        }
        result(name);
    } else if ([@"startTunnel" isEqualToString:call.method]) {
        [[SFUemSDK sharedInstance].tunnel startTunnel];
        result(nil);
    } else if ([@"startTunnelAndWait" isEqualToString:call.method]) {
        SFTunnel *tunnel = [SFUemSDK sharedInstance].tunnel;
        SFTunnelStatus currentStatus = SFTunnelStatus_UNKNOWN;
        @try { currentStatus = [tunnel getTunnelStatus]; }
        @catch (NSException *ex) {
            NSLog(@"AtrustFlutterPlugin getTunnelStatus exception: %@", ex.reason);
        }
        if (currentStatus == SFTunnelStatus_ONLINE) {
            result(@{@"success": @(YES), @"message": @"already ONLINE", @"status": @"ONLINE"});
            return;
        }
        self.tunnelWaitResult = result;
        [tunnel setTunnelStatusDelegate:self];

        NSNumber *timeout = call.arguments[@"timeoutMs"];
        NSTimeInterval seconds = (timeout ? timeout.doubleValue : 15000.0) / 1000.0;
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.tunnelWaitResult) {
                strongSelf.tunnelWaitResult(@{@"success": @(NO), @"message": @"timeout", @"status": @"TIMEOUT"});
                strongSelf.tunnelWaitResult = nil;
                [tunnel setTunnelStatusDelegate:nil];
            }
        });

        [tunnel startTunnel];
    } else {
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark - SFTunnelStatusDelegate
- (void)onTunnelStatusChanged:(SFTunnelStatus)status {
    NSLog(@"AtrustFlutterPlugin tunnel status changed: %ld", (long)status);
    if (!self.tunnelWaitResult) return;
    if (status == SFTunnelStatus_ONLINE) {
        self.tunnelWaitResult(@{@"success": @(YES), @"message": @"ONLINE", @"status": @"ONLINE"});
        self.tunnelWaitResult = nil;
        [[SFUemSDK sharedInstance].tunnel setTunnelStatusDelegate:nil];
    } else if (status == SFTunnelStatus_OFFLINE) {
        self.tunnelWaitResult(@{@"success": @(NO), @"message": @"OFFLINE", @"status": @"OFFLINE"});
        self.tunnelWaitResult = nil;
        [[SFUemSDK sharedInstance].tunnel setTunnelStatusDelegate:nil];
    }
}

- (void)onCommonHttpsRequestResult:(SFBaseMessage *)msg {
    if (self.commonHttpsRequestResult) {
        NSDictionary *resultDict = @{
            @"mErrCode": @(msg.errCode),
            @"mErrStr": msg.errStr ?: @"",
            @"mServerInfo": msg.serverInfo ?: @""
        };
        self.commonHttpsRequestResult(resultDict);
        self.commonHttpsRequestResult = nil;
    }
}

- (void)onAuthFailed:(nonnull SFBaseMessage *)message {
    NSLog(@"AtrustFlutterPlugin onAuthFailed: code=%ld, msg=%@", (long)message.errCode, message.errStr);
    if (self.authResult) {
        NSDictionary *resultDict = @{
            @"mErrCode": @(message.errCode),
            @"mErrStr":  message.errStr ?: @"认证失败",
        };
        self.authResult(resultDict);
        self.authResult = nil;
    }
}

- (void)onAuthProcess:(SFAuthType)nextAuthType message:(nonnull SFBaseMessage *)message {
    // 仅打日志，不回调 result（避免同一个 FlutterResult 被多次调用导致异常）
    NSLog(@"AtrustFlutterPlugin onAuthProcess: nextType=%ld, code=%ld, msg=%@",
          (long)nextAuthType, (long)message.errCode, message.errStr);
}

- (void)onAuthSuccess:(nonnull SFBaseMessage *)message {
    NSLog(@"AtrustFlutterPlugin onAuthSuccess: code=%ld, msg=%@", (long)message.errCode, message.errStr);
    if (self.authResult) {
        NSDictionary *resultDict = @{
            @"mErrCode": @(message.errCode),
            @"mErrStr":  message.errStr ?: @"认证成功",
        };
        self.authResult(resultDict);
        self.authResult = nil;
    }
}

- (void)onLogout:(SFLogoutType)type message:(nonnull SFBaseMessage *)msg { 
    NSString *reason = @"";
    switch (type) {
        case SFLogoutTypeUser:
            reason = @"用户注销";
            break;
        case SFLogoutTypeTicketAuthError:
            reason = @"免密失败";
            break;
        case SFLogoutTypeServerShutdown:
            reason = @"服务端注销";
            break;
        case SFLogoutTypeAuthorError:
            reason = @"授权失败";
            break;
        default:
            reason = @"未知";
            break;
    }
    NSLog(@"AtrustFlutterPlugin onLogout reason:%@", reason);
}

@end
