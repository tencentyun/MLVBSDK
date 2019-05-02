注意：
（1）在集成SDK前请务必阅读以下文档，该文档有助于您更快的集成SDK：
     https://www.qcloud.com/doc/api/258/5319

（2）SDK相关的库(jar/so)放在app/src/main/jniLibs目录下，jniLibs目录为android studio默认的so加载目录，推荐在集成SDK时按照demo的做法，将so和jar拷贝入您的工程的src/main/jniLibs目录下

（3）本目录下的几个aar和jar为demo工程用到的辅助库，如果您不需要这些功能，可以自行移除：
     barcodescanner-core-1.8.4.aar      二维码扫码库
     zxing-1.8.4.aar                    二维码扫码库
     zxing-core-3.2.1.jar               二维码扫码库
     bugly_crash_release__2.1.jar       bugly库，为腾讯提供的用于crash收集分析的库