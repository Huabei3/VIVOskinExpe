package com.example.calib96p3;



import static androidx.constraintlayout.helper.widget.MotionEffect.TAG;

import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import androidx.appcompat.app.AppCompatActivity;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Random;

public class MainActivity extends AppCompatActivity {
    private ImageView imageView;
    private int currentIndex = 0;
    private List<Integer> randomIndexes;
    private static final int TOTAL_IMAGES = 96;

    // 模式："normal"=正常播放96张, "debug_white"=只播放image71
//    private static final String MODE = "normal";
     private static final String MODE = "debug_white";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // 强制全屏
        getWindow().getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_FULLSCREEN |
                        View.SYSTEM_UI_FLAG_HIDE_NAVIGATION |
                        View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
        setContentView(R.layout.activity_main);

        // 设置保持屏幕常亮
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        getWindow().setColorMode(ActivityInfo.COLOR_MODE_WIDE_COLOR_GAMUT);
        Log.d(TAG, "getWindow().getColorMode(): " + getWindow().getColorMode());
        // 设置亮度为350nit 1deg
//        setScreenBrightness(0.76f);//1
//        setScreenBrightness(0.755f);//2
//        setScreenBrightness(0.758f);//3
//        setScreenBrightness(0.47f);//4
        setScreenBrightness(0.76f);//5



        //setScreenBrightness(0.8511f);//11
//        setScreenBrightness(0.7960f);//one plus
        //setScreenBrightness(0.8391f);//13

        //setScreenBrightness(1f);//full
        //setScreenBrightness(0.8551f);//2
        //setScreenBrightness(0.8361f);//mean

        //setScreenBrightness(0.8518f);//8**
        //setScreenBrightness(0.835f);//4
        //setScreenBrightness(0.8364f);//5
        //setScreenBrightness(0.835f);//4
        //setScreenBrightness(0.8439f);//3
        //setScreenBrightness(0.761f);//1
        // 设置亮度为350nit
        //setScreenBrightness(0.831f);//5
        //setScreenBrightness(0.830f);//4
        // 设置亮度为200nit
        //setScreenBrightness(0.735f);//5
        //setScreenBrightness(0.728f);//3、4
        //setScreenBrightness(0.73f);//2
        //setScreenBrightness(0.631f);//1





        imageView = findViewById(R.id.imageView);
        View rootView = findViewById(android.R.id.content);

        // 生成一个随机的index序列
        randomIndexes = generateRandomIndexes(TOTAL_IMAGES);

        // 初始显示第一张图片
        if (MODE.equals("debug_white")) {
            displayImageByNumber(71);
        } else {
            displayImage(currentIndex);
        }

        rootView.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if (event.getAction() == KeyEvent.ACTION_DOWN) {
                    if (MODE.equals("debug_white")) {
                        // debug_white: Enter 始终可用，永不退出
                        switch (keyCode) {
                            case KeyEvent.KEYCODE_ENTER:
                                nextImage();
                                return true;
                        }
                    } else if (currentIndex < TOTAL_IMAGES) {
                        switch (keyCode) {
                            case KeyEvent.KEYCODE_ENTER:
                                nextImage();
                                return true;
                        }
                    }
                }
                return false;
            }
        });

        rootView.setFocusableInTouchMode(true);
        rootView.requestFocus();
    }

    private List<Integer> generateRandomIndexes(int size) {
        List<Integer> indexes = new ArrayList<>();
        for (int i = 1; i <= size; i++) {
            indexes.add(i);
        }
        Collections.shuffle(indexes, new Random(System.currentTimeMillis()));
        return indexes;
    }

    private void displayImage(int imageIndex) {
        int resId = getResources().getIdentifier("image" + imageIndex, "drawable", getPackageName());
        if (resId != 0) {
            imageView.setImageResource(resId);
        }
    }

    private void nextImage() {
        if (MODE.equals("debug_white")) {
            // debug_white: 始终显示 image71，不退出
            displayImageByNumber(71);
            return;
        }
        if (currentIndex < TOTAL_IMAGES - 1) {
            currentIndex++;
            displayImage(currentIndex);
        } else {
            finish();
        }
    }

    private void displayImageByNumber(int imageNumber) {
        int resId = getResources().getIdentifier("image" + imageNumber, "drawable", getPackageName());
        if (resId != 0) {
            imageView.setImageResource(resId);
        }
    }

    private void setScreenBrightness(float brightnessValue) {
        WindowManager.LayoutParams layoutParams = getWindow().getAttributes();
        layoutParams.screenBrightness = brightnessValue;
        getWindow().setAttributes(layoutParams);
    }
}
