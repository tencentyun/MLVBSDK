package com.tencent.qcloud.xiaozhibo.common.utils;

import android.os.Build;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by Link on 2016/7/26.
 */
//
//由于测试机型调度的时间周期比较长，初期的100台Android机型测试智能在8月中旬完成，届时才能知道Top100机型的兼容情况
//目前我们把研发和功能测试团队手上全部的26款机型进行了测试，汇总了一个白名单列表，在其中的您可以放心开启硬件加速
//
//其它机型，如果您发现也支持，即可把其添加进去，我们团队也在持续增加这个列表的数量。

//H264硬编码白名单:
//每一条目用"\n"分割，客户和机型用"|"分割，当前手机的客户和机型可通过Android Studio查看，也可以在Demo运行后在Log界面看到
//对小米、华为、魅族机型做了模糊处理，如小米4有 MI 4LTE/ MI 4W/ MI 4等多种类型，统一处理为MI 4
//其他品牌类型按全称识别
//经测试有问题的机型：
//1.HUAWEI P6-U06:硬编完成后，UV数据位置颠倒
//2.Samsung SCH-I939(S3):编码填数据发生异常
//3.VIVO vivoX5Pro D:码率异常
//4.金立 GN9006:码率异常
//5.Samsung A7000:偶现黑屏
public class TCHWSupportList {
    static final String supportList =
            "HUAWEI|PE-TL20\n" +
                    "HUAWEI|RIO-UL\n" +
                    "HUAWEI|P7-\n" +//P7
                    "HUAWEI|GRA-UL\n" +//P8
                    "HUAWEI|GRA-TL\n" +
                    "HUAWEI|MLA-AL\n" +//麦芒5
                    "HUAWEI|MT7-TL\n" +//mate7
                    "HUAWEI|ALE-TL\n" +//P8-LITE
                    "HUAWEI|TAG-AL\n" +
                    "HUAWEI|H60-L\n" +
                    "HUAWEI|G750-t\n" +
                    "HUAWEI|Che1-c\n" +
                    "HUAWEI|Ath-al\n" +
                    "HUAWEI|PLK-TL\n" +
                    "HUAWEI|XUS 6P\n" +//Nexus 6P
                    "HUAWEI|MT7-TL\n" +
                    "HUAWEI|NXT-AL\n" +
                    "HUAWEI|ALE-UL\n" +
                    "HUAWEI|H60-L0\n" +
                    "HUAWEI|EVA-AL\n" +
                    "HUAWEI|TAG-AL\n" +
                    "HUAWEI|RIO-AL\n" +
                    "HUAWEI|CRR-CL\n" +//Mate-s
                    "Xiaomi|MI 2\n" +
                    "Xiaomi|MI 3\n" +
                    "Xiaomi|MI 5\n" +
                    "Xiaomi|MI 4\n" +
                    "Xiaomi|HM NOTE\n" +//HM NOTE
                    "Xiaomi|Redmi Note 3\n" +//Redmi Note 3
                    "Xiaomi|Redmi Note 2\n" +//Redmi Note 3
                    "Xiaomi|Redmi 3\n" +//Redmi 3
                    "Xiaomi|2014501\n" +
                    "Xiaomi|2014011\n" +
                    "Xiaomi|2014813\n" +
                    "Xiaomi|MI NOTE LTE\n" +
                    "Xiaomi|HM NOTE 1LTE\n" +
                    "Xiaomi|HM MOTE 1S\n" +
                    "Xiaomi|HM 2A\n" +
                    "Xiaomi|2s\n" +
                    "Xiaomi|Mi-4c\n" +
                    "Meizu|MX4\n" +
                    "Meizu|MX5\n" +
                    "Meizu|MX6\n" +
                    "Meizu|Pro 5\n" +
                    "Meizu|Pro 6\n" +
                    "Meizu|m1 metal\n" +
                    "Meizu|note 2\n" +
                    "Meizu|M1 note\n" +
                    "Meizu|M2\n" +
                    "Meizu|note 3\n" +
                    "OPPO|R7Plusm\n" +
                    "OPPO|OPPO A33\n" +
                    "OPPO|OPPO R9m\n" +
                    "OPPO|R7Plus\n" +
                    "OPPO|R7\n" +
                    "OPPO|R7s\n" +
                    "OPPO|R7sm\n" +
                    "OPPO|R8207\n" +
                    "OPPO|A31\n" +
                    "OPPO|R6007\n" +
                    "OPPO|3007\n" +
                    "OPPO|X9007\n" +
                    "OPPO|R8107\n" +
                    "OPPO|A51\n" +
                    "OPPO|N5207\n" +
                    "OPPO|A53\n" +
                    "OPPO|R7t\n" +
                    "OPPO|A31t\n" +
                    "OPPO|n5117\n" +
                    "OPPO|R8007\n" +
                    "OPPO|R2017\n" +
                    "OPPO|R7C\n" +
                    "OPPO|R7007\n" +
                    "OPPO|OPPO R7sPlus\n" +
                    "OPPO|OPPO A33m\n" +
                    "VIVO|X5S L\n" +
                    "VIVO|X5M\n" +
                    "VIVO|X5Max+\n" +
                    "vivo|X5Max\n" +
                    "VIVO|X6Plus D\n" +
                    "VIVO|X6D\n" +
                    "VIVO|Y27\n" +
                    "VIVO|Y33\n" +
                    "VIVO|X5V\n" +
                    "VIVO|Y29L\n" +
                    "VIVO|Y51A\n" +
                    "VIVO|X710L\n" +
                    "VIVO|X6A\n" +
                    "VIVO|R9 plustm A\n" +
                    "VIVO|a53m\n" +
                    "VIVO|X3L\n" +
                    "VIVO|Xplay 3S\n" +
                    "VIVO|X5L\n" +
                    "VIVO|Y23L\n" +
                    "VIVO|Y51\n" +
                    "VIVO|Y35\n" +
                    "VIVO|Y37\n" +
                    "Samsung|GT-I9500\n" +//S4
                    "Samsung|GT-N7100\n" +
                    "Samsung|A5000\n" +
                    "Samsung|N9006\n" +
                    "Samsung|N9008V\n" +
                    "Samsung|G9250\n" +
                    "Samsung|i9500\n" +
                    "Motorola|Nexus 6\n" +
                    "LGE|Nexus 5\n" +//Mate-s
                    "HTC|8088\n" +
                    "ONEPLUS|A0001\n" +//Mate-s
                    "smartisan|YQ601\n" +
                    "Lenovo|K900\n" +
                    "Letv|X900+\n" +
                    "Letv|X500\n" +
                    "Letv|X501\n";
    public static boolean isHWVideoEncodeSupport(){
        if(Build.VERSION.SDK_INT < 18){
            return false;
        }
        String[] items = supportList.split("\n");
        Map<String,String> list = new HashMap<>();
        for (int i =0;i<items.length;i++){
            String[] its = items[i].split("\\|");
            if (!list.containsKey(its[0].toLowerCase())){
                list.put(its[0].toLowerCase(),its[1].toLowerCase());
            }
            else{
                list.put(its[0].toLowerCase(),list.get(its[0].toLowerCase())+"|"+its[1].toLowerCase());
            }
        }
        if (list.containsKey(Build.MANUFACTURER.toLowerCase())){
            boolean ret = false;
            if (Build.MANUFACTURER.toLowerCase().contains("xiaomi")){
                if (list.get(Build.MANUFACTURER.toLowerCase()).contains((Build.MODEL.length()>=4?Build.MODEL.substring(0,4):Build.MODEL).toLowerCase())){
                    ret = true;
                }
            }
            else if(Build.MANUFACTURER.toLowerCase().contains("huawei")){
                if (list.get(Build.MANUFACTURER.toLowerCase()).contains((Build.MODEL.length()>=6?Build.MODEL.substring(0,6):Build.MODEL).toLowerCase())){
                    ret = true;
                }
            }
            else if(Build.MANUFACTURER.toLowerCase().contains("meizu")){
                if (list.get(Build.MANUFACTURER.toLowerCase()).contains((Build.MODEL.length()>=3?Build.MODEL.substring(0,3):Build.MODEL).toLowerCase())){
                    ret = true;
                }
            }
            if (ret == false){
                if (list.get(Build.MANUFACTURER.toLowerCase()).contains(Build.MODEL.toLowerCase())){
                    return  true;
                }
            }
            else {
                return true;
            }
        }
        return false;
    }
}
