/// WebView-specific configuration constants
class WebViewConfig {
  WebViewConfig._();

  /// Height of the dev toolbar
  static const double toolbarHeight = 56.0;

  /// Height of the URL input bar
  static const double urlInputBarHeight = 52.0;

  /// Padding for toolbar items
  static const double toolbarPadding = 8.0;

  /// Icon size for toolbar buttons
  static const double toolbarIconSize = 24.0;

  /// Border radius for input fields
  static const double inputBorderRadius = 8.0;

  /// Animation duration for toolbar show/hide
  static const Duration toolbarAnimationDuration = Duration(milliseconds: 300);

  /// Maximum retry count for failed loads
  static const int maxRetryCount = 3;

  /// Delay before auto-hiding toolbar (0 = no auto-hide)
  static const Duration toolbarAutoHideDelay = Duration.zero;
}
