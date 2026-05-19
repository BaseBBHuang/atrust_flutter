package com.tianxin.atrust_flutter

import android.content.Context
import android.util.Log
import com.sangfor.sdk.SFUemSDK
import com.sangfor.sdk.base.SFAuthResultListener
import com.sangfor.sdk.base.SFAuthType
import com.sangfor.sdk.base.SFBaseMessage
import com.sangfor.sdk.base.SFCommonHttpsRequestListener
import com.sangfor.sdk.base.SFLogoutListener
import com.sangfor.sdk.base.SFSDKExtras
import com.sangfor.sdk.base.SFSDKFlags
import com.sangfor.sdk.base.SFSDKMode
import com.sangfor.sdk.utils.SFLogN
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.EnumMap


/** AtrustFlutterPlugin */
class AtrustFlutterPlugin: FlutterPlugin, MethodCallHandler {
  private val TAG: String = "PrimaryAuthActivity"

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "atrust_flutter")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "initSDK" -> {
        val extra: Map<SFSDKExtras, String> = EnumMap(com.sangfor.sdk.base.SFSDKExtras::class.java)

        var sdkFlags = SFSDKFlags.FLAGS_HOST_APPLICATION
        sdkFlags = sdkFlags or SFSDKFlags.FLAGS_VPN_MODE_TCP

        try {
          SFUemSDK.getInstance()
            .initSDK(context, SFSDKMode.MODE_SUPPORT_MUTABLE, sdkFlags, extra)
          result.success(null)
        } catch (e: Exception) {
          result.error("1001", e.message, null)
        }
      }

      "authenticate" -> {
        val url = call.argument<String>("url")
        val username = call.argument<String>("username")
        val password = call.argument<String>("password")
        SFUemSDK.getInstance().setAuthResultListener(object : SFAuthResultListener {
          override fun onAuthSuccess(message: SFBaseMessage) {
            try {
              SFLogN.info(TAG, "auth success")

              val extra: MutableMap<String, Any?> = mutableMapOf()
              extra["mErrCode"] = message.mErrCode
              extra["mErrStr"] = message.mErrStr
              extra["mServerInfo"] = message.mServerInfo
              extra["currentAuthType"] = message.currentAuthType.name
              extra["mDisplayName"] = message.mDisplayName
              extra["mEnhanceAuthTips"] = message.mEnhanceAuthTips
              extra["mNextServiceList"] = message.mNextServiceList

              result.success(extra)
            } catch(e: Exception) {
              Log.e(TAG, "onAuthSuccess: ", e)
            }
          }

          override fun onAuthFailed(message: SFBaseMessage) {
            SFLogN.error2(TAG, "auth failed", "errMsg: " + message.mErrStr)
            result.error(message.mErrCode.toString(), message.mErrStr, null)
          }

          override fun onAuthProgress(nextAuthType: SFAuthType, message: SFBaseMessage) {
            SFLogN.info(TAG, "need next auth, authType: " + nextAuthType.name)
          }
        })
        SFUemSDK.getInstance().startPasswordAuth(url, username, password)
      }

      "commonHttpsRequest" -> {
        val url = call.argument<String>("url")
        val type = call.argument<String>("type")
        val value = call.argument<String>("value")

        if (url.isNullOrEmpty() || type.isNullOrEmpty() || value == null) {
          result.error("1002", "url、type、value不能为空", null)
          return
        }

        try {
          SFUemSDK.getInstance().getSFAuth().commonHttpsRequest(
            url,
            type,
            value,
            object : SFCommonHttpsRequestListener {
              override fun onRequestResult(message: SFBaseMessage) {
                val extra: MutableMap<String, Any?> = mutableMapOf()
                extra["mErrCode"] = message.mErrCode
                extra["mErrStr"] = message.mErrStr
                extra["mServerInfo"] = message.mServerInfo
                result.success(extra)
              }
            }
          )
        } catch (e: Exception) {
          result.error("1003", e.message, null)
        }
      }

      "logout" -> {
        val logoutListener = SFLogoutListener { type, message ->
          // 修正 Log.d 方法的调用，将 type 和 message 作为日志消息
          Log.d(TAG, "Logout type: $type, message: $message")
        }
        SFUemSDK.getInstance().registerLogoutListener(logoutListener)

        SFUemSDK.getInstance().logout();
        result.success(null)
      }

      "autoTicket" -> {
        if (SFUemSDK.getInstance().startAutoTicket()){
          result.success(true)
        } else {
          result.success(false)
        }
      }

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
