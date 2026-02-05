/// Application-wide configuration constants
class AppConfig {
  AppConfig._();

  /// Maximum number of URLs to store in history
  static const int maxUrlHistoryCount = 10;

  /// Default timeout for page load
  static const Duration pageLoadTimeout = Duration(seconds: 30);

  /// App name
  static const String appName = 'Phaser Local Viewer';

  /// Default URL for initial load (empty for no default)
  static const String defaultUrl = '';

  /// SharedPreferences key for URL history
  static const String urlHistoryKey = 'url_history';

  /// SharedPreferences key for last loaded URL
  static const String lastLoadedUrlKey = 'last_loaded_url';

  /// SharedPreferences key for fullscreen mode preference
  static const String isFullscreenKey = 'is_fullscreen';

  /// SharedPreferences key for toolbar visibility
  static const String isToolbarVisibleKey = 'is_toolbar_visible';

  /// SharedPreferences key for bookmarked URLs
  static const String bookmarkedUrlsKey = 'bookmarked_urls';

  /// Maximum number of bookmarks
  static const int maxBookmarkCount = 20;
}
