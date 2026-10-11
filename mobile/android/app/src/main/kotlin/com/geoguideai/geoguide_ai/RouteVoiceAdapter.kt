package com.geoguideai.geoguide_ai

import android.content.Context
import android.os.Handler
import io.flutter.plugin.common.MethodChannel

internal class RouteVoiceAdapter(context: Context, private val handler: Handler) {
 private var output: AndroidVoiceOutput? = null
 private var controller: VoiceDeliveryController? = null
 private var deadline: Runnable? = null
 fun consent(enabled: Boolean) {
  if (enabled && controller == null) {
   try {
    val out = AndroidVoiceOutput(context, handler)
    val core = VoiceDeliveryController(out, System::currentTimeMillis)
    out.completed = core::done; out.failed = core::error
    output = out; controller = core
   } catch (_: Exception) { output = null; controller = null }
  }
  controller?.consent(enabled)
 }
 private val context = context.applicationContext
 fun deliver(data: Map<*, *>, result: MethodChannel.Result) {
  val id = data["eventId"] as? String ?: throw IllegalArgumentException()
  val generation = (data["generation"] as? Number)?.toInt() ?: throw IllegalArgumentException()
  val revision = data["snapshotRevision"] as? String ?: throw IllegalArgumentException()
  val expiry = (data["expiresAt"] as? Number)?.toLong() ?: throw IllegalArgumentException()
  val name = (data["name"] as? String)?.replace(Regex("[\\p{Cntrl}]"), " ")?.trim()?.take(120) ?: throw IllegalArgumentException()
  val token = VoiceToken(id, generation, revision, expiry)
  val ack: (String) -> Unit = { state ->
   result.success(mapOf("eventId" to id, "generation" to generation, "snapshotRevision" to revision, "state" to state))
  }
  val core = controller
  if (core == null || core.busy || name.isEmpty()) { ack("SUPPRESSED"); return }
  val task = Runnable { core.expire(token) }
  deadline?.let(handler::removeCallbacks); deadline = task
  handler.postDelayed(task, (expiry - System.currentTimeMillis()).coerceAtLeast(0))
  core.deliver(token, "CEFI. Lugar cercano: $name.") { state -> handler.removeCallbacks(task); if (deadline === task) deadline = null; ack(state) }
 }
 fun cancel(id: String): Boolean = controller?.cancel(id) ?: true
 fun close() { deadline?.let(handler::removeCallbacks); deadline = null; try { controller?.close() } finally { controller = null; output = null } }
}
