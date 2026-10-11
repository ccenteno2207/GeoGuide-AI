package com.geoguideai.geoguide_ai

import android.Manifest
import android.app.*
import android.content.*
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.location.*
import android.os.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.FlutterInjector
import io.flutter.plugin.common.MethodChannel

internal object RouteSessionBridge {
 var service: RouteSessionService? = null
 var snapshot: ByteArray? = null
 var pending: MethodChannel.Result? = null
 var ui: MethodChannel? = null
 var interrupted = false
 fun state(active: Boolean, failed: Boolean = false) { interrupted = failed; ui?.invokeMethod("state", mapOf("active" to active, "interrupted" to failed)) }
}
class RouteSessionService : Service(), LocationListener {
 private val handler = Handler(Looper.getMainLooper())
 private var engine: FlutterEngine? = null
 private var worker: MethodChannel? = null
 private lateinit var locations: LocationManager
 private var listening = false
 private var preciseProducer = false
 private var ended = false
 private var ready = false
 val isReady: Boolean get() = ready && !ended
 private val deadline = Runnable { if (!ready) terminate("START_FAILED") }
 private val audit = object : Runnable {
  override fun run() {
   if (ended) return
   if (!allowed()) { terminate("PERMISSION_REVOKED"); return }
   handler.postDelayed(this, 3000)
  }
 }
 override fun onBind(intent: Intent?) = null
 override fun onCreate() {
  super.onCreate()
  locations = getSystemService(LOCATION_SERVICE) as LocationManager
  RouteSessionBridge.service = this
 }
 private fun allowed(): Boolean {
  val coarse = checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
  val fine = checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
  val enabled = if (Build.VERSION.SDK_INT >= 28) locations.isLocationEnabled else locations.isProviderEnabled(LocationManager.GPS_PROVIDER) || locations.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
  val notifications = getSystemService(NotificationManager::class.java).areNotificationsEnabled()
  if (listening && !B1Policy.producerPermissionValid(preciseProducer, fine)) return false
  return B1Policy.canContinue(Build.VERSION.SDK_INT, coarse, fine, enabled, notifications, Build.VERSION.SDK_INT < 33 || checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED)
 }
 override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
  if (intent?.action == "STOP") { terminate(null); return START_NOT_STICKY }
  if (engine != null) return START_NOT_STICKY
  if (RouteSessionBridge.snapshot == null || !allowed()) { terminate("START_DENIED"); return START_NOT_STICKY }
  try {
   val nm = getSystemService(NotificationManager::class.java)
   if (Build.VERSION.SDK_INT >= 26) nm.createNotificationChannel(NotificationChannel("route_session", "Recorrido activo", NotificationManager.IMPORTANCE_LOW))
   val stop = PendingIntent.getService(this, 10, Intent(this, RouteSessionService::class.java).setAction("STOP"), PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
   val open = PendingIntent.getActivity(this, 11, Intent(this, MainActivity::class.java), PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
   val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(this, "route_session") else Notification.Builder(this)
   val notification = builder.setSmallIcon(android.R.drawable.ic_menu_mylocation).setContentTitle("GeoGuide AI — recorrido activo")
    .setContentText("Ubicación activa. Detén la sesión al finalizar.").setOngoing(true).setContentIntent(open).addAction(android.R.drawable.ic_delete, "Detener", stop).build()
   if (Build.VERSION.SDK_INT >= 29) startForeground(41, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION) else startForeground(41, notification)
   val flutter = FlutterEngine(this)
   engine = flutter
   val channel = MethodChannel(flutter.dartExecutor.binaryMessenger, "geoguide/route_worker")
   worker = channel
   channel.setMethodCallHandler { call, result ->
    if (ended) { result.error("STOPPED", "Session stopped", null); return@setMethodCallHandler }
    try {
     when (call.method) {
      "snapshot" -> result.success(RouteSessionBridge.snapshot)
      "begin" -> { begin(); result.success(null) }
      "end" -> { endLocation(); result.success(null); if (ready) handler.post { terminate(null) } }
      "ready" -> { ready = true; handler.removeCallbacks(deadline); RouteSessionBridge.snapshot = null; RouteSessionBridge.pending?.success(null); RouteSessionBridge.pending = null; RouteSessionBridge.state(true); result.success(null) }
      "publish" -> { if (ready && allowed()) RouteSessionBridge.ui?.invokeMethod("sample", call.arguments); result.success(null) }
      "finish" -> { result.success(null); handler.post { terminate(null) } }
      else -> result.notImplemented()
     }
    } catch (_: Exception) { result.error("SESSION_FAILED", "Session unavailable", null); terminate("SESSION_FAILED") }
   }
   val loader = FlutterInjector.instance().flutterLoader()
   loader.startInitialization(this); loader.ensureInitializationComplete(this, null)
   flutter.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "b1RouteSessionMain"))
   handler.postDelayed(deadline, 10000); handler.post(audit)
  } catch (_: Exception) { terminate("START_FAILED") }
  return START_NOT_STICKY
 }
 private fun begin() {
  if (listening) return
  if (!allowed()) throw SecurityException()
  // One platform subscription, no GMS/commercial dependency. Experimental cadence.
  val fine = checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
  val provider = if (fine && locations.isProviderEnabled(LocationManager.GPS_PROVIDER)) LocationManager.GPS_PROVIDER else LocationManager.NETWORK_PROVIDER
  if (!locations.isProviderEnabled(provider)) throw IllegalStateException()
  preciseProducer = provider == LocationManager.GPS_PROVIDER
  locations.requestLocationUpdates(provider, 5000L, 5f, this, Looper.getMainLooper())
  listening = true
 }
 private fun endLocation() { if (listening) locations.removeUpdates(this); listening = false; preciseProducer = false }
 override fun onLocationChanged(location: Location) {
  if (ended || !listening || !allowed()) { if (!ended) terminate("PERMISSION_REVOKED"); return }
  val sample = mapOf("latitude" to location.latitude, "longitude" to location.longitude, "timestamp" to location.time,
   "accuracy" to location.accuracy.toDouble(), "heading" to if (location.hasBearing()) location.bearing.toDouble() else null,
   "headingAccuracy" to if (Build.VERSION.SDK_INT >= 26 && location.hasBearingAccuracy()) location.bearingAccuracyDegrees.toDouble() else null,
   "speed" to if (location.hasSpeed()) location.speed.toDouble() else null,
   "speedAccuracy" to if (Build.VERSION.SDK_INT >= 26 && location.hasSpeedAccuracy()) location.speedAccuracyMetersPerSecond.toDouble() else null)
  worker?.invokeMethod("sample", sample)
 }
 override fun onProviderDisabled(provider: String) { terminate("LOCATION_DISABLED") }
 override fun onProviderEnabled(provider: String) {}
 @Deprecated("Legacy Android callback") override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
 override fun onTaskRemoved(rootIntent: Intent?) { terminate(null) }
 fun terminate(code: String?) {
  if (ended) return
  ended = true
  handler.removeCallbacksAndMessages(null)
  try { endLocation() } catch (_: Exception) { listening = false; preciseProducer = false }
  RouteSessionBridge.snapshot = null
  RouteSessionBridge.pending?.error(code ?: "STOPPED", "Session stopped", null); RouteSessionBridge.pending = null
  RouteSessionBridge.state(false, code != null)
  RouteSessionBridge.service = null
  worker?.setMethodCallHandler(null); worker = null
  val old = engine; engine = null
  // Let any in-flight channel result return before destroying its engine.
  Handler(Looper.getMainLooper()).post { old?.destroy() }
  stopForeground(STOP_FOREGROUND_REMOVE); stopSelf()
 }
 override fun onDestroy() { terminate(null); super.onDestroy() }
}
