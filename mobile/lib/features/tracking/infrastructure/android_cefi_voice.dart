import 'package:flutter/services.dart';

import '../application/cefi_alert_delivery_coordinator.dart';

/// Native completion is correlated; no provider queue, retry or proximity rules.
class AndroidCEFIAlertDelivery implements CEFIAlertDeliveryPort {
  AndroidCEFIAlertDelivery(this.channel);
  final MethodChannel channel;
  @override
  Future<CEFIAlertAck> deliver(CEFIAlertEvent event) async {
    final response = await channel.invokeMapMethod<String, dynamic>(
      'voiceDeliver',
      {
        'eventId': event.eventId,
        'generation': event.generation,
        'snapshotRevision': event.snapshotRevision,
        'expiresAt': event.expiresAt.millisecondsSinceEpoch,
        'name': event.candidate.name,
      },
    );
    if (response == null) throw StateError('Voice completion unavailable');
    final state = AlertDeliveryState.values.firstWhere(
      (s) => s.name.toUpperCase() == response['state'],
      orElse: () => AlertDeliveryState.failed,
    );
    return CEFIAlertAck(
      response['eventId'] as String,
      response['generation'] as int,
      response['snapshotRevision'] as String,
      state,
    );
  }

  @override
  Future<void> cancel(String eventId) =>
      channel.invokeMethod<void>('voiceCancel', eventId);
}
