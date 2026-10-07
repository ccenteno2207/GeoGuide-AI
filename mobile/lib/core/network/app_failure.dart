enum AppFailureType {
  backendUnavailable,
  timeout,
  invalidResponse,
  noRouteFound,
  validation,
  server,
  security,
}

class AppFailure implements Exception {
  const AppFailure(this.type);

  final AppFailureType type;

  String get userMessage => switch (type) {
    AppFailureType.backendUnavailable => 'Servicio no disponible',
    AppFailureType.timeout => 'La solicitud tardó demasiado',
    AppFailureType.invalidResponse => 'No se pudieron usar los datos recibidos',
    AppFailureType.noRouteFound =>
      'No hay una ruta disponible para estos puntos',
    AppFailureType.validation => 'Los puntos seleccionados no son válidos',
    AppFailureType.server => 'No se pudo completar la solicitud',
    AppFailureType.security =>
      'No se pudo verificar una conexión autorizada y segura',
  };
}
