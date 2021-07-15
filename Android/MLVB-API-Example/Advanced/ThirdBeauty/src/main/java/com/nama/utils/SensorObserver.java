package com.nama.utils;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.util.Log;

/**
 * 加速度监听器
 *
 * @author Richie on 2020.07.17
 */
public class SensorObserver implements SensorEventListener {
    private static final String TAG = "SensorObserver";
    private Sensor mSensor;
    private SensorManager mSensorManager;
    private OnAccelerometerChangedListener mOnAccelerometerChangedListener;

    public SensorObserver(Context context) {
        mSensorManager = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);
        mSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
    }

    public void setOnAccelerometerChangedListener(OnAccelerometerChangedListener onAccelerometerChangedListener) {
        mOnAccelerometerChangedListener = onAccelerometerChangedListener;
    }

    public void register() {
        Log.d(TAG, "register: ");
        mSensorManager.registerListener(this, mSensor, SensorManager.SENSOR_DELAY_NORMAL);
    }

    public void unregister() {
        Log.d(TAG, "unregister: ");
        mSensorManager.unregisterListener(this);
    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
            float x = event.values[0];
            float y = event.values[1];
            float z = event.values[2];
            if (mOnAccelerometerChangedListener != null) {
                mOnAccelerometerChangedListener.onAccelerometerChanged(x, y, z);
            }
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }

    public interface OnAccelerometerChangedListener {
        /**
         * 加速度变化
         *
         * @param x
         * @param y
         * @param z
         */
        void onAccelerometerChanged(float x, float y, float z);
    }

}