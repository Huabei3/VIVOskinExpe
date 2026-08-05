package com.example.fixedbrightness;



import static androidx.constraintlayout.helper.widget.MotionEffect.TAG;

import android.annotation.SuppressLint;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;

public class MainActivity extends AppCompatActivity {
    private ImageView imageView;
    private float currentBrightness = 0.66f;
    //private float currentBrightness = 0.753f;
    private static final float MAX_BRIGHTNESS = 1.0f;
    private static final float BRIGHTNESS_INCREMENT = 0.00f;
    private boolean isBrightnessMax = false;

    // 模式：729=calib729p3 图片, 96=calib96p3 image71
    private static final int MODE = 729;
//    private static final int MODE = 96;

    // 图片管理
    private int currentImageIndex = 0;
    private int totalImages = 2; // 非 final，模式切换时可变更
    private String[] imageNames = new String[totalImages];

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

        // 初始化图片名称
        setupImageNames();

//        x200
//        setScreenBrightness(0.76f);//1
//        setScreenBrightness(0.755f);//2
//        setScreenBrightness(0.758f);//3
//        setScreenBrightness(0.47f);//4
        setScreenBrightness(0.76f);//5



        //setScreenBrightness(0.8511f);//11
//        setScreenBrightness(0.795f);//12
        //setScreenBrightness(0.8391f);//13

        //setScreenBrightness(0.8551f);//2
        //setScreenBrightness(0.8555f);
        //setScreenBrightness(0.8361f);//mean
        //setScreenBrightness(0.8473f);//3

        // 设置亮度为350nit 1°
        //setScreenBrightness(0.8518f);//8**
        //setScreenBrightness(0.83985f);//8**
        //setScreenBrightness(0.8061f);//7**
        //setScreenBrightness(0.8384f);//6
        //setScreenBrightness(0.8364f);//5？？
        //setScreenBrightness(0.835f);//4
        //setScreenBrightness(0.8439f);//3
        //setScreenBrightness(0.8475f);//1

        // 初始设置亮度为0.05f
        //setScreenBrightness(currentBrightness);

        imageView = findViewById(R.id.imageView);
        View rootView = findViewById(android.R.id.content);

        // 设置根视图的背景颜色为黑色
        rootView.setBackgroundColor(getResources().getColor(android.R.color.black));

        // 显示第一张图片
        displayImage(currentImageIndex);

        rootView.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if (event.getAction() == KeyEvent.ACTION_DOWN) {
                    switch (keyCode) {
                        case KeyEvent.KEYCODE_ENTER:
                            if (isBrightnessMax) {
                                // 当前亮度已达到最大，播放下一张图片
                                nextImage();
                            } else {
                                // 增加亮度
                                increaseBrightness();
                            }
                            return true;
                    }
                }
                return false;
            }
        });

        rootView.setFocusableInTouchMode(true);
        rootView.requestFocus();
    }

    private void displayImage(int imageIndex) {
        // 获取对应图片资源
        @SuppressLint("DefaultLocale") int resId = getResources().getIdentifier(imageNames[imageIndex], "drawable", getPackageName());
        if (resId != 0) {
            imageView.setImageResource(resId);
        }
    }

    private void increaseBrightness() {
        if (currentBrightness < MAX_BRIGHTNESS) {
            currentBrightness += BRIGHTNESS_INCREMENT;
            if (currentBrightness >= MAX_BRIGHTNESS) {
                currentBrightness = MAX_BRIGHTNESS;
                isBrightnessMax = true;
            }
            setScreenBrightness(currentBrightness);
        }
    }

    private void nextImage() {
        if (currentImageIndex < totalImages - 1) {
            // 切换到下一张图片
//            currentImageIndex++;
            isBrightnessMax = false; // 重置亮度标志
            //currentBrightness = 0.05f; // 重置亮度为初始值
//            setScreenBrightness(currentBrightness); // 设置屏幕亮度
//            displayImage(currentImageIndex); // 显示下一张图片
        } else {
            // 最后一张图片亮度达到最大时退出应用
            finish();
        }
    }

    private void setScreenBrightness(float brightnessValue) {
        WindowManager.LayoutParams layoutParams = getWindow().getAttributes();
        layoutParams.screenBrightness = brightnessValue;
        getWindow().setAttributes(layoutParams);
    }

    private void setupImageNames() {
        if (MODE == 96) {
            totalImages = 1;
            imageNames = new String[]{"image96_71"};
        } else {
            // MODE=729: 保持原有逻辑
            totalImages = 2;
            imageNames = new String[totalImages];
            for (int i = 0; i < totalImages; i++) {
                imageNames[i] = "image" + i;
            }
        }
    }
}
