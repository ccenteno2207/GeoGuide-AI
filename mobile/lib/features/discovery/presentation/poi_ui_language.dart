import 'dart:ui' show Locale, LocaleStringAttribute, TextRange;

import 'package:flutter/semantics.dart' show AttributedString;

const spanishPoiUiLocale = Locale('es', 'PE');

// Only the caller-owned UI prefix is tagged. The factual suffix is not assigned
// a language, even when both contribute to a single accessible label.
AttributedString spanishPoiUiPrefix(String prefix, String factualSuffix) =>
    AttributedString(
      '$prefix$factualSuffix',
      attributes: [
        LocaleStringAttribute(
          range: TextRange(start: 0, end: prefix.length),
          locale: spanishPoiUiLocale,
        ),
      ],
    );
