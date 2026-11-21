import 'package:flutter/material.dart';

import '../domain/poi_operational_info.dart';

typedef PoiOperationalInfoLoader = Future<PoiOperationalInfo> Function(
  String poiId,
);

class PoiOperationalInfoSection extends StatefulWidget {
  const PoiOperationalInfoSection({
    super.key,
    required this.poiId,
    required this.load,
  });
  final String poiId;
  final PoiOperationalInfoLoader? load;

  @override
  State<PoiOperationalInfoSection> createState() =>
      _PoiOperationalInfoSectionState();
}

class _PoiOperationalInfoSectionState extends State<PoiOperationalInfoSection> {
  Future<PoiOperationalInfo>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PoiOperationalInfoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.poiId != widget.poiId || oldWidget.load != widget.load) {
      _load();
    }
  }

  void _load() {
    final loader = widget.load;
    _future = loader == null ? null : loader(widget.poiId);
  }

  void _retry() {
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    const dayNames = <String, String>{
      'MONDAY': 'Lunes',
      'TUESDAY': 'Martes',
      'WEDNESDAY': 'Miércoles',
      'THURSDAY': 'Jueves',
      'FRIDAY': 'Viernes',
      'SATURDAY': 'Sábado',
      'SUNDAY': 'Domingo',
    };
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horarios y actividades',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_future == null)
            const Text(
              'Esta información se consulta en línea y no está incluida en el modo sin conexión.',
            )
          else
            FutureBuilder<PoiOperationalInfo>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Semantics(
                    label: 'Cargando horarios y actividades',
                    child: LinearProgressIndicator(),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No se pudo consultar esta información en línea. Intenta de nuevo cuando tengas conexión.',
                      ),
                      TextButton(
                        onPressed: _retry,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  );
                }
                final info = snapshot.data!;
                final hasHours = info.weeklyHours.any(
                  (day) => day.periods.isNotEmpty,
                );
                if (!hasHours && info.items.isEmpty) {
                  return const Text(
                    'Este POI aún no tiene horarios, funciones o promociones publicados.',
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasHours) ...[
                      Text(
                        'Horario semanal · ${info.timeZone}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      for (final day in info.weeklyHours)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            '${dayNames[day.day] ?? day.day}: ${day.periods.isEmpty ? 'Cerrado' : day.periods.map((period) => '${period.opensAt.substring(0, 5)}–${period.closesAt.substring(0, 5)}').join(' · ')}',
                          ),
                        ),
                    ],
                    for (final item in info.items) ...[
                      const SizedBox(height: 10),
                      Text(
                        item.type == 'PROMOTION'
                            ? 'Promoción · ${item.title}'
                            : 'Función / actividad · ${item.title}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      if (item.description?.isNotEmpty == true)
                        Text(item.description!),
                      if (item.scheduleText?.isNotEmpty == true)
                        Text('Programación: ${item.scheduleText}'),
                      if (item.validFrom != null || item.validUntil != null)
                        Text(
                          'Vigencia: ${item.validFrom ?? 'sin inicio'} – ${item.validUntil ?? 'sin término'}',
                        ),
                      if (item.terms?.isNotEmpty == true)
                        Text('Condiciones: ${item.terms}'),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
