package com.example.ultimate_demo;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.alibaba.alibclogin.AlibcLogin;
import com.alibaba.alibcprotocol.callback.AlibcLoginCallback;
import com.alibaba.alibcprotocol.callback.AlibcTradeCallback;
import com.alibaba.alibcprotocol.param.AlibcBizParams;
import com.alibaba.alibcprotocol.param.AlibcDegradeType;
import com.alibaba.alibcprotocol.param.AlibcShowParams;
import com.alibaba.alibcprotocol.param.AlibcTaokeParams;
import com.alibaba.alibcprotocol.param.OpenType;
import com.alibaba.baichuan.trade.common.AlibcTradeCommon;
import com.alibaba.baichuan.trade.common.security.AlibcSecurityGuard;
import com.alibaba.baichuan.trade.common.utils.AlibcCommonUtils;
import com.alibaba.baichuan.trade.common.utils.AlibcLogger;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.baichuan.nb_trade.AlibcTrade;
import com.randy.alibcextend.auth.AuthCallback;
import com.randy.alibcextend.auth.TopAuth;
//import com.baichuan.nb_trade.auth.TopAuth;
//import com.baichuan.nb_trade.callback.AlibcTradeCallback;
//import com.baichuan.nb_trade.callback.AuthCallback;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class MainActivity extends Activity {

    private static final String TAG = MainActivity.class.getSimpleName();

    private static final String DEFAULT_BACK_URL = "alisdk://";

    public AlibcTaokeParams taokeParams = new AlibcTaokeParams("", "", "");

    public Map<String,String> trackParams = new HashMap<>(16);

    public AlibcBizParams bizParams = new AlibcBizParams();

    public EditText trackParamEdit = null;

    public EditText taokeParamEdit = null;

    public EditText bizParamEdit = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // 淘客参数
        taokeParams.subPid = "";
        taokeParams.pid = "mm_98836808_2699500290_114433900090";
        taokeParams.unionId = "";
        taokeParams.relationId = "";
        taokeParams.materialSourceUrl = "";
        taokeParams.extParams = new HashMap<>();

        // 业务参数  商品id
        bizParams.setId("743632141802");
        bizParams.setShopId("");
        bizParams.setSellerId("");
        Map<String, String> map = new HashMap<>();
        bizParams.setExtParams(map);

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        // 启动悬浮窗
        AlibcCommonUtils.setOpenAnalysisTool(true);
        // 展示浮窗
//        AnalyzerTools.showFloatWindow(MainActivity.this, "baichuan");

        //跟踪参数
        trackParamEdit = findViewById(R.id.track_param);
        trackParams.put("testKey", "testValue");
        trackParamEdit.setText(trackParams.toString());
        //设置跟踪参数
        Button setTrackParam = findViewById(R.id.set_track_param);
        setTrackParam.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(v.getContext(), ParamEditActivity.class);
                intent.putExtra("trackParams",trackParamEdit.getText().toString());
                intent.putExtra("tag","trackParams");
                startActivityForResult(intent,1000);
            }
        });

        //淘客参数
        taokeParamEdit = findViewById(R.id.taoke_param);
        Map<String, String> taokeMap = new HashMap<>(16);
        taokeMap.put("pid",taokeParams.pid);
        taokeMap.put("subPid",taokeParams.subPid);
        taokeMap.put("unionId",taokeParams.unionId);
        taokeMap.put("relationId", taokeParams.relationId);
        taokeMap.put("materialSourceUrl", taokeParams.materialSourceUrl);
        taokeParamEdit.setText(taokeMap.toString());

        //设置淘客参数
        Button setTaokeParam = findViewById(R.id.set_taoke_param);
        setTaokeParam.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(v.getContext(),ParamEditActivity.class);
                intent.putExtra("taokeParams",taokeParamEdit.getText().toString());
                intent.putExtra("tag","taokeParams");
                startActivityForResult(intent,1001);
            }
        });

        // 业务参数
        bizParamEdit = findViewById(R.id.biz_param);
        Map<String, String> bizMap = new HashMap<>(16);
        bizMap.put("id", bizParams.getId());
        bizMap.put("shopId", bizParams.getShopId());
        bizMap.put("sellerId", bizParams.getSellerId());
        bizMap.put("extParams", JSON.toJSONString(bizParams.getExtParams()));
        bizParamEdit.setText(JSON.toJSONString(bizMap));

        // 采用套件code的方式打开
        Button openCode = findViewById(R.id.open_code);
        openCode.setOnClickListener(v -> {
            // show参数
            AlibcShowParams showParams = new AlibcShowParams();
            showParams.setBackUrl(DEFAULT_BACK_URL);
            showParams.setOpenType(OpenType.Native);
            showParams.setDegradeUrl("https://www.baidu.com");
            showParams.setDegradeType(AlibcDegradeType.H5);

//            // 淘客参数（入参pid，自行填写）
//            // TODO 此处的为测试用，切勿在自己应用中使用
//            AlibcTaokeParams taokeParams = new AlibcTaokeParams("mm_98836808_1507450087_110257500101");
//
//            // 自定义埋点参数（可缺省）
//            Map<String,String> trackParams = new HashMap<>(16);
//
//            // 淘客业务参数（参数设置具体参见文档）
//            AlibcBizParams bizParams = new AlibcBizParams();
//            // 设置商品id
//            bizParams.setId("557898536895");
//            // 其他业务参数
//            HashMap<String, String> extMap = new HashMap<>();
//            // 设置直播间id
////            extMap.put("id", "610409740620");
//            bizParams.setExtParams(extMap);

            // 业务参数
            String biz = "";
            if (null != bizParamEdit.getText()) {
                biz = bizParamEdit.getText().toString().trim();
            }
            try {
                JSONObject object = JSONObject.parseObject(biz);
                String sellerId = String.valueOf(object.get("sellerId"));
                String id = String.valueOf(object.get("id"));
                String shopId = String.valueOf(object.get("shopId"));
                String ext = String.valueOf(object.get("extParams"));
                bizParams.setId(id);
                bizParams.setSellerId(sellerId);
                bizParams.setShopId(shopId);
                bizParams.setExtParams((Map<String, String>) JSONObject.parse(ext));
            }catch (Exception e) {
                AlibcLogger.e(TAG, e.getMessage());
            }

            // 淘客参数
            taokeParams = getTaokeMap(getList(taokeParamEdit.getText().toString().trim()), taokeParams);

            // track参数
            trackParams = getTrackMap(getList(trackParamEdit.getText().toString().trim()));

            // 套件平台申请套件获取的code 【测试用code】
//            String code = "union.item.detail";
//            String code = "baichuan.union.detail.v1";
            String code = "suite://bc.suite.basic/bc.template.detail";
//            String code = "suite://bc.suite.live/bc.template.live.list";
//            String code = "suite://bc.suite.basic/bc.template.cart";
            AlibcTrade.openByCode(MainActivity.this, code, bizParams, showParams,
                    taokeParams, trackParams, new AlibcTradeCallback() {
                        @Override
                        public void onSuccess(int i, Object o) {

                        }

                        @Override
                        public void onFailure(int code, String msg) {
                            AlibcLogger.e(TAG, "open fail: code = " + code + ", msg = " + msg);
                        }
                    });
        });
        AlibcSecurityGuard.getInstance().init();

        // 采用普通url方式打开
        Button openUrl = findViewById(R.id.open_url);
        openUrl.setOnClickListener(v -> {

            // show参数
            AlibcShowParams showParams = new AlibcShowParams();
            showParams.setBackUrl(DEFAULT_BACK_URL);
            showParams.setOpenType(OpenType.Native);

//            AlibcTaokeParams taokeParams = new AlibcTaokeParams("");
//
//            // 自定义埋点参数（可缺省）
//            Map<String,String> trackParams = new HashMap<>(16);

            // 淘客参数
            taokeParams = getTaokeMap(getList(taokeParamEdit.getText().toString().trim()), taokeParams);

            // track参数
            trackParams = getTrackMap(getList(trackParamEdit.getText().toString().trim()));

            // 目标打开的链接【测试用链接】
            String url = "https://m.duanqu.com?_ariver_appid=3000000002019601&page=plugin-private%3a%2f%2f3000000002019601%2fpages%2findex%2findex%3fid%3d601132451767%26bbid%3dbaichuan";
            String temaiUrl = "https://temai.m.taobao.com/index.htm?pid=mm_26632738_595600271_109578950055";
            AlibcTrade.openByUrl(MainActivity.this, url, showParams, taokeParams, trackParams, new AlibcTradeCallback() {
                @Override
                public void onSuccess(int i, Object o) {

                }

                @Override
                public void onFailure(int code, String msg) {
                    AlibcLogger.e(TAG, "open fail: code = " + code + ", msg = " + msg);
                }
            });
        });

        // top auth授权
        Button topAuth = findViewById(R.id.top_auth);
        topAuth.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String appKey = AlibcTradeCommon.getAppKey();
                TopAuth.showAuthDialog(MainActivity.this, R.mipmap.ic_launcher_round, "百川测试Demo", appKey, new AuthCallback() {
                    @Override
                    public void onSuccess(String accessToken, String expireTime) {
                        Toast.makeText(MainActivity.this, "accessToken=" + accessToken
                                + ", expireTime=" + expireTime, Toast.LENGTH_SHORT).show();
                    }

                    @Override
                    public void onError(String code, String msg) {
                        Toast.makeText(MainActivity.this, "code=" + code + ", msg=" + msg, Toast.LENGTH_SHORT).show();
                    }
                });
            }
        });

        // 登录
        Button login = findViewById(R.id.login);
        login.setOnClickListener(v -> {
            AlibcLogin.getInstance().showLogin(new AlibcLoginCallback() {
                @Override
                public void onSuccess(String userId, String userNick) {
                    Toast.makeText(MainActivity.this, "login success" + " - "
                            + userId + " - " + userNick, Toast.LENGTH_SHORT).show();
                }

                @Override
                public void onFailure(int code, String msg) {
                    Toast.makeText(MainActivity.this, "login fail: code = " + code + ", msg = " + msg, Toast.LENGTH_SHORT).show();
                }
            });
        });

        // 登出
        Button logout = findViewById(R.id.logout);
        logout.setOnClickListener(v -> {
            AlibcLogin.getInstance().logout(new AlibcLoginCallback() {
                @Override
                public void onSuccess(String userId, String userNick) {
                    Toast.makeText(MainActivity.this, "logout success", Toast.LENGTH_SHORT).show();
                }

                @Override
                public void onFailure(int code, String msg) {
                    Toast.makeText(MainActivity.this, "logout fail: code = " + code + ", msg = " + msg, Toast.LENGTH_SHORT).show();
                }
            });
        });
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode,resultCode,data);
        String params;
        if(data!=null){
            if (requestCode == 1000 && resultCode == 1002) {
                params = (String) data.getSerializableExtra("mData");
                trackParamEdit.setText(params);
            } else if (requestCode == 1001 && resultCode==1002) {
                params  = (String) data.getSerializableExtra("mData");
                taokeParamEdit.setText(params);
            }
        }
    }

    public static class Param{
        String key;
        String value;
        public Param(String key,String value){
            this.key = key;
            this.value = value;
        }
        public String getKey(){
            return key;
        }
        public  String getValue(){
            return value;
        }
    }

    public ArrayList<Param> getList(String text){
        if(text == null){
            return null;
        }
        ArrayList<Param> list = new ArrayList<>();
        String subString = "";
        if(text.endsWith("}")&&text.startsWith("{")){
            subString = text.substring(text.indexOf("{")+1,text.lastIndexOf("}"));
            String [] array = subString.split(",");
            for (int i= 0;i<array.length;i++){
                if(array[i].split("=").length==0){
                    list.add(new Param("",""));
                }
                else if(array[i].startsWith("=")) {
                    list.add(new Param("", array[i].split("=")[1]));
                }else if(array[i].endsWith("=")){
                    list.add(new Param(array[i].split("=")[0], ""));
                }else{
                    list.add(new Param(array[i].split("=")[0], array[i].split("=")[1]));
                }
            }
            return list;
        }
        return  list;
    }

    public Map<String,String> getTrackMap(ArrayList<Param> list){
        trackParams.clear();
        if (null != list && list.size() > 0) {
            for(int i = 0; i < list.size(); i++){
                if(null != list.get(i)){
                    trackParams.put(list.get(i).key.trim(),list.get(i).value.trim());
                }
            }
        }
        return trackParams;
    }

    public AlibcTaokeParams getTaokeMap(ArrayList<Param> list, AlibcTaokeParams taokeParams){
        if(list == null){
            return null;
        }
        if(null == taokeParams){
            taokeParams = new AlibcTaokeParams("", "", "");
        }
        for(int i=0; i<list.size(); i++){
            String key = list.get(i).getKey().trim();
            String value = list.get(i).getValue().trim();
            if("pid".equals(key)){
                taokeParams.pid = value;
            }else if("unionId".equals(key)){
                taokeParams.unionId = value;
            }else if("subPid".equals(key)){
                taokeParams.subPid = value;
            }else if("relationId".equals(key)){
                taokeParams.relationId = value;
            }else if("materialSourceUrl".equals(key)){
                taokeParams.materialSourceUrl = value;
            }
        }
        return taokeParams;
    }
}
