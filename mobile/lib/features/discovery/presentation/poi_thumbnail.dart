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
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              Icons.landscape_outlined,
              color: colors.onSurfaceVariant,
              size: 32,
            ),
          ),
        ),
      ),
    );
    if (!detail) return SizedBox(width: 96, height: 72, child: placeholder);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: AspectRatio(aspectRatio: 16 / 9, child: placeholder),
      ),
    );
  }
}
