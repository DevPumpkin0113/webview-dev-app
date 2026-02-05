import 'package:flutter/material.dart';
import '../config/webview_config.dart';
import 'url_input_bar.dart';

/// Developer toolbar for WebView control
class DevToolbar extends StatelessWidget {
  final String currentUrl;
  final bool isLoading;
  final bool isFullscreen;
  final ValueChanged<String> onUrlSubmit;
  final VoidCallback onReload;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onToggleToolbar;

  const DevToolbar({
    super.key,
    required this.currentUrl,
    required this.isLoading,
    required this.isFullscreen,
    required this.onUrlSubmit,
    required this.onReload,
    required this.onToggleFullscreen,
    required this.onToggleToolbar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UrlInputBar(
            currentUrl: currentUrl,
            onUrlSubmit: onUrlSubmit,
          ),
          _buildActionBar(context),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      height: WebViewConfig.toolbarHeight,
      padding: EdgeInsets.symmetric(
        horizontal: WebViewConfig.toolbarPadding,
        vertical: WebViewConfig.toolbarPadding / 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Hide button
          IconButton(
            icon: const Icon(Icons.visibility_off),
            iconSize: WebViewConfig.toolbarIconSize,
            onPressed: onToggleToolbar,
            tooltip: 'Hide Toolbar',
          ),

          // Center: Reload button
          IconButton(
            icon: isLoading
                ? SizedBox(
                    width: WebViewConfig.toolbarIconSize,
                    height: WebViewConfig.toolbarIconSize,
                    child: const CircularProgressIndicator(strokeWidth: 2.0),
                  )
                : const Icon(Icons.refresh),
            iconSize: WebViewConfig.toolbarIconSize,
            onPressed: isLoading ? null : onReload,
            tooltip: 'Reload',
          ),

          // Right: Fullscreen button
          IconButton(
            icon: Icon(
              isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            ),
            iconSize: WebViewConfig.toolbarIconSize,
            onPressed: onToggleFullscreen,
            tooltip: isFullscreen ? 'Exit Fullscreen' : 'Fullscreen',
          ),
        ],
      ),
    );
  }
}
