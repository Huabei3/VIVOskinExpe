package com.example.calib729p3;



import static androidx.constraintlayout.helper.widget.MotionEffect.TAG;

import android.content.pm.ActivityInfo;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.Display;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import androidx.appcompat.app.AppCompatActivity;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.reflect.Field;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Random;

public class MainActivity extends AppCompatActivity {
    private ImageView imageView;
    private int currentIndex = 0; // 默认从第0张开始
    private List<Integer> randomIndexes;
    private static final int TOTAL_IMAGES = 729;

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

//        setScreenBrightness(0.76f);//1
//        setScreenBrightness(0.755f);//2
//        setScreenBrightness(0.758f);//3
//        setScreenBrightness(0.47f);//4
        setScreenBrightness(0.76f); //5



        //setScreenBrightness(0.8511f);//11
        // setScreenBrightness(0.7710f);//12
//        setScreenBrightness(0.7960f);//one plus
        //setScreenBrightness(0.8391f);//13

        //setScreenBrightness(1f);//mean
        //setScreenBrightness(0.8361f);//mean
        //setScreenBrightness(0.8551f);//2
        //350
        //setScreenBrightness(0.8518f);//8**
        //setScreenBrightness(0.8364f);//5
        //setScreenBrightness(0.835f);//4
        //setScreenBrightness(0.8439f);//3
        //setScreenBrightness(0.761f);//1
        //350
        //setScreenBrightness(0.831f);//5
        //setScreenBrightness(0.830f);//4
        //setScreenBrightness(0.8345f);//3
        // 设置亮度为50%
        //setScreenBrightness(0.735f);//5
        //setScreenBrightness(0.728f);//3、4
        //setScreenBrightness(0.73f);//2
        //setScreenBrightness(0.631f);//1

        imageView = findViewById(R.id.imageView);
        View rootView = findViewById(android.R.id.content);

        // 生成一个随机的index序列
        randomIndexes = generateRandomIndexes(TOTAL_IMAGES);

        // 设置起始图片索引（可以修改这个值来从指定图片开始）
        setStartingImageIndex(0); // 这里设置为0，可以修改为其他值（0到728之间）
        
        // 显示起始图片
        displayImage(currentIndex);
        
        // 自动循环调用nextImage()方法n-1次，以从起始位置前进到第n张图片
        int n = 1; // 这里设置为1，表示从第1张开始，不需要跳转。如果想从第5张开始，设置为5
        autoAdvanceToNthImage(n);

        rootView.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if (event.getAction() == KeyEvent.ACTION_DOWN && (currentIndex < TOTAL_IMAGES)) {
                    switch (keyCode) {
                        case KeyEvent.KEYCODE_ENTER:
                            nextImage();
                            return true;
                    }
                }
                return false;
            }
        });

        rootView.setFocusableInTouchMode(true);
        rootView.requestFocus();
        // 检查设备是否支持广色域显示

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
        if (currentIndex < TOTAL_IMAGES - 1) {
            currentIndex++;
            displayImage(currentIndex);
        } else {
            finish(); // 结束当前活动
        }
    }

    private void setScreenBrightness(float brightnessValue) {
        WindowManager.LayoutParams layoutParams = getWindow().getAttributes();
        layoutParams.screenBrightness = brightnessValue;
        getWindow().setAttributes(layoutParams);
    }
    
    /**
     * 设置起始图片索引
     * @param startIndex 要开始播放的图片索引（0到TOTAL_IMAGES-1）
     */
    private void setStartingImageIndex(int startIndex) {
        // 确保起始索引在有效范围内
        if (startIndex >= 0 && startIndex < TOTAL_IMAGES) {
            currentIndex = startIndex;
        } else {
            Log.w(TAG, "起始索引无效，使用默认值0。索引范围应该是0到" + (TOTAL_IMAGES - 1));
            currentIndex = 0;
        }
    }
    
    /**
     * 自动前进到第n张图片
     * @param n 目标图片序号（从1开始计数）
     */
    private void autoAdvanceToNthImage(int n) {
        if (n <= 1) {
            // 如果n小于等于1，不需要跳转
            return;
        }
        
        // 计算需要跳转的次数
        int advanceCount = n - 1;
        
        // 循环调用nextImage()方法n-1次
        for (int i = 0; i < advanceCount && currentIndex < TOTAL_IMAGES - 1; i++) {
            nextImage();
        }
    }
}
