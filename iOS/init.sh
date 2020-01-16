#!/usr/bin/env bash
cd $(dirname $0)
ROOT=`pwd`

cd $ROOT
if [ ! -e "SDK/ImSDK.framework" ]; then
URL="https://pod-1252463788.cos.ap-guangzhou.myqcloud.com/mlvbspec/ImSDK/ImSDK.framework.zip"
echo "Downloading IM SDK from $URL"
curl "$URL" --output SDK/ImSDK.zip
cd SDK
unzip -q ImSDK.zip
rm -rf ImSDK.zip
rm -rf __MACOSX
fi

cd $ROOT
if [ ! -e "SDK/Bugly.framework" ]; then
URL="https://pod-1252463788.cos.ap-guangzhou.myqcloud.com/mlvbspec/Bugly/Bugly.framework.zip"
echo "Downloading Bugly SDK from $URL"
curl "$URL" --output SDK/Bugly.zip
cd SDK
unzip -q Bugly.zip
rm -rf Bugly.zip
fi

cd $ROOT
if [ ! -e "SDK/TXLiteAVSDK_Smart.framework" ]; then
URL="$(cat SDK/README.md | grep -o 'http.*zip')"
echo "Downloading SDK from $URL"
curl "$URL" --output SDK/TXLiteAVSDK_Smart_iOS.zip
cd SDK
unzip -q TXLiteAVSDK_Smart_iOS.zip
mv TXLiteAVSDK_Smart_*/SDK/*.framework .
rm -rf TXLiteAVSDK_Smart_*
fi
