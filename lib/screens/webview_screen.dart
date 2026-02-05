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

  // Multi-finger long press detection
  int _activePointerCount = 0;
  Timer? _multiFingerLongPressTimer;

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

    // Show hint when hiding toolbar
    if (!_isToolbarVisible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Touch with 3 fingers for 1 second to show toolbar'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

  void _startMultiFingerLongPressTimer() {
    _cancelMultiFingerLongPressTimer();

    _multiFingerLongPressTimer = Timer(const Duration(seconds: 1), () {
      if (_activePointerCount >= 3) {
        _toggleToolbar();
      }
    });
  }

  void _cancelMultiFingerLongPressTimer() {
    _multiFingerLongPressTimer?.cancel();
    _multiFingerLongPressTimer = null;
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
        body: Column(
          children: [
            if (_isToolbarVisible)
              SafeArea(
                bottom: false,
                child: DevToolbar(
                  currentUrl: _currentUrl,
                  isLoading: _isLoading,
                  isFullscreen: _isFullscreen,
                  onUrlSubmit: _loadUrl,
                  onReload: _reload,
                  onToggleFullscreen: _toggleFullscreen,
                  onToggleToolbar: _toggleToolbar,
                ),
              ),
            Expanded(
              child: _buildWebViewContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebViewContent() {
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    return Listener(
      onPointerDown: (PointerDownEvent event) {
        // Track pointer count for multi-finger detection
        setState(() {
          _activePointerCount++;
        });

        // If 3 fingers detected, start timer for long press
        if (_activePointerCount == 3) {
          _startMultiFingerLongPressTimer();
        }
      },
      onPointerUp: (PointerUpEvent event) {
        setState(() {
          _activePointerCount--;
        });
        _cancelMultiFingerLongPressTimer();
      },
      onPointerCancel: (PointerCancelEvent event) {
        setState(() {
          _activePointerCount--;
        });
        _cancelMultiFingerLongPressTimer();
      },
      child: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64.0,
              color: Colors.red,
            ),
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
            ElevatedButton(
              onPressed: _reload,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cancelMultiFingerLongPressTimer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}
