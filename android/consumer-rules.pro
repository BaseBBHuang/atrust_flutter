# Atrust Flutter Plugin ProGuard Rules
# 深信服 SDK 混淆规则

# 保持深信服 SDK 所有类不被混淆
-keep class com.sangfor.** {*;}

# 保持 Android 系统类
-keep class android.** {*;}

# 保持插件入口类
-keep class com.tianxin.atrust_flutter.** {*;}
