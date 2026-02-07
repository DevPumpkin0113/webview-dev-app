import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/url_validator.dart';
import '../widgets/dev_toolbar.dart';

/// Main WebView screen
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _webViewController;

  String _currentUrl = '';
  bool _isLoading = false;
  bool _isFullscreen = false;
  bool _isToolbarVisible = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: _onPageStarted,
          onPageFinished: _onPageFinished,
          onWebResourceError: _onWebResourceError,
        ),
      )
      ..enableZoom(true)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      );
  }

  void _onPageStarted(String url) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  }

  void _onPageFinished(String url) {
    setState(() {
      _isLoading = false;
      _currentUrl = url;
    });

    // Inject JavaScript to log viewport info for debugging
    _webViewController.runJavaScript('''
      console.log('Viewport width: ' + window.innerWidth);
      console.log('Viewport height: ' + window.innerHeight);
      console.log('Device pixel ratio: ' + window.devicePixelRatio);
      console.log('Screen width: ' + screen.width);
      console.log('Screen height: ' + screen.height);
    ''');
  }

  void _onWebResourceError(WebResourceError error) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Failed to load page: ${error.description}';
    });
  }

  void _loadUrl(String url) {
    final String? validatedUrl = UrlValidator.validateAndNormalize(url);

    if (validatedUrl == null) {
      _showErrorSnackBar('Invalid URL format');
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    _webViewController.loadRequest(Uri.parse(validatedUrl));
  }

  void _reload() {
    _webViewController.reload();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleToolbar() {
    setState(() {
      _isToolbarVisible = !_isToolbarVisible;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _handleBackButton() async {
    // Show exit confirmation dialog
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Do you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      // Exit the app
      SystemNavigator.pop();
    }

    return false; // Always return false to prevent default pop behavior
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }

        final bool shouldPop = await _handleBackButton();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              if (_isToolbarVisible)
                DevToolbar(
                  currentUrl: _currentUrl,
                  isLoading: _isLoading,
                  isFullscreen: _isFullscreen,
                  onUrlSubmit: _loadUrl,
                  onReload: _reload,
                  onToggleFullscreen: _toggleFullscreen,
                  onToggleToolbar: _toggleToolbar,
                ),
              Expanded(child: _buildWebViewContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebViewContent() {
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_isLoading) _buildLoadingIndicator(),
        if (!_isToolbarVisible) _buildFloatingControls(),
      ],
    );
  }

  // Floating controls configuration constants
  static const double _floatingControlsTopPosition = 42.0;
  static const double _floatingControlsRightPosition = 16.0;
  static const double _floatingControlsHorizontalPadding = 12.0;
  static const double _floatingControlsVerticalPadding = 8.0;
  static const double _floatingControlsBackgroundAlpha = 0.5;
  static const double _floatingControlsBorderRadius = 8.0;
  static const double _floatingControlsIconSize = 18.0;
  static const double _floatingControlsButtonSize = 18.0;

  Widget _buildFloatingControls() {
    return Positioned(
      top: _floatingControlsTopPosition,
      right: _floatingControlsRightPosition,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _floatingControlsHorizontalPadding,
          vertical: _floatingControlsVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(
            alpha: _floatingControlsBackgroundAlpha,
          ),
          borderRadius: BorderRadius.circular(_floatingControlsBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: _floatingControlsButtonSize,
              height: _floatingControlsButtonSize,
              child: IconButton(
                icon: const Icon(Icons.visibility, color: Colors.white),
                iconSize: _floatingControlsIconSize,
                padding: EdgeInsets.zero,
                tooltip: 'Show Toolbar',
                onPressed: _toggleToolbar,
              ),
            ),
            const SizedBox(width: 12.0),
            SizedBox(
              width: _floatingControlsButtonSize,
              height: _floatingControlsButtonSize,
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                iconSize: _floatingControlsIconSize,
                padding: EdgeInsets.zero,
                tooltip: 'Reload',
                onPressed: _reload,
              ),
            ),
            const SizedBox(width: 12.0),
            SizedBox(
              width: _floatingControlsButtonSize,
              height: _floatingControlsButtonSize,
              child: IconButton(
                icon: Icon(
                  _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
                iconSize: _floatingControlsIconSize,
                padding: EdgeInsets.zero,
                tooltip: _isFullscreen ? 'Exit Fullscreen' : 'Fullscreen',
                onPressed: _toggleFullscreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64.0, color: Colors.red),
            const SizedBox(height: 16.0),
            Text(
              'Error Loading Page',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(onPressed: _reload, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}
