class PoiTourismContent {
  const PoiTourismContent({
    required this.summary,
    required this.description,
    required this.history,
    required this.significance,
    required this.visitorExperience,
    required this.interestingFacts,
    required this.recommendations,
    required this.practicalInfo,
    required this.officialUrl,
    required this.photos,
  });

  final String? summary;
  final String? description;
  final String? history;
  final String? significance;
  final String? visitorExperience;
  final List<String> interestingFacts;
  final List<String> recommendations;
  final String? practicalInfo;
  final String? officialUrl;
  final List<PoiTourismPhoto> photos;

  bool get hasText =>
      [
        summary,
        description,
        history,
        significance,
        visitorExperience,
        practicalInfo,
      ].any((value) => value != null && value.trim().isNotEmpty) ||
      interestingFacts.isNotEmpty ||
      recommendations.isNotEmpty ||
      officialUrl != null;

  factory PoiTourismContent.fromJson(Map<String, Object?> json) {
    final rawContent = json['content'];
    final content = rawContent is Map
        ? rawContent.map((key, value) => MapEntry(key.toString(), value))
        : <String, Object?>{};
    final rawPhotos = json['photos'];
    return PoiTourismContent(
      summary: _text(content['summary']),
      description: _text(content['description']),
      history: _text(content['history']),
      significance: _text(content['significance']),
      visitorExperience: _text(content['visitorExperience']),
      interestingFacts: _textList(content['interestingFacts']),
      recommendations: _textList(content['recommendations']),
      practicalInfo: _text(content['practicalInfo']),
      officialUrl: _text(content['officialUrl']),
      photos: rawPhotos is List
          ? rawPhotos
                .whereType<Map>()
                .map(
                  (item) => PoiTourismPhoto.fromJson(
                    item.map((key, value) => MapEntry(key.toString(), value)),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }

  static String? _text(Object? value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;

  static List<String> _textList(Object? value) => value is List
      ? value
            .whereType<String>()
            .map((text) => text.trim())
            .where((text) => text.isNotEmpty)
            .toList(growable: false)
      : const [];
}

class PoiTourismPhoto {
  const PoiTourismPhoto({
    required this.path,
    required this.altText,
    required this.author,
    required this.attribution,
    required this.license,
    required this.primary,
  });

  final String path;
  final String altText;
  final String? author;
  final String? attribution;
  final String? license;
  final bool primary;

  factory PoiTourismPhoto.fromJson(Map<String, Object?> json) =>
      PoiTourismPhoto(
        path: json['path'] is String ? json['path']! as String : '',
        altText: json['altText'] is String ? json['altText']! as String : '',
        author: json['author'] as String?,
        attribution: json['attribution'] as String?,
        license: json['license'] as String?,
        primary: json['primary'] == true,
      );
}
