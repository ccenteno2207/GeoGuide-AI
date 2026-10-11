package com.geoguideai.geoguide_ai

internal object B1Policy {
 fun producerPermissionValid(preciseProducer: Boolean, fineGranted: Boolean): Boolean = !preciseProducer || fineGranted
 fun canStart(visible: Boolean, busy: Boolean, payloadBytes: Int): Boolean = visible && !busy && payloadBytes in 1..5242880
 fun canContinue(sdk: Int, coarse: Boolean, fine: Boolean, locationEnabled: Boolean, notificationsEnabled: Boolean, notificationGranted: Boolean): Boolean =
  (coarse || fine) && locationEnabled && notificationsEnabled && (sdk < 33 || notificationGranted)
}
