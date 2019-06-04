package com.tencent.qcloud.xiaozhibo.anchor.prepare;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;

import java.io.IOException;
import java.util.List;

/**
 * Module:   TCLocationHelper
 * <p>
 * Function: 定位服务的工具类
 *
 * 该工具能提供粗略的定位服务，若您需要高精度定位，可以使用腾讯云 LBS SDK进行位置定位。
 *
 * 详情见：https://lbs.qq.com/geo/index.html
 */
public class TCLocationHelper {
    private static String TAG = "LocationHelper";

    private static LocationListener mLocationListener;

    static public boolean checkLocationPermission(final @NonNull Activity activity) {
        if (Build.VERSION.SDK_INT >= 23) {
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION)) {
                ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, TCConstants.LOCATION_PERMISSION_REQ_CODE);
                return false;
            }
        }

        return true;
    }

    static private String getAddressFromLocation(final @NonNull Activity activity, Location location) {
        Geocoder geocoder = new Geocoder(activity);

        try {
            double latitude = location.getLatitude();
            double longitude = location.getLongitude();
            Log.d(TAG, "getAddressFromLocation->lat:" + latitude + ", long:" + longitude);
            List<Address> list = geocoder.getFromLocation(latitude, longitude, 1);
            if (list.size() > 0) {
                //返回当前位置，精度可调
                Address address = list.get(0);
                String sAddress;

                if(!TextUtils.isEmpty(address.getLocality())) {
                    if(!TextUtils.isEmpty(address.getFeatureName())) {
                        sAddress = address.getLocality() + " " + address.getFeatureName();
                    } else {
                        sAddress = address.getLocality();
                    }
                } else
                    sAddress = "定位失败";

                return sAddress;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        return "";
    }

    static public boolean getMyLocation(final @NonNull Activity activity, final @NonNull OnLocationListener listener) {
        final LocationManager locationManager = (LocationManager) activity.getSystemService(Context.LOCATION_SERVICE);

        if(!locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)){
            // notify user
            AlertDialog.Builder dialog = new AlertDialog.Builder(activity, R.style.ConfirmDialogStyle);
            dialog.setMessage("尚未开启位置定位服务");
            dialog.setPositiveButton("开启", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface paramDialogInterface, int paramInt) {
                    // TODO Auto-generated method stub
                    Intent myIntent = new Intent( Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                    activity.startActivity(myIntent);
                    //get gps
                }
            });
            dialog.setNegativeButton("取消", new DialogInterface.OnClickListener() {

                @Override
                public void onClick(DialogInterface paramDialogInterface, int paramInt) {
                    // TODO Auto-generated method stub

                }
            });
            dialog.show();
            return false;
        }

        if (!checkLocationPermission(activity)) {
            return true;
        }

        Location curLoc = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
        if (null == curLoc) {
            mLocationListener = new LocationListener() {
                @Override
                public void onLocationChanged(Location location) {
                    String strAddr = getAddressFromLocation(activity, location);
                    if (TextUtils.isEmpty(strAddr)) {
                        listener.onLocationChanged(-1, 0, 0, strAddr);
                    } else {
                        listener.onLocationChanged(0, location.getLatitude(), location.getLongitude(), strAddr);
                    }
                    locationManager.removeUpdates(this);
                }

                @Override
                public void onStatusChanged(String provider, int status, Bundle extras) {
                    locationManager.removeUpdates(this);
                }

                @Override
                public void onProviderEnabled(String provider) {
                    locationManager.removeUpdates(this);
                }

                @Override
                public void onProviderDisabled(String provider) {
                    locationManager.removeUpdates(this);
                }
            };
            locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 8000, 0, mLocationListener);
        } else {
            String strAddr = getAddressFromLocation(activity, curLoc);
            if (TextUtils.isEmpty(strAddr)) {
                listener.onLocationChanged(-1, 0, 0, strAddr);
            } else {
                listener.onLocationChanged(0, curLoc.getLatitude(), curLoc.getLongitude(), strAddr);
            }
        }
        return true;
    }

    public interface OnLocationListener {
        void onLocationChanged(int code, double lat1, double long1, String location);
    }
}
