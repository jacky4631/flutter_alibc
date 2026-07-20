package com.wxwx.flutter_alibc_ultimate

import android.app.Activity
import android.content.Intent
import android.webkit.WebChromeClient
import android.webkit.WebViewClient
import com.alibaba.baichuan.android.trade.AlibcTrade
import com.alibaba.baichuan.android.trade.AlibcTradeSDK
import com.alibaba.baichuan.android.trade.callback.AlibcTradeInitCallback
import com.alibaba.baichuan.android.trade.model.AlibcShowParams
import com.alibaba.baichuan.android.trade.page.AlibcBasePage
import com.alibaba.baichuan.android.trade.page.AlibcDetailPage
import com.alibaba.baichuan.android.trade.page.AlibcMyCartsPage
import com.alibaba.baichuan.android.trade.page.AlibcShopPage
import com.alibaba.baichuan.trade.biz.AlibcTradeCallback
import com.alibaba.baichuan.trade.biz.applink.adapter.AlibcFailModeType
import com.alibaba.baichuan.trade.biz.context.AlibcResultType
import com.alibaba.baichuan.trade.biz.context.AlibcTradeResult
import com.alibaba.baichuan.trade.biz.core.taoke.AlibcTaokeParams
import com.alibaba.baichuan.trade.biz.login.AlibcLogin
import com.alibaba.baichuan.trade.biz.login.AlibcLoginCallback
import com.alibaba.alibcprotocol.param.AlibcBizParams
import com.baichuan.nb_trade.AlibcTrade as AlibcTradeUltimate
import com.alibaba.fastjson.JSON
import com.wxwx.flutter_alibc_ultimate.web.WebViewActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

class FlutterAlibcUltimateHandle(var methodChannel: MethodChannel?){
    var activity: Activity? = null

    fun disposed(){
        this.methodChannel = null
        this.activity = null
    }

    /**
     * 初始化阿里百川旗舰版
     */
    fun initAlibc(result: MethodChannel.Result){
        AlibcTradeSDK.init(activity!!.application, object : AlibcTradeInitCallback {
            override fun onSuccess() {
                result.success(PluginResponse.success(null).toMap())
            }
            override fun onFailure(code: Int, msg: String?) {
                result.success(PluginResponse(code.toString(), msg, null).toMap())
            }
        }, AlibcTradeSDK.InitStrategy.INIT)
    }

    /**
     * 登陆淘宝
     */
    fun loginTaoBao(){
        val alibcLogin = AlibcLogin.getInstance()
        if(alibcLogin.isLogin){
            val session = alibcLogin.session
            System.out.println(JSON.toJSONString(alibcLogin.session))
            val userInfo: MutableMap<String, Any> = HashMap()
            userInfo["nick"] = session.nick
            userInfo["avatarUrl"] = session.avatarUrl
            userInfo["openId"] = session.openId
            userInfo["openSid"] = session.openSid
            userInfo["topAccessToken"] = session.topAccessToken
            userInfo["topAuthCode"] = session.topAuthCode
            methodChannel!!.invokeMethod("AlibcTaobaoLogin", PluginResponse.success(userInfo).toMap())
            return
        }
        alibcLogin.showLogin(object : AlibcLoginCallback {
            override fun onSuccess(loginResult: Int, openId: String?, nickName: String?) {
                val userInfo: MutableMap<String, Any> = HashMap()
                val session = alibcLogin.session
                System.out.println(JSON.toJSONString(alibcLogin.session))
                userInfo["nick"] = session.nick
                userInfo["avatarUrl"] = session.avatarUrl
                userInfo["openId"] = session.openId
                userInfo["openSid"] = session.openSid
                userInfo["topAccessToken"] = session.topAccessToken
                userInfo["topAuthCode"] = session.topAuthCode
                methodChannel!!.invokeMethod("AlibcTaobaoLogin", PluginResponse.success(userInfo).toMap())
            }
            override fun onFailure(code: Int, msg: String?) {
                methodChannel!!.invokeMethod("AlibcTaobaoLogin", PluginResponse(code.toString(), msg, null).toMap())
            }
        })
    }

    /**
     * 登出
     */
    fun logoutTaoBao(result: MethodChannel.Result){
        val alibcLogin = AlibcLogin.getInstance()
        alibcLogin.logout(object : AlibcLoginCallback {
            override fun onSuccess(p0: Int, p1: String?, p2: String?) {
                result.success(PluginResponse.success(null).toMap())
            }
            override fun onFailure(code: Int, msg: String?) {
                result.success(PluginResponse(code.toString(), msg, null).toMap())
            }
        })
    }

    /**
     * 淘宝授权登陆 获取access_token
     */
    fun taoKeLogin(call: MethodCall){
        val map = call.arguments as HashMap<String, Any>
        val url = call.argument<String>("url")
        WebViewActivity.callBack = object : WebViewActivity.Callback {
            override fun success(accessToken: String?) {
                val resMap: HashMap<String, Any?> = HashMap<String, Any?>()
                resMap["accessToken"] = accessToken
                methodChannel!!.invokeMethod("AlibcTaokeLogin", PluginResponse.success(resMap).toMap())
            }
            override fun failed(errorMsg: String?) {
                val code = -1
                methodChannel!!.invokeMethod("AlibcTaokeLogin", PluginResponse(code.toString(), errorMsg, null).toMap())
            }
        }
        val intent = Intent(activity!!, WebViewActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.putExtra("url", url)
        intent.putExtra("arguments", map)
        activity!!.startActivity(intent)
    }

    /**
     * 淘宝授权登陆 获取code授权码
     */
    fun taoKeLoginForCode(call: MethodCall){
        val map = call.arguments as HashMap<*, *>
        val url = call.argument<String>("url")
        WebViewActivity.callBack = object : WebViewActivity.Callback {
            override fun success(accessToken: String?) {
                val resMap: HashMap<String, Any?> = HashMap<String, Any?>()
                resMap["code"] = accessToken
                methodChannel!!.invokeMethod("AlibcTaokeLoginForCode", PluginResponse.success(resMap).toMap())
            }
            override fun failed(errorMsg: String?) {
                var code = -1
                methodChannel!!.invokeMethod("AlibcTaokeLoginForCode", PluginResponse(code.toString(), errorMsg, null).toMap())
            }
        }
        val intent = Intent(activity!!, WebViewActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.putExtra("url", url)
        intent.putExtra("arguments", map)
        activity!!.startActivity(intent)
    }

    /**
     * 通过URL方式打开淘宝
     */
    fun openByUrl(call: MethodCall, result: MethodChannel.Result){
        val showParams = AlibcShowParams()
        var taokeParams: AlibcTaokeParams? = AlibcTaokeParams("", "", "")

        showParams.backUrl = call.argument(PluginConstants.key_BackUrl)
        if (call.argument<Any?>(PluginConstants.key_OpenType) != null) {
            showParams.openType = PluginUtil.getOpenType("" + call.argument<Any>(PluginConstants.key_OpenType))
        }
        if (call.argument<Any?>(PluginConstants.key_ClientType) != null) {
            showParams.clientType = PluginUtil.getClientType("" + call.argument<Any>(PluginConstants.key_ClientType))
        }
        if (call.argument<Any?>("taokeParams") != null) {
            taokeParams = PluginUtil.getTaokeParams(call.argument<Map<String?, Any?>>("taokeParams")!!)
        }
        if ("false" == call.argument<Any>("isNeedCustomNativeFailMode")) {
            showParams.nativeOpenFailedMode = AlibcFailModeType.AlibcNativeFailModeNONE
        } else if (call.argument<Any?>(PluginConstants.key_NativeFailMode) != null) {
            showParams.nativeOpenFailedMode = PluginUtil.getFailModeType("" + call.argument<Any>(PluginConstants.key_NativeFailMode))
        }

        val trackParams: Map<String, String> = HashMap()
        val url = call.argument<String>("url")
        AlibcTrade.openByUrl(activity, "", url!!, null,
                WebViewClient(), WebChromeClient(), showParams,
                taokeParams, trackParams, object : AlibcTradeCallback {
            override fun onTradeSuccess(tradeResult: AlibcTradeResult) {
                val results: MutableMap<String, Any> = HashMap()
                if (AlibcResultType.TYPECART == tradeResult.resultType) {
                    results["type"] = 1
                } else if (AlibcResultType.TYPEPAY == tradeResult.resultType) {
                    results["type"] = 0
                    results["payFailedOrders"] = tradeResult.payResult.payFailedOrders
                    results["paySuccessOrders"] = tradeResult.payResult.paySuccessOrders
                }
                methodChannel!!.invokeMethod("AlibcOpenURL", PluginResponse.success(results).toMap())
            }
            override fun onFailure(code: Int, msg: String) {
                methodChannel!!.invokeMethod("AlibcOpenURL", PluginResponse(code.toString(), msg, null).toMap())
            }
        })
    }

    /**
     * 打开商店
     */
    fun openShop(call: MethodCall, result: MethodChannel.Result) {
        val page: AlibcBasePage = AlibcShopPage(call.argument("shopId"))
        openByBizCode(page, "shop", "AlibcOpenShop", call, result)
    }

    /**
     * 打开购物车
     */
    fun openCart(call: MethodCall, result: MethodChannel.Result) {
        val page: AlibcBasePage = AlibcMyCartsPage()
        openByBizCode(page, "cart", "AlibcOpenCar", call, result)
    }

    /**
     * 打开保价页 (通过openByCode方式)
     */
    fun openPriceProtection(call: MethodCall, result: MethodChannel.Result) {
        val showParams = AlibcShowParams()
        var taokeParams: AlibcTaokeParams? = AlibcTaokeParams("", "", "")
        showParams.backUrl = call.argument(PluginConstants.key_BackUrl)
        if (call.argument<Any?>(PluginConstants.key_OpenType) != null) {
            showParams.openType = PluginUtil.getOpenType("" + call.argument<Any>(PluginConstants.key_OpenType))
        }
        if (call.argument<Any?>(PluginConstants.key_ClientType) != null) {
            showParams.clientType = PluginUtil.getClientType("" + call.argument<Any>(PluginConstants.key_ClientType))
        }
        if (call.argument<Any?>("taokeParams") != null) {
            taokeParams = PluginUtil.getTaokeParams(call.argument<Map<String?, Any?>>("taokeParams")!!)
        }
        if ("false" == call.argument<Any>("isNeedCustomNativeFailMode")) {
            showParams.nativeOpenFailedMode = AlibcFailModeType.AlibcNativeFailModeNONE
        } else if (call.argument<Any?>(PluginConstants.key_NativeFailMode) != null) {
            showParams.nativeOpenFailedMode = PluginUtil.getFailModeType("" + call.argument<Any>(PluginConstants.key_NativeFailMode))
        }
        val trackParams: Map<String, String> = HashMap()
        val pageCode = call.argument<String>("pageCode") ?: "priceProtection"
        val bizParams = AlibcBizParams()
        AlibcTradeUltimate.openByCode(activity, pageCode, bizParams, showParams,
                taokeParams, trackParams, object : AlibcTradeCallback {
            override fun onTradeSuccess(tradeResult: AlibcTradeResult) {
                val results: MutableMap<String, Any> = HashMap()
                if (AlibcResultType.TYPECART == tradeResult.resultType) {
                    results["type"] = 1
                } else if (AlibcResultType.TYPEPAY == tradeResult.resultType) {
                    results["type"] = 0
                    results["payFailedOrders"] = tradeResult.payResult.payFailedOrders
                    results["paySuccessOrders"] = tradeResult.payResult.paySuccessOrders
                }
                methodChannel!!.invokeMethod("AlibcOpenPriceProtection", PluginResponse.success(results).toMap())
            }
            override fun onFailure(code: Int, msg: String) {
                methodChannel!!.invokeMethod("AlibcOpenPriceProtection", PluginResponse(code.toString(), msg, null).toMap())
            }
        })
    }

    /**
     * 打开商品详情
     */
    fun openItemDetail(call: MethodCall, result: MethodChannel.Result) {
        val page: AlibcBasePage = AlibcDetailPage(call.argument("itemID"))
        openByBizCode(page, "detail", "AlibcOpenDetail", call, result)
    }

    private fun openByBizCode(page: AlibcBasePage, type: String, methodName: String, call: MethodCall, result: MethodChannel.Result) {
        val showParams = AlibcShowParams()
        var taokeParams: AlibcTaokeParams? = AlibcTaokeParams("", "", "")
        showParams.backUrl = call.argument(PluginConstants.key_BackUrl)
        if (call.argument<Any?>(PluginConstants.key_OpenType) != null) {
            showParams.openType = PluginUtil.getOpenType("" + call.argument<Any>(PluginConstants.key_OpenType))
        }
        if (call.argument<Any?>(PluginConstants.key_ClientType) != null) {
            showParams.clientType = PluginUtil.getClientType("" + call.argument<Any>(PluginConstants.key_ClientType))
        }
        if (call.argument<Any?>("taokeParams") != null) {
            taokeParams = PluginUtil.getTaokeParams(call.argument<Map<String?, Any?>>("taokeParams")!!)
        }
        if ("false" == call.argument<Any>("isNeedCustomNativeFailMode")) {
            showParams.nativeOpenFailedMode = AlibcFailModeType.AlibcNativeFailModeNONE
        } else if (call.argument<Any?>(PluginConstants.key_NativeFailMode) != null) {
            showParams.nativeOpenFailedMode = PluginUtil.getFailModeType("" + call.argument<Any>(PluginConstants.key_NativeFailMode))
        }
        val trackParams: Map<String, String> = HashMap()
        AlibcTrade.openByBizCode(activity, page, null, WebViewClient(),
                WebChromeClient(), type, showParams, taokeParams,
                trackParams, object : AlibcTradeCallback {
            override fun onTradeSuccess(tradeResult: AlibcTradeResult) {
                val results: MutableMap<String, Any> = HashMap()
                if (AlibcResultType.TYPECART == tradeResult.resultType) {
                    results["type"] = 1
                } else if (AlibcResultType.TYPEPAY == tradeResult.resultType) {
                    results["type"] = 0
                    results["payFailedOrders"] = tradeResult.payResult.payFailedOrders
                    results["paySuccessOrders"] = tradeResult.payResult.paySuccessOrders
                }
                methodChannel!!.invokeMethod(methodName, PluginResponse.success(results).toMap())
            }
            override fun onFailure(code: Int, msg: String) {
                methodChannel!!.invokeMethod(methodName, PluginResponse(code.toString(), msg, null).toMap())
            }
        })
    }

    /**
     * 设置淘客打点策略 是否异步
     */
    fun syncForTaoke(call: MethodCall) {
        AlibcTradeSDK.setSyncForTaoke(call.argument<Boolean>("isSync")!!)
    }

    fun useAlipayNative(call: MethodCall) {
        // AlibcTradeSDK.setShouldUseAlipay(call.argument<Boolean>("isNeed")!!)
    }
}
