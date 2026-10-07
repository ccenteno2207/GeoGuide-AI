package com.geoguideai.geoguide_ai

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "geoguide/offline")
            .setMethodCallHandler { call, result ->
                if (call.method != "noBackupDirectory") {
                    result.notImplemented()
                } else {
                    try {
                        val root = noBackupFilesDir.canonicalFile
                        val directory = File(root, "geoguide_p9_cache").canonicalFile
                        check(directory.parentFile == root)
                        check(directory.isDirectory || directory.mkdirs())
                        result.success(directory.path)
                    } catch (_: Exception) {
                        result.error("CACHE_UNAVAILABLE", "Private cache unavailable", null)
                    }
                }
            }
    }
}
