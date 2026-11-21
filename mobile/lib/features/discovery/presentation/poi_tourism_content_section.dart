import 'package:flutter/material.dart';

import '../domain/poi_tourism_content.dart';
import 'poi_ui_language.dart';

typedef PoiTourismContentLoader = Future<PoiTourismContent> Function(
  String poiId,
);

class PoiTourismContentSection extends StatefulWidget {
  const PoiTourismContentSection({super.key, required this.poiId, this.load});

  final String poiId;
  final PoiTourismContentLoader? load;

  @override
  State<PoiTourismContentSection> createState() =>
      _PoiTourismContentSectionState();
}

class _PoiTourismContentSectionState extends State<PoiTourismContentSection> {
  late Future<PoiTourismContent>? _future = _start();

  Future<PoiTourismContent>? _start() => widget.load?.call(widget.poiId);

  @override
  void didUpdateWidget(covariant PoiTourismContentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.poiId != widget.poiId || oldWidget.load != widget.load) {
      _future = _start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final future = _future;
    if (future == null) return const SizedBox.shrink();
    return FutureBuilder<PoiTourismContent>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('No se pudo cargar el contenido turístico.'),
              TextButton(
                onPressed: () => setState(() => _future = _start()),
                child: const Text('Reintentar'),
              ),
            ],
          );
        }
        final content = snapshot.data;
        if (content == null) return const SizedBox.shrink();
        final hasContent = content.hasText || content.photos.isNotEmpty;
        if (!hasContent) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final photo in content.photos)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Semantics(
                    image: true,
                    label: photo.altText.isEmpty
                        ? 'Fotografía del lugar'
                        : photo.altText,
                    child: Image.network(
                      photo.path,
                      width: double.infinity,
                      height: 190,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            if (content.summary case final text? when text.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(text, style: Theme.of(context).textTheme.titleMedium),
            ],
            for (final section in <(String, String?)>[
              if (content.contentSource != 'CURATED')
                ('Descripción turística', content.description),
              ('Historia', content.history),
              ('Importancia', content.significance),
              ('Qué puedes conocer', content.visitorExperience),
              ('Información práctica', content.practicalInfo),
            ])
              if (section.$2 case final text? when text.isNotEmpty)
                _textSection(context, section.$1, text),
            for (final pair in <(String, List<String>)>[
              ('Datos interesantes', content.interestingFacts),
              ('Recomendaciones', content.recommendations),
            ])
              if (pair.$2.isNotEmpty) _listSection(context, pair.$1, pair.$2),
            if (content.officialUrl case final url? when url.isNotEmpty)
              SelectableText('Enlace oficial: $url'),
            for (final photo in content.photos)
              if (photo.attribution case final attribution?
                  when attribution.isNotEmpty)
                Text(
                  'Fotografía: $attribution',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
          ],
        );
      },
    );
  }

  Widget _textSection(BuildContext context, String title, String text) =>
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              locale: spanishPoiUiLocale,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(text),
          ],
        ),
      );

  Widget _listSection(
    BuildContext context,
    String title,
    List<String> values,
  ) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          locale: spanishPoiUiLocale,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        for (final value in values)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('• $value'),
          ),
      ],
    ),
  );
}
