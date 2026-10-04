class BackendConfiguration {
  const BackendConfiguration(this.baseUrl);

  final Uri baseUrl;

  static BackendConfiguration? tryParse(String value) {
    final baseUrl = Uri.tryParse(value.trim());
    if (baseUrl == null ||
        !baseUrl.hasScheme ||
        !baseUrl.hasAuthority ||
        (baseUrl.scheme != 'http' && baseUrl.scheme != 'https')) {
      return null;
    }

    return BackendConfiguration(baseUrl);
  }
}
