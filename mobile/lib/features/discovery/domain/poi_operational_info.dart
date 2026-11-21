class PoiOperationalInfo {
  const PoiOperationalInfo({
    required this.timeZone,
    required this.weeklyHours,
    required this.items,
  });

  final String timeZone;
  final List<DailyPoiHours> weeklyHours;
  final List<PoiOperationalItem> items;

  factory PoiOperationalInfo.fromJson(Map<String, Object?> json) {
    final hours = json['weeklyHours'];
    final items = json['items'];
    return PoiOperationalInfo(
      timeZone: json['timeZone'] is String
          ? json['timeZone']! as String
          : 'America/Lima',
      weeklyHours: hours is List
          ? hours
                .whereType<Map>()
                .map(
                  (entry) => DailyPoiHours.fromJson(
                    entry.map((key, value) => MapEntry(key.toString(), value)),
                  ),
                )
                .toList(growable: false)
          : const [],
      items: items is List
          ? items
                .whereType<Map>()
                .map(
                  (entry) => PoiOperationalItem.fromJson(
                    entry.map((key, value) => MapEntry(key.toString(), value)),
                  ),
                )
                .where((item) => item.active)
                .toList(growable: false)
          : const [],
    );
  }
}

class DailyPoiHours {
  const DailyPoiHours({required this.day, required this.periods});
  final String day;
  final List<OpeningPeriod> periods;

  factory DailyPoiHours.fromJson(Map<String, Object?> json) => DailyPoiHours(
    day: json['day'] is String ? json['day']! as String : '',
    periods: json['periods'] is List
        ? (json['periods']! as List)
              .whereType<Map>()
              .map(
                (entry) => OpeningPeriod.fromJson(
                  entry.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList(growable: false)
        : const [],
  );
}

class OpeningPeriod {
  const OpeningPeriod({required this.opensAt, required this.closesAt});
  final String opensAt;
  final String closesAt;

  factory OpeningPeriod.fromJson(Map<String, Object?> json) => OpeningPeriod(
    opensAt: json['opensAt'] is String ? json['opensAt']! as String : '',
    closesAt: json['closesAt'] is String ? json['closesAt']! as String : '',
  );
}

class PoiOperationalItem {
  const PoiOperationalItem({
    required this.type,
    required this.title,
    required this.description,
    required this.scheduleText,
    required this.validFrom,
    required this.validUntil,
    required this.terms,
    required this.active,
  });
  final String type;
  final String title;
  final String? description;
  final String? scheduleText;
  final String? validFrom;
  final String? validUntil;
  final String? terms;
  final bool active;

  factory PoiOperationalItem.fromJson(Map<String, Object?> json) =>
      PoiOperationalItem(
        type: json['type'] is String ? json['type']! as String : '',
        title: json['title'] is String ? json['title']! as String : '',
        description: json['description'] as String?,
        scheduleText: json['scheduleText'] as String?,
        validFrom: json['validFrom'] as String?,
        validUntil: json['validUntil'] as String?,
        terms: json['terms'] as String?,
        active: json['active'] == true,
      );
}
