/// Service for validating URLs
class UrlValidator {
  UrlValidator._();

  /// Validates if a string is a valid URL
  static bool isValidUrl(String input) {
    if (input.isEmpty) {
      return false;
    }

    final Uri? uri = Uri.tryParse(input);
    if (uri == null) {
      return false;
    }

    // Must have a scheme (http or https)
    if (!uri.hasScheme) {
      return false;
    }

    // Must be http or https
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return false;
    }

    // Must have a host
    if (!uri.hasAuthority) {
      return false;
    }

    return true;
  }

  /// Attempts to fix common URL issues
  static String normalizeUrl(String input) {
    String normalized = input.trim();

    // Add http:// if no scheme is present
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'http://$normalized';
    }

    return normalized;
  }

  /// Validates and normalizes a URL
  static String? validateAndNormalize(String input) {
    if (input.isEmpty) {
      return null;
    }

    final String normalized = normalizeUrl(input);

    if (!isValidUrl(normalized)) {
      return null;
    }

    return normalized;
  }
}
