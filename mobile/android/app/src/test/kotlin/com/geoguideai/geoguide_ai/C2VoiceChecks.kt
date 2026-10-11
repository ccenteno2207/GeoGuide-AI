package com.geoguideai.geoguide_ai

object C2VoiceChecks {
 private var checks = 0
 private fun verify(value: Boolean) { check(value) { "C2 assertion ${checks + 1}" }; checks++ }
 private class Fake : VoiceOutput {
  var ready = true; var granted = true; var speakOk = true; var stopOk = true
  var focusCalls = 0; var speaks = 0; var stops = 0; var releases = 0; var closes = 0
  var lost: () -> Unit = {}
  var throwFocus = false; var throwSpeak = false; var throwRelease = false
  override fun available() = ready
  override fun focus(token: VoiceToken, lost: () -> Unit): Boolean { focusCalls++; this.lost = lost; if (throwFocus) error("focus"); return granted }
  override fun speak(text: String, token: VoiceToken): Boolean { speaks++; if (throwSpeak) error("speak"); return speakOk }
  override fun stop(): Boolean { stops++; return stopOk }
  override fun release() { releases++; if (throwRelease) error("release") }
  override fun close() { closes++ }
 }
 @JvmStatic fun main(args: Array<String>) {
  var time = 1000L
  val a = VoiceToken("a", 1, "r1", 2000L)
  val b = VoiceToken("b", 2, "r2", 3000L)
  fun scenario(run: (Fake, VoiceDeliveryController, MutableList<String>) -> Unit) {
   time = 1000L
   val out = Fake(); val core = VoiceDeliveryController(out) { time }; val states = mutableListOf<String>()
   run(out, core, states)
   core.close()
  }
  scenario { out, core, states ->
   core.deliver(a, "POI", states::add); verify(states == listOf("SUPPRESSED")); verify(out.speaks == 0); verify(out.focusCalls == 0)
  }
  scenario { out, core, states ->
   core.consent(true); core.deliver(a, "POI", states::add)
   verify(states.isEmpty()); verify(out.speaks == 1); verify(out.focusCalls == 1)
   core.deliver(b, "POI", states::add); verify(states == listOf("SUPPRESSED")); verify(out.speaks == 1)
   core.done(a.copy(generation = 2)); verify(states.size == 1)
   core.done(a.copy(revision = "wrong")); verify(states.size == 1)
   core.done(a); verify(states.last() == "DELIVERED"); verify(out.releases == 1)
   core.done(a); verify(states.size == 2)
  }
  scenario { out, core, states ->
   out.granted = false; core.consent(true); core.deliver(a, "POI", states::add)
   verify(states.single() == "SUPPRESSED"); verify(out.speaks == 0); verify(out.releases == 1)
   out.lost(); verify(states.size == 1)
  }
  scenario { out, core, states ->
   core.consent(true); core.deliver(a, "POI", states::add); val oldLoss = out.lost
   out.lost(); verify(states.single() == "SUPPRESSED"); verify(out.stops == 1); verify(out.releases == 1)
   core.done(a); verify(states.size == 1)
   core.deliver(b, "POI", states::add); oldLoss(); verify(states.size == 1)
   core.done(b); verify(states.last() == "DELIVERED")
  }
  scenario { out, core, states ->
   core.consent(true); core.deliver(a, "POI", states::add); core.consent(false)
   verify(states.single() == "CANCELLED"); verify(out.stops == 1); verify(out.releases == 1)
   core.done(a); verify(states.size == 1)
   core.deliver(b, "POI", states::add); verify(states.last() == "SUPPRESSED"); verify(out.speaks == 1)
   core.consent(true); verify(out.speaks == 1)
  }
  scenario { out, core, states ->
   core.consent(true); core.deliver(a, "POI", states::add)
   verify(core.cancel("wrong")); verify(states.isEmpty())
   verify(core.cancel("a")); verify(states.single() == "CANCELLED"); verify(out.releases == 1)
   core.done(a); verify(states.size == 1)
  }
  scenario { out, core, states ->
   core.consent(true); core.deliver(a, "POI", states::add); core.close()
   verify(states.single() == "CANCELLED"); verify(out.stops == 1); verify(out.releases == 1); verify(out.closes == 1)
   core.consent(true); core.deliver(b, "POI", states::add); verify(states.last() == "SUPPRESSED"); verify(out.speaks == 1)
  }
  scenario { out, core, states ->
   core.consent(true); time = 2000L; core.deliver(a, "POI", states::add)
   verify(states.single() == "EXPIRED"); verify(out.focusCalls == 0)
  }
  scenario { out, core, states ->
   core.consent(true); core.deliver(a, "POI", states::add); time = 2000L; core.expire(a)
   verify(states.single() == "EXPIRED"); verify(out.stops == 1); verify(out.releases == 1)
   core.done(a); verify(states.size == 1)
  }
  scenario { out, core, states ->
   core.consent(true); core.deliver(a, "POI", states::add); time = 2000L; core.done(a)
   verify(states.single() == "EXPIRED"); verify(out.releases == 1)
  }
  scenario { out, core, states ->
   core.consent(true); out.ready = false; core.deliver(a, "POI", states::add)
   verify(states.single() == "SUPPRESSED"); verify(out.focusCalls == 0)
  }
  for (failure in 0..3) scenario { out, core, states ->
   core.consent(true)
   when (failure) { 0 -> out.speakOk = false; 1 -> out.throwFocus = true; 2 -> out.throwSpeak = true }
   core.deliver(a, "POI", states::add)
   if (failure == 3) core.error(a)
   verify(states.single() == "FAILED"); verify(out.releases == 1); verify(out.stops == 1)
   core.done(a); verify(states.size == 1)
  }
  scenario { out, core, states ->
   core.consent(true); core.deliver(a, "POI", states::add); out.stopOk = false
   verify(!core.cancel("a")); verify(states.single() == "FAILED")
   core.deliver(b, "POI", states::add); verify(states.last() == "SUPPRESSED"); verify(out.speaks == 1)
  }
  scenario { out, core, states ->
   core.consent(true); core.deliver(a, "POI", states::add); out.throwRelease = true
   core.done(a); verify(states.single() == "FAILED"); verify(out.closes == 1)
   core.deliver(b, "POI", states::add); verify(states.last() == "SUPPRESSED"); verify(out.speaks == 1)
  }
  scenario { out, core, states ->
   core.consent(true); core.deliver(a, "POI") { error("channel closed") }
   try { core.close() } catch (_: IllegalStateException) {}
   verify(out.closes == 1); verify(out.stops == 1); verify(out.releases == 1)
   core.close(); verify(out.closes == 1)
  }
  println("C2_VOICE_CONTROLLER_ASSERTIONS_PASS=$checks")
 }
}
