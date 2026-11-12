import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/app_failure.dart';

import '../../route_planning/domain/route_point.dart';
import '../application/search_destinations.dart';
import '../domain/destination_search_result.dart';

enum _SearchState { idle, loading, results, empty, error, offline }

/// Search surface backed by the configured first-party destination catalog.
class DestinationSearchSheet extends StatefulWidget {
  const DestinationSearchSheet({
    super.key,
    required this.searchDestinations,
    required this.onDestinationSelected,
  });

  final SearchDestinations searchDestinations;
  final ValueChanged<RoutePoint> onDestinationSelected;

  @override
  State<DestinationSearchSheet> createState() => _DestinationSearchSheetState();
}

class _DestinationSearchSheetState extends State<DestinationSearchSheet> {
  static const _debounceDuration = Duration(milliseconds: 300);
  final _controller = TextEditingController();
  _SearchState _state = _SearchState.idle;
  List<DestinationSearchResult> _results = const [];
  String? _message;
  int _requestId = 0;
  Timer? _debounceTimer;
  String? _inFlightQuery;
  String? _completedQuery;
  String? _scheduledQuery;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _requestId++;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit({bool force = false}) async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _scheduledQuery = null;
    final query = _normalizeQuery(_controller.text);
    if (query.isEmpty) {
      _requestId++;
      _inFlightQuery = null;
      _completedQuery = null;
      setState(() {
        _state = _SearchState.idle;
        _results = const [];
        _message = null;
      });
      return;
    }

    if (_state == _SearchState.loading && _inFlightQuery == query) return;
    if (!force && _completedQuery == query) return;

    final requestId = ++_requestId;
    _inFlightQuery = query;
    setState(() {
      _state = _SearchState.loading;
      _results = const [];
      _message = null;
    });

    try {
      final results = await widget.searchDestinations(query);
      if (!mounted || requestId != _requestId) return;
      _inFlightQuery = null;
      _completedQuery = query;
      setState(() {
        _results = results;
        _state = results.isEmpty ? _SearchState.empty : _SearchState.results;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      _inFlightQuery = null;
      _completedQuery = query;
      setState(() {
        if (error is AppFailure &&
            error.type == AppFailureType.backendUnavailable) {
          _state = _SearchState.offline;
          _message = 'Sin conexión o servicio no disponible. Comprueba la conexión e inténtalo de nuevo.';
        } else {
          _state = _SearchState.error;
          _message = 'No se pudo buscar destinos. Inténtalo de nuevo.';
        }
      });
    }
  }

  void _queryChanged(String value) {
    final query = _normalizeQuery(value);
    if (query == _inFlightQuery ||
        query == _completedQuery ||
        query == _scheduledQuery) {
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _scheduledQuery = null;
    _requestId++;
    _inFlightQuery = null;
    _completedQuery = null;
    setState(() {
      _state = _SearchState.idle;
      _results = const [];
      _message = null;
    });
    if (query.isEmpty) return;
    _scheduledQuery = query;
    _debounceTimer = Timer(_debounceDuration, () {
      _debounceTimer = null;
      _scheduledQuery = null;
      if (mounted && _normalizeQuery(_controller.text) == query) _submit();
    });
  }

  String _normalizeQuery(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  Widget _status(String message, {Widget? child}) => Semantics(
    liveRegion: true,
    label: message,
    child: child ?? Text(message),
  );

  Widget _retryState(String message) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _status(message),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => _submit(force: true),
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¿Qué conoceremos hoy?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey('destination-search-query'),
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onChanged: _queryChanged,
                    onSubmitted: (_) => _submit(force: true),
                    decoration: const InputDecoration(
                      hintText: '¿Qué conoceremos hoy?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  key: const ValueKey('destination-search-submit'),
                  tooltip: 'Buscar destinos',
                  onPressed: () => _submit(force: true),
                  icon: const Icon(Icons.search),
                  constraints: const BoxConstraints.tightFor(
                    width: 48,
                    height: 48,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_state == _SearchState.loading)
              _status(
                'Buscando destinos',
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (_state == _SearchState.empty)
              _status('No encontramos destinos con ese nombre.')
            else if (_state == _SearchState.error)
              _retryState(_message ?? 'No se pudo buscar destinos.')
            else if (_state == _SearchState.offline)
              _retryState(_message ?? 'Sin conexión o servicio no disponible.')
            else if (_state == _SearchState.results)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => _DestinationResultTile(
                    result: _results[index],
                    onSelected: widget.onDestinationSelected,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DestinationResultTile extends StatelessWidget {
  const _DestinationResultTile({
    required this.result,
    required this.onSelected,
  });

  final DestinationSearchResult result;
  final ValueChanged<RoutePoint> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectable = result.isRouteable;
    final subtitle = [
      result.typeLabel,
      result.geographicContext,
      if (result.provenanceLabel.trim().isNotEmpty)
        'Fuente: ${result.provenanceLabel}',
      if (result.attribution.trim().isNotEmpty)
        'Atribución: ${result.attribution}',
      if (result.license.trim().isNotEmpty) 'Licencia: ${result.license}',
    ].where((part) => part.trim().isNotEmpty).join(' · ');

    return ListTile(
      key: ValueKey('destination-result-${result.id}'),
      title: Text(result.name),
      subtitle: Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis),
      isThreeLine: subtitle.contains(' · '),
      trailing: FilledButton.tonal(
        onPressed: selectable ? () => onSelected(result.verifiedPoint!) : null,
        child: const Text('Seleccionar'),
      ),
      enabled: selectable,
    );
  }
}
