import 'unicode_name_data.dart';

/// NFD + removal of Unicode marks, then whitespace/case normalization.
/// Canonical combining order cannot affect the result once marks are removed.
/// Hangul decomposition is algorithmic; other decompositions are Unicode data.
String normalizePoiName(String value) {
  final output = StringBuffer();
  for (final rune in value.runes) {
    if (_isMark(rune)) continue;
    if (rune >= 0xAC00 && rune <= 0xD7A3) {
      final index = rune - 0xAC00;
      output.writeCharCode(0x1100 + index ~/ 588);
      output.writeCharCode(0x1161 + (index % 588) ~/ 28);
      if (index % 28 != 0) output.writeCharCode(0x11A7 + index % 28);
    } else {
      final decomposition = canonicalNameDecompositions[rune];
      if (decomposition == null) {
        output.writeCharCode(rune);
      } else {
        for (final part in decomposition) {
          output.writeCharCode(part);
        }
      }
    }
  }
  return output.toString().trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}

bool _isMark(int rune) {
  var low = 0, high = unicodeMarkRanges.length - 1;
  while (low <= high) {
    final mid = (low + high) ~/ 2;
    final (start, end) = unicodeMarkRanges[mid];
    if (rune < start) {
      high = mid - 1;
    } else if (rune > end) {
      low = mid + 1;
    } else {
      return true;
    }
  }
  return false;
}
