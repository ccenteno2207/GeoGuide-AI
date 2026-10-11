package com.geoguideai.geoguide_ai

/** One isolated diagnostic. Reuses C2 delivery/focus and never owns location or POIs. */
internal class VoiceDiagnosticController(
 private val output: VoiceOutput,
 private val now: () -> Long,
 private val result: (String) -> Unit,
) {
 companion object {
  fun allowed(debug: Boolean, visible: Boolean, consent: Boolean, routeBusy: Boolean, busy: Boolean) = debug && visible && consent && !routeBusy && !busy
 }
 private var terminal = false
 private var started = false
 private var reason = "ERROR"
 private val token = VoiceToken("debug-voice", 0, "diagnostic", now() + 30000)
 private val observed = object : VoiceOutput by output {
  override fun focus(token: VoiceToken, lost: () -> Unit): Boolean {
   val granted = output.focus(token) { reason = "FOCUS_LOST"; lost() }
   if (!granted) reason = "FOCUS_DENIED"
   return granted
  }
 }
 private val core = VoiceDeliveryController(observed, now)
 fun ready(state: String) {
  if (terminal || started) return
  when (state) {
   "READY" -> { started = true; core.consent(true); core.deliver(token, "CEFI: prueba de voz") { finish(when (it) { "DELIVERED" -> "COMPLETED"; "CANCELLED" -> "CANCELLED"; "SUPPRESSED" -> reason; else -> "ERROR" }) } }
   "NO_SPANISH_VOICE", "ERROR" -> finish(state)
  }
 }
 fun done(token: VoiceToken) = core.done(token)
 fun error(token: VoiceToken) = core.error(token)
 fun cancel() { if (terminal) return; if (started) core.cancel(token.eventId) else finish("CANCELLED") }
 fun timeout() { if (!terminal) { if (started) core.cancel(token.eventId) else finish("ERROR") } }
 private fun finish(state: String) {
  if (terminal) return
  terminal = true
  var finalState = state
  try { core.close() } catch (_: Exception) { finalState = "ERROR" }
  result(finalState)
 }
}
