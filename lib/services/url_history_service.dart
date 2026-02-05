import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/url_history_item.dart';

/// Service for managing URL history persistence
class UrlHistoryService {
  UrlHistoryService._();

  static final UrlHistoryService _instance = UrlHistoryService._();
  static UrlHistoryService get instance => _instance;

  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get all URL history items
  Future<List<UrlHistoryItem>> getHistory() async {
    await _ensureInitialized();

    final List<String>? historyJson =
        _prefs!.getStringList(AppConfig.urlHistoryKey);

    if (historyJson == null || historyJson.isEmpty) {
      return [];
    }

    return historyJson
        .map((String json) =>
            UrlHistoryItem.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  /// Add a URL to history
  Future<void> addToHistory(String url) async {
    await _ensureInitialized();

    final List<UrlHistoryItem> history = await getHistory();

    // Remove if already exists
    history.removeWhere((UrlHistoryItem item) => item.url == url);

    // Add new item at the beginning
    history.insert(
      0,
      UrlHistoryItem(url: url, timestamp: DateTime.now()),
    );

    // Limit history size
    if (history.length > AppConfig.maxUrlHistoryCount) {
      history.removeRange(
          AppConfig.maxUrlHistoryCount, history.length);
    }

    // Save to preferences
    final List<String> historyJson = history
        .map((UrlHistoryItem item) => jsonEncode(item.toJson()))
        .toList();

    await _prefs!.setStringList(AppConfig.urlHistoryKey, historyJson);
  }

  /// Clear all history
  Future<void> clearHistory() async {
    await _ensureInitialized();
    await _prefs!.remove(AppConfig.urlHistoryKey);
  }

  /// Get the last loaded URL
  Future<String?> getLastLoadedUrl() async {
    await _ensureInitialized();
    return _prefs!.getString(AppConfig.lastLoadedUrlKey);
  }

  /// Save the last loaded URL
  Future<void> saveLastLoadedUrl(String url) async {
    await _ensureInitialized();
    await _prefs!.setString(AppConfig.lastLoadedUrlKey, url);
  }

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
}
