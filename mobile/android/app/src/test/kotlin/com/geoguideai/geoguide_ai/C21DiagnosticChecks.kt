package com.geoguideai.geoguide_ai

object C21DiagnosticChecks {
 private var checks = 0
 private fun verify(value: Boolean) { check(value) { "Diagnostic assertion ${checks + 1}" }; checks++ }
 private class Fake : VoiceOutput {
  var granted = true; var speakOk = true; var stopOk = true
  var speaks = 0; var stops = 0; var closes = 0; var releases = 0
  var token: VoiceToken? = null; var text = ""; var lost: () -> Unit = {}
  override fun available() = true
  override fun focus(token: VoiceToken, lost: () -> Unit): Boolean { this.lost = lost; return granted }
  override fun speak(text: String, token: VoiceToken): Boolean { speaks++; this.token = token; this.text = text; return speakOk }
  override fun stop(): Boolean { stops++; return stopOk }
  override fun release() { releases++ }
  override fun close() { closes++ }
 }
 @JvmStatic fun main(args: Array<String>) {
  verify(VoiceDiagnosticController.allowed(true,true,true,false,false))
  verify(!VoiceDiagnosticController.allowed(false,true,true,false,false))
  verify(!VoiceDiagnosticController.allowed(true,false,true,false,false))
  verify(!VoiceDiagnosticController.allowed(true,true,false,false,false))
  verify(!VoiceDiagnosticController.allowed(true,true,true,true,false))
  verify(!VoiceDiagnosticController.allowed(true,true,true,false,true))
  fun scenario(run: (Fake, VoiceDiagnosticController, MutableList<String>) -> Unit) {
   val out = Fake(); val states = mutableListOf<String>(); val core = VoiceDiagnosticController(out, {1000L}, states::add)
   run(out, core, states); core.cancel(); verify(out.closes >= 1)
  }
  scenario { out, core, states ->
   core.ready("INITIALIZING"); verify(out.speaks == 0)
   core.ready("READY"); core.ready("READY"); verify(out.speaks == 1); verify(out.text == "CEFI: prueba de voz")
   core.done(out.token!!.copy(revision="wrong")); verify(states.isEmpty())
   core.done(out.token!!); verify(states == listOf("COMPLETED")); verify(out.releases == 1)
   core.done(out.token!!); core.ready("READY"); verify(states.size == 1); verify(out.speaks == 1)
  }
  scenario { out, core, states -> core.cancel(); core.ready("READY"); verify(states == listOf("CANCELLED")); verify(out.speaks == 0) }
  scenario { out, core, states -> core.ready("READY"); core.cancel(); core.done(out.token!!); core.error(out.token!!); verify(states == listOf("CANCELLED")); verify(out.stops == 1); verify(out.releases == 1) }
  scenario { out, core, states -> out.granted=false; core.ready("READY"); verify(states == listOf("FOCUS_DENIED")); verify(out.speaks == 0); verify(out.releases == 1) }
  scenario { out, core, states -> core.ready("READY"); out.lost(); core.done(out.token!!); verify(states == listOf("FOCUS_LOST")); verify(out.stops == 1) }
  scenario { out, core, states -> core.ready("NO_SPANISH_VOICE"); verify(states == listOf("NO_SPANISH_VOICE")); verify(out.speaks == 0) }
  scenario { out, core, states -> core.ready("ERROR"); verify(states == listOf("ERROR")); verify(out.speaks == 0) }
  scenario { out, core, states -> out.speakOk=false; core.ready("READY"); verify(states == listOf("ERROR")); verify(out.releases == 1) }
  scenario { out, core, states -> out.stopOk=false; core.ready("READY"); core.cancel(); verify(states == listOf("ERROR")) }
  scenario { out, core, states -> core.timeout(); core.ready("READY"); verify(states == listOf("ERROR")); verify(out.speaks == 0) }
  println("C2.1 diagnostic checks PASS ($checks assertions)")
 }
}
