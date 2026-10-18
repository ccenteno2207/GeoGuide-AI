import 'package:flutter/material.dart';

/// Reserved media area. No image source, asset or network request is involved.
class PoiThumbnail extends StatelessWidget {
  const PoiThumbnail({super.key, this.detail = false});
  final bool detail;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = Semantics(
      label: 'Imagen no disponible',
      image: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Center(
            child: Icon(
              Icons.landscape_outlined,
              color: colors.onSurfaceVariant,
              size: detail ? 28 : 24,
            ),
          ),
        ),
      ),
    );
    if (!detail) return SizedBox(width: 72, height: 54, child: placeholder);
    return Center(
      child: SizedBox(
        key: const ValueKey('poi-detail-thumbnail-frame'),
        width: 160,
        height: 90,
        child: placeholder,
      ),
    );
  }
}
