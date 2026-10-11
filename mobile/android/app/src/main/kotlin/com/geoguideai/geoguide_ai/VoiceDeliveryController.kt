package com.geoguideai.geoguide_ai

internal data class VoiceToken(val eventId: String, val generation: Int, val revision: String, val expiresAt: Long)
internal interface VoiceOutput {
 fun available(): Boolean
 fun focus(token: VoiceToken, lost: () -> Unit): Boolean
 fun speak(text: String, token: VoiceToken): Boolean
 fun stop(): Boolean
 fun release()
 fun close()
}
/** Serialized on the Android main thread. No proximity, queue or retry logic. */
internal class VoiceDeliveryController(private val output: VoiceOutput, private val now: () -> Long) {
 private data class Flight(val token: VoiceToken, val ack: (String) -> Unit)
 private var flight: Flight? = null
 private var enabled = false
 private var closed = false
 private var unsafe = false
 val busy: Boolean get() = flight != null
 fun consent(value: Boolean) {
  enabled = value && !closed
  if (!enabled) finish("CANCELLED", true)
 }
 fun deliver(token: VoiceToken, text: String, ack: (String) -> Unit) {
  if (closed || !enabled || unsafe || !output.available() || flight != null) { ack("SUPPRESSED"); return }
  if (token.expiresAt <= now()) { ack("EXPIRED"); return }
  val current = Flight(token, ack)
  flight = current
  try {
   val granted = output.focus(token) { if (flight === current) finish("SUPPRESSED", true) }
   if (flight !== current) return
   if (!granted) { finish("SUPPRESSED", false); return }
   if (!output.speak(text, token)) finish("FAILED", true)
  } catch (_: Exception) { finish("FAILED", true) }
 }
 fun done(token: VoiceToken) {
  if (flight?.token == token) finish(if (token.expiresAt > now()) "DELIVERED" else "EXPIRED", false)
 }
 fun error(token: VoiceToken) { if (flight?.token == token) finish("FAILED", true) }
 fun cancel(eventId: String): Boolean {
  if (flight?.token?.eventId == eventId) finish("CANCELLED", true)
  return !unsafe
 }
 fun expire(token: VoiceToken) { if (flight?.token == token && token.expiresAt <= now()) finish("EXPIRED", true) }
 private fun finish(state: String, halt: Boolean) {
  val current = flight ?: return
  flight = null // Invalidate callbacks before stop/abandon, including reentrant callbacks.
  var result = state
  try { if (halt && !output.stop()) { unsafe = true; result = "FAILED" } }
  catch (_: Exception) { unsafe = true; result = "FAILED" }
  try { output.release() } catch (_: Exception) { unsafe = true; result = "FAILED" }
  if (unsafe) { try { output.close() } catch (_: Exception) { /* Remain blocked. */ } }
  current.ack(result)
 }
 fun close() {
  if (closed) return
  closed = true; enabled = false
  try { finish("CANCELLED", true) } finally { output.close() }
 }
}
