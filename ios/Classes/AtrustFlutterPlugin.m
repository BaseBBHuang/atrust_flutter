#import "AtrustFlutterPlugin.h"
#import <SangforSDK/SFUemSDK.h>

@interface AtrustFlutterPlugin () <SFAuthResultDelegate, SFLogoutDelegate, SFCommonHttpsRequestResultDelegate>
@property (nonatomic, strong) FlutterResult authResult;
@property (nonatomic, strong) FlutterResult commonHttpsRequestResult;
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
    } else {
    result(FlutterMethodNotImplemented);
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
    if (self.authResult) {
        NSDictionary *resultDict = @{
            @"success": @NO,
            @"message": message.errStr ?: @"认证失败",
            @"code": @(message.errCode)
        };
        self.authResult(resultDict);
        self.authResult = nil;
    }
}

- (void)onAuthProcess:(SFAuthType)nextAuthType message:(nonnull SFBaseMessage *)message { 
    NSLog(@"AtrustFlutterPlugin onAuthProcess:%ld, msg:%@", (long)nextAuthType, message.errStr);
}

- (void)onAuthSuccess:(nonnull SFBaseMessage *)message { 
    if (self.authResult) {
        NSDictionary *resultDict = @{
            @"success": @YES,
            @"message": @"认证成功",
            @"code": @(message.errCode)
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
