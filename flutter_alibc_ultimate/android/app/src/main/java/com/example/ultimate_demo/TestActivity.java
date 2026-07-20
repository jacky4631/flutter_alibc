package com.example.ultimate_demo;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import com.alibaba.alibcprotocol.callback.AlibcTradeCallback;
import com.alibaba.alibcprotocol.param.AlibcBizParams;
import com.alibaba.alibcprotocol.param.AlibcDegradeType;
import com.alibaba.alibcprotocol.param.AlibcShowParams;
import com.alibaba.alibcprotocol.param.AlibcTaokeParams;
import com.alibaba.alibcprotocol.param.OpenType;
import com.alibaba.baichuan.trade.common.utils.AlibcLogger;
import com.baichuan.nb_trade.AlibcTrade;
import com.baichuan.nb_trade.callback.AlibcTradeInitCallback;
import com.baichuan.nb_trade.core.AlibcTradeSDK;

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;

/**
 * author: created by randy on 2020-06-19 13:08
 * 项目名称：百川旗舰版SDK
 */
public class TestActivity extends Activity {

    private static final String TAG = MainActivity.class.getSimpleName();

    public static ClassLoader ORIGINAL_CLASS_LOADER = null;
    public static ClassLoader CUSTOMED_CLASS_LOADER = null;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.test_layout);
        setClassLoader(getApplication());
        cart();
        init();
    }

    private void setClassLoader(Application application) {
        Context mBase = (Context) getFieldValue(application, "mBase");
        Object mPackageInfo = getFieldValue(mBase, "mPackageInfo");
        ORIGINAL_CLASS_LOADER = (ClassLoader) getFieldValue(mPackageInfo, "mClassLoader");
        CUSTOMED_CLASS_LOADER = new MyClassLoader(ORIGINAL_CLASS_LOADER);
        setFieldValue(mPackageInfo, "mClassLoader", CUSTOMED_CLASS_LOADER);
    }

    public static class MyClassLoader extends ClassLoader {

        public MyClassLoader(ClassLoader parent) {
            super(parent);
        }

        @Override
        public Class<?> loadClass(String className)
                throws ClassNotFoundException {
            return super.loadClass(className);
        }
    }

    public static void setFieldValue(Object obj, String fieldName,
                                     Object fieldValue) {
        if (obj == null || fieldName == null) {
            return;
        }
        Class<?> clazz = obj.getClass();
        while (clazz != null) {
            try {
                Field field = clazz.getDeclaredField(fieldName);
                field.setAccessible(true);
                field.set(obj, fieldValue);
                return;
            } catch (SecurityException e) {
            } catch (NoSuchFieldException e) {
            } catch (IllegalArgumentException e) {
            } catch (IllegalAccessException e) {
            } finally {
                clazz = clazz.getSuperclass();
            }
        }
    }

    public static Object getFieldValue(Object obj, String fieldName) {
        if (obj == null || fieldName == null) {
            return null;
        }
        Class<?> c = obj.getClass();
        Object value = null;
        while (c != null) {
            try {
                Field field = c.getDeclaredField(fieldName);
                field.setAccessible(true);
                value = field.get(obj);
                if (value != null) {
                    return value;
                }
            } catch (SecurityException e) {
            } catch (NoSuchFieldException e) {
            } catch (IllegalArgumentException e) {
            } catch (IllegalAccessException e) {
            } finally {
                c = c.getSuperclass();
            }
        }
        return null;
    }

    private void initSDK() {
        // 扩展参数（默认可不设置或传空）
        Map<String, Object> extParams = new HashMap<>(16);
        AlibcTradeSDK.init(getApplication(), extParams, new AlibcTradeInitCallback() {
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

    private void init() {
//        findViewById(R.id.sdk_init).setOnClickListener(v -> initSDK());
        String[] abis = Build.SUPPORTED_ABIS;
        for (String abi: abis) {
            AlibcLogger.i(TAG, "abi: " + abi);
        }
    }

    private void cart() {
        findViewById(R.id.open_cart).setOnClickListener(v -> {
            AlibcShowParams showParams = new AlibcShowParams();
            showParams.setOpenType(OpenType.Auto);
            showParams.setDegradeType(AlibcDegradeType.H5);
            showParams.setBackUrl("alisdk://");

            AlibcTaokeParams taokeParams = new AlibcTaokeParams("mm_13127418_7884048_48384150139");
            AlibcBizParams bizParams = new AlibcBizParams();

            AlibcTrade.openByCode(TestActivity.this, "suite://bc.suite.basic/bc.template.cart", bizParams, showParams, taokeParams, null,
                    new AlibcTradeCallback() {
                        @Override
                        public void onSuccess(int i, Object o) {
                            Log.d(TAG, "onSuccess: i = " + i);
                        }

                        @Override
                        public void onFailure(int i, String s) {
                            Log.d(TAG, "onFailure: i = " + i + ", s = " + s);
                        }
                    });
        });
    }
}
