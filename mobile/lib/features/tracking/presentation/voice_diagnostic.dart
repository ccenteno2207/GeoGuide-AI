import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract interface class VoiceDiagnosticPort {
  Future<String> start();
  Future<void> stop();
}

class AndroidVoiceDiagnostic implements VoiceDiagnosticPort {
  const AndroidVoiceDiagnostic();
  static const _channel = MethodChannel('geoguide/voice_diagnostic');
  @override
  Future<String> start() async {
    if (!kDebugMode) return 'UNAVAILABLE';
    return await _channel.invokeMethod<String>('start') ?? 'ERROR';
  }

  @override
  Future<void> stop() async {
    if (kDebugMode) await _channel.invokeMethod<void>('stop');
  }
}

/// Only included by the normal debug UI. Native checks consent and GPS ownership again.
class VoiceDiagnosticAction extends StatelessWidget {
  const VoiceDiagnosticAction({
    super.key,
    required this.consent,
    required this.routeBusy,
    this.port = const AndroidVoiceDiagnostic(),
  });
  final bool consent;
  final bool routeBusy;
  final VoiceDiagnosticPort port;
  static bool available({required bool debug, required bool driving}) =>
      debug && !driving;
  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Probar voz CEFI (debug)',
      icon: const Icon(Icons.record_voice_over),
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => VoiceDiagnosticDialog(
          consent: consent,
          routeBusy: routeBusy,
          port: port,
        ),
      ),
    );
  }
}

class VoiceDiagnosticDialog extends StatefulWidget {
  const VoiceDiagnosticDialog({
    super.key,
    required this.consent,
    required this.routeBusy,
    required this.port,
  });
  final bool consent;
  final bool routeBusy;
  final VoiceDiagnosticPort port;
  @override
  State<VoiceDiagnosticDialog> createState() => _VoiceDiagnosticDialogState();
}

class _VoiceDiagnosticDialogState extends State<VoiceDiagnosticDialog> {
  bool _busy = false;
  int _generation = 0;
  String _status = 'Sin ejecutar';
  static const _labels = {
    'COMPLETED': 'Completado',
    'CANCELLED': 'Cancelado',
    'FOCUS_DENIED': 'Foco de audio denegado',
    'FOCUS_LOST': 'Cancelado por pérdida de foco',
    'NO_SPANISH_VOICE': 'Voz española local no disponible',
    'UNAVAILABLE': 'Prueba no disponible: revisa consentimiento y recorrido',
    'ERROR': 'Error de voz o limpieza',
  };
  Future<void> _start() async {
    if (_busy || !widget.consent || widget.routeBusy || !kDebugMode) return;
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _status = 'Inicializando / reproduciendo';
    });
    String result;
    try {
      result = await widget.port.start();
    } catch (_) {
      result = 'ERROR';
    }
    if (!mounted || generation != _generation) return;
    setState(() {
      _busy = false;
      _status = _labels[result] ?? _labels['ERROR']!;
    });
  }

  Future<void> _stop() async {
    if (!_busy) return;
    // Stay busy until the native terminal acknowledgement confirms teardown.
    try {
      await widget.port.stop();
    } catch (_) {
      if (mounted) setState(() => _status = 'No se confirmó la detención');
    }
  }

  @override
  void dispose() {
    _generation++;
    if (_busy) widget.port.stop().catchError((Object _) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Probar voz CEFI'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Diagnóstico debug sin GPS ni POIs: «CEFI: prueba de voz». Máximo 30 segundos. No valida proximidad.',
        ),
        if (!widget.consent)
          const Text('Activa previamente los avisos de voz CEFI.'),
        if (widget.routeBusy) const Text('Detén primero el recorrido GPS.'),
        Text(_status, key: const ValueKey('voice-diagnostic-status')),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cerrar'),
      ),
      if (_busy)
        TextButton(onPressed: _stop, child: const Text('Detener prueba'))
      else
        FilledButton(
          onPressed: widget.consent && !widget.routeBusy ? _start : null,
          child: const Text('Probar voz CEFI'),
        ),
    ],
  );
}
