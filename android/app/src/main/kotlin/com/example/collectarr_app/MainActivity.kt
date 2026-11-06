package com.example.collectarr_app

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val ocrThread = Executors.newSingleThreadExecutor()
    private val mainThread = Handler(Looper.getMainLooper())
    private var coverTextRecognizer: CoverTextRecognizer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "collectarr/cover_ocr")
            .setMethodCallHandler { call, result ->
                if (call.method != "read") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val path = call.argument<String>("path")!!
                ocrThread.execute {
                    try {
                        val recognizer = coverTextRecognizer
                            ?: CoverTextRecognizer(assets).also { coverTextRecognizer = it }
                        val text = recognizer.read(path)
                        mainThread.post { result.success(text) }
                    } catch (error: Throwable) {
                        mainThread.post { result.error("cover_ocr", error.toString(), null) }
                    }
                }
            }
    }
}
