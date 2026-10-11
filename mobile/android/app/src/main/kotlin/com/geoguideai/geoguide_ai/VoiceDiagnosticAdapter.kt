package com.geoguideai.geoguide_ai

import android.content.Context
import android.os.Handler
import io.flutter.plugin.common.MethodChannel

/** Activity-only, bounded to 30 seconds including local TTS initialization. */
internal class VoiceDiagnosticAdapter(private val context: Context, private val handler: Handler) {
 private var controller: VoiceDiagnosticController? = null
 private var poll: Runnable? = null
 val busy get() = controller != null
 fun start(result: MethodChannel.Result) {
  if (busy) { result.success("UNAVAILABLE"); return }
  var output: AndroidVoiceOutput? = null
  try {
   val created = AndroidVoiceOutput(context, handler)
   output = created
   val deadline = android.os.SystemClock.elapsedRealtime() + 30000
   val core = VoiceDiagnosticController(created, android.os.SystemClock::elapsedRealtime) { state ->
    poll?.let(handler::removeCallbacks); poll = null; controller = null
    result.success(state)
   }
   controller = core; created.completed = core::done; created.failed = core::error
   val task = object : Runnable {
    override fun run() {
     if (controller !== core) return
     if (android.os.SystemClock.elapsedRealtime() >= deadline) core.timeout() else core.ready(created.initialization)
     if (controller === core) handler.postDelayed(this, 100)
    }
   }
   poll = task; handler.post(task)
  } catch (_: Exception) {
   val active = controller
   if (active != null) active.cancel() else { try { output?.close() } catch (_: Exception) {} ; result.success("ERROR") }
  }
 }
 fun cancel() { controller?.cancel() }
}
