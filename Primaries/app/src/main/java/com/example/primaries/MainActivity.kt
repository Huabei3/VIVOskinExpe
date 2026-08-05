package com.example.primaries

import android.content.pm.ActivityInfo
import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    companion object {
        private val IMAGE_NAMES = arrayOf(
            "image0", "image8", "image72", "image648", "image728"
        )
    }

    private lateinit var imageView: ImageView
    private var currentIndex = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Full-screen immersive sticky mode
        window.decorView.systemUiVisibility = (
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
            or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
            or View.SYSTEM_UI_FLAG_FULLSCREEN
        )

        // Keep screen on
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        // Wide Color Gamut
        window.colorMode = ActivityInfo.COLOR_MODE_WIDE_COLOR_GAMUT

        // Screen brightness calibration

//        x200
//        setScreenBrightness(0.76f);//1
//        setScreenBrightness(0.755f);//2
//        setScreenBrightness(0.758f);//3
//        setScreenBrightness(0.47f);//4
        setScreenBrightness(0.76f) //5




//        setScreenBrightness(0.7960f)

        setContentView(R.layout.activity_main)
        imageView = findViewById(R.id.imageView)

        // Display the first image
        displayImage(currentIndex)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_ENTER) {
            nextImage()
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    private fun displayImage(imageIndex: Int) {
        val resId = resources.getIdentifier(
            IMAGE_NAMES[imageIndex], "drawable", packageName
        )
        imageView.setImageResource(resId)
    }

    private fun nextImage() {
        currentIndex++
        if (currentIndex >= IMAGE_NAMES.size) {
            // All 4 images displayed, exit
            finish()
        } else {
            displayImage(currentIndex)
        }
    }

    private fun setScreenBrightness(brightness: Float) {
        val layoutParams = window.attributes
        layoutParams.screenBrightness = brightness
        window.attributes = layoutParams
    }
}
