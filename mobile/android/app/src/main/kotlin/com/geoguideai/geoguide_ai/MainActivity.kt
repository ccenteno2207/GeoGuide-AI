package com.geoguideai.geoguide_ai

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val diagnostic by lazy { VoiceDiagnosticAdapter(this, android.os.Handler(android.os.Looper.getMainLooper())) }
    private val diagnosticDebug get() = applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE != 0
    private var visible = false
    private var permissionResult: MethodChannel.Result? = null
    private var routeChannel: MethodChannel? = null
    override fun onResume() { super.onResume(); visible = true; RouteSessionBridge.ui = routeChannel }
    override fun onPause() { visible = false; diagnostic.cancel(); super.onPause() }
    override fun onDestroy() {
        if (RouteSessionBridge.ui === routeChannel) RouteSessionBridge.ui = null
        permissionResult?.error("CANCELLED", "Activity unavailable", null); permissionResult = null
        diagnostic.cancel()
        super.onDestroy()
    }
    private fun startRoute(bytes: ByteArray, result: MethodChannel.Result) {
        if (!B1Policy.canStart(visible, RouteSessionBridge.service != null || RouteSessionBridge.pending != null || permissionResult != null || diagnostic.busy, bytes.size)) { result.error("SESSION_UNAVAILABLE", "Session unavailable", null); return }
        RouteSessionBridge.interrupted = false
        RouteSessionBridge.snapshot = bytes; RouteSessionBridge.pending = result
        try {
            val intent = android.content.Intent(this, RouteSessionService::class.java)
            if (android.os.Build.VERSION.SDK_INT >= 26) startForegroundService(intent) else startService(intent)
        } catch (_: Exception) { RouteSessionBridge.snapshot = null; RouteSessionBridge.pending = null; result.error("START_FAILED", "Session unavailable", null) }
    }
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 812) { permissionResult?.success(null); permissionResult = null }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "geoguide/voice_diagnostic").setMethodCallHandler { call, result ->
            if (!diagnosticDebug) result.notImplemented()
            else when (call.method) {
                "start" -> {
                    val routeBusy = RouteSessionBridge.service != null || RouteSessionBridge.pending != null || permissionResult != null
                    if (!VoiceDiagnosticController.allowed(diagnosticDebug, visible, RouteSessionBridge.voiceConsent, routeBusy, diagnostic.busy)) result.success("UNAVAILABLE")
                    else diagnostic.start(result)
                }
                "stop" -> { diagnostic.cancel(); result.success(null) }
                else -> result.notImplemented()
            }
        }
        routeChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "geoguide/route_session")
        RouteSessionBridge.ui = routeChannel
        routeChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val bytes = call.arguments as? ByteArray
                    if (bytes == null || bytes.size > 5242880) result.error("ROUTE_INVALID", "Route unavailable", null)
                    else startRoute(bytes, result)
                }
                "stop" -> { RouteSessionBridge.service?.terminate(null); RouteSessionBridge.snapshot = null; RouteSessionBridge.interrupted = false; result.success(null) }
                "voiceConsent" -> {
                    if (!visible) result.error("ACTIVITY_UNAVAILABLE", "Visible Activity required", null)
                    else {
                        val enabled = call.arguments == true
                        if (!enabled) diagnostic.cancel()
                        RouteSessionBridge.voiceConsent = enabled
                        RouteSessionBridge.service?.voiceConsent(enabled)
                        result.success(enabled)
                    }
                }
                "voiceState" -> result.success(RouteSessionBridge.voiceConsent)
                "active" -> result.success(mapOf("active" to (RouteSessionBridge.service != null || RouteSessionBridge.pending != null), "interrupted" to RouteSessionBridge.interrupted, "starting" to (RouteSessionBridge.pending != null)))
                "permissions" -> {
                    if (!visible || permissionResult != null) result.error("ACTIVITY_UNAVAILABLE", "Visible Activity required", null)
                    else {
                        val needed = mutableListOf<String>()
                        if (checkSelfPermission(android.Manifest.permission.ACCESS_COARSE_LOCATION) != android.content.pm.PackageManager.PERMISSION_GRANTED) {
                            needed.add(android.Manifest.permission.ACCESS_COARSE_LOCATION); needed.add(android.Manifest.permission.ACCESS_FINE_LOCATION)
                        }
                        if (android.os.Build.VERSION.SDK_INT >= 33 && checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) != android.content.pm.PackageManager.PERMISSION_GRANTED) needed.add(android.Manifest.permission.POST_NOTIFICATIONS)
                        if (needed.isEmpty()) result.success(null) else { permissionResult = result; requestPermissions(needed.toTypedArray(), 812) }
                    }
                }
                else -> result.notImplemented()
            }
        }

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
