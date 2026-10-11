package com.geoguideai.geoguide_ai

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener

/** Offline Spanish voice only. Main-thread ownership, no logs or synthesized files. */
internal class AndroidVoiceOutput(context: Context, private val handler: Handler) : VoiceOutput {
 private val audio = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
 private val attributes = AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_ASSISTANCE_NAVIGATION_GUIDANCE).setContentType(AudioAttributes.CONTENT_TYPE_SPEECH).build()
 private var tts: TextToSpeech? = null
 private var ready = false
 private var closed = false
 private var focusRequest: AudioFocusRequest? = null
 private var listener: AudioManager.OnAudioFocusChangeListener? = null
 private var utterance: Pair<String, VoiceToken>? = null
 private var sequence = 0L
 var completed: (VoiceToken) -> Unit = {}
 var failed: (VoiceToken) -> Unit = {}
 init {
  tts = TextToSpeech(context.applicationContext) { status -> handler.post {
   if (closed) return@post
   val engine = tts ?: return@post
   if (status != TextToSpeech.SUCCESS) return@post
   try {
    val voice = engine.voices?.filter { it.locale.language == "es" && !it.isNetworkConnectionRequired && !it.features.orEmpty().contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED) }
     ?.sortedWith(compareBy({ if (it.locale.country == "PE") 0 else 1 }, { it.name }))?.firstOrNull()
    if (voice == null || engine.setVoice(voice) != TextToSpeech.SUCCESS) return@post
    if (engine.setAudioAttributes(attributes) != TextToSpeech.SUCCESS) return@post
    engine.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
     override fun onStart(id: String?) {}
     override fun onDone(id: String?) { handler.post { val item = utterance; if (!closed && item != null && item.first == id) { utterance = null; completed(item.second) } } }
     @Deprecated("Legacy TTS callback") override fun onError(id: String?) { error(id) }
     override fun onError(id: String?, code: Int) { error(id) }
     override fun onStop(id: String?, interrupted: Boolean) { error(id) }
     private fun error(id: String?) { handler.post { val item = utterance; if (!closed && item != null && item.first == id) { utterance = null; failed(item.second) } } }
    })
    ready = true
   } catch (_: Exception) { ready = false }
  } }
 }
 override fun available() = ready && !closed
 override fun focus(token: VoiceToken, lost: () -> Unit): Boolean {
  val callback = AudioManager.OnAudioFocusChangeListener { change -> if (change < 0) lost() }
  listener = callback
  return if (Build.VERSION.SDK_INT >= 26) {
   val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK).setAudioAttributes(attributes)
    .setAcceptsDelayedFocusGain(false).setWillPauseWhenDucked(true).setOnAudioFocusChangeListener(callback, handler).build()
   focusRequest = request
   audio.requestAudioFocus(request) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
  } else {
   @Suppress("DEPRECATION")
   (audio.requestAudioFocus(callback, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED)
  }
 }
 override fun speak(text: String, token: VoiceToken): Boolean {
  if (!available()) return false
  val id = "cefi-${++sequence}-${token.eventId}"
  utterance = id to token
  return tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, id) == TextToSpeech.SUCCESS
 }
 override fun stop(): Boolean { utterance = null; return tts?.stop() == TextToSpeech.SUCCESS || tts == null }
 override fun release() {
  val request = focusRequest; val callback = listener
  val released = if (Build.VERSION.SDK_INT >= 26 && request != null) audio.abandonAudioFocusRequest(request)
  else if (callback != null) { @Suppress("DEPRECATION") (audio.abandonAudioFocus(callback)) }
  else AudioManager.AUDIOFOCUS_REQUEST_GRANTED
  if (released != AudioManager.AUDIOFOCUS_REQUEST_GRANTED) throw IllegalStateException("Focus release unconfirmed")
  focusRequest = null; listener = null
 }
 override fun close() { closed = true; ready = false; utterance = null; try { tts?.stop() } finally { try { release() } finally { tts?.shutdown(); tts = null } } }
}
