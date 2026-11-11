import '../../route_planning/domain/route_point.dart';

/// A destination returned by an approved search source.
///
/// A null or invalid [verifiedPoint] may be displayed for disambiguation, but
/// must never be passed to route planning.
class DestinationSearchResult {
  const DestinationSearchResult({
    required this.id,
    required this.name,
    required this.typeLabel,
    required this.geographicContext,
    required this.provenanceLabel,
    required this.verifiedPoint,
  });

  final String id;
  final String name;
  final String typeLabel;
  final String geographicContext;
  final String provenanceLabel;
  final RoutePoint? verifiedPoint;

  bool get isRouteable =>
      id.trim().isNotEmpty &&
      name.trim().isNotEmpty &&
      verifiedPoint?.isValid == true;
}
