# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# 混淆规则：https://baichuan.taobao.com/docs/doc.htm?spm=a3c0d.7629140.0.0.12a5be48ZrTi3q&treeId=129&articleId=118885&docType=1
-keepattributes Signature
-ignorewarnings
-keep class javax.ws.rs.** { *; }

-keep class com.alibaba.fastjson.** { *; }
-dontwarn com.alibaba.fastjson.**

-keep class sun.misc.Unsafe { *; }
-dontwarn sun.misc.**

-keep class com.taobao.** {*;}
-keep class com.alibaba.** {*;}
-dontwarn com.taobao.**
-dontwarn com.alibaba.**

-keep class com.ta.** {*;}
-dontwarn com.ta.**
-keep class org.json.** {*;}
-keepattributes *Annotation*

-keep interface mtopsdk.mtop.global.init.IMtopInitTask {*;}
-keep class * implements mtopsdk.mtop.global.init.IMtopInitTask {*;}

-keep class tv.danmaku.ijk.media.player.TaobaoMediaPlayer{*;}
-keep class tv.danmaku.ijk.media.player.TaobaoMediaPlayer$*{*;}
-keep class tv.taobao.media.player.TaobaoMediaPlayer{*;}
-keep class tv.taobao.media.player.TaobaoMediaPlayer$*{*;}

# 安全保镖新版本
-keep class com.hzchengdun.securityguard.** { *; }