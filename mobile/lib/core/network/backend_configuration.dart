class BackendConfiguration {
  const BackendConfiguration(this.baseUrl);

  final Uri baseUrl;

  static BackendConfiguration? fromEnvironment() {
    const rawUrl = String.fromEnvironment('BACKEND_BASE_URL');
    if (rawUrl.isEmpty) return null;

    final baseUrl = Uri.tryParse(rawUrl);
    if (baseUrl == null || baseUrl.scheme != 'https' || baseUrl.host.isEmpty) {
      return null;
    }
    return BackendConfiguration(baseUrl);
  }
}
