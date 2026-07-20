package com.example.ultimate_demo;

import android.app.Application;

import com.alibaba.alibctriver.AlibcImageCenter;
import com.alibaba.alibctriver.AlibcNavigateCenter;
import com.alibaba.baichuan.trade.common.AlibcBaseTradeCommon;
import com.alibaba.baichuan.trade.common.AlibcTradeCommon;
import com.alibaba.baichuan.trade.common.utils.AlibcLogger;
import com.baichuan.nb_trade.callback.AlibcTradeInitCallback;
import com.baichuan.nb_trade.core.AlibcTradeBiz;
import com.baichuan.nb_trade.core.AlibcTradeSDK;
import com.example.ultimate_demo.extend.ImageImpl;
import com.example.ultimate_demo.extend.ShareImpl;

import java.util.HashMap;
import java.util.Map;

public class BaseApplication extends Application {

    private static final String TAG = BaseApplication.class.getSimpleName();

    @Override
    public void onCreate() {
        super.onCreate();
        // 打开debug调试
        turnOnDebug();
        // 注册小程序三方实现（比如：分享或图片库等）
        registerThirdInstance();
        // 初始化SDK
        initSDK();
    }

    private void turnOnDebug() {
        AlibcTradeCommon.turnOnDebug();
        AlibcTradeCommon.openErrorLog();
        AlibcTradeBiz.turnOnDebug();
    }

    private void turnOffDebug() {
        AlibcTradeCommon.turnOffDebug();
        AlibcTradeCommon.closeErrorLog();
        AlibcTradeBiz.turnOffDebug();
    }

    private void registerThirdInstance() {
        // 注册分享实现
        ShareImpl share = new ShareImpl();
        AlibcNavigateCenter.registerNavigateUrl(share);
        // 注册图片库实现
        ImageImpl image = new ImageImpl(BaseApplication.this);
        AlibcImageCenter.registerImage(image);
    }

    private void initSDK() {
        // 扩展参数（默认可不设置或传空）
        Map<String, Object> extParams = new HashMap<>(16);
        extParams.put("timeout", 5000);
        AlibcTradeSDK.init(this, extParams, new AlibcTradeInitCallback() {
            @Override
            public void onSuccess() {
                AlibcLogger.i(TAG, "init sdk success");
            }

            @Override
            public void onFailure(int code, String msg) {
                AlibcLogger.e(TAG, "init sdk fail: code = " + code + ", msg = " + msg);
            }
        }, AlibcTradeSDK.InitStrategy.BEFORE_CALL_API);
    }
}
