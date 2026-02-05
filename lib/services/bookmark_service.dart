import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/bookmark_item.dart';

/// Service for managing bookmarked URLs
class BookmarkService {
  BookmarkService._();

  static final BookmarkService _instance = BookmarkService._();
  static BookmarkService get instance => _instance;

  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get all bookmarks
  Future<List<BookmarkItem>> getBookmarks() async {
    await _ensureInitialized();

    final List<String>? bookmarksJson =
        _prefs!.getStringList(AppConfig.bookmarkedUrlsKey);

    if (bookmarksJson == null || bookmarksJson.isEmpty) {
      return [];
    }

    return bookmarksJson
        .map((String json) =>
            BookmarkItem.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  /// Add a bookmark
  Future<bool> addBookmark(BookmarkItem bookmark) async {
    await _ensureInitialized();

    final List<BookmarkItem> bookmarks = await getBookmarks();

    // Check if already bookmarked
    if (bookmarks.any((BookmarkItem item) => item.url == bookmark.url)) {
      return false;
    }

    // Check if max count reached
    if (bookmarks.length >= AppConfig.maxBookmarkCount) {
      return false;
    }

    bookmarks.add(bookmark);

    // Save to preferences
    final List<String> bookmarksJson = bookmarks
        .map((BookmarkItem item) => jsonEncode(item.toJson()))
        .toList();

    await _prefs!.setStringList(AppConfig.bookmarkedUrlsKey, bookmarksJson);
    return true;
  }

  /// Remove a bookmark by URL
  Future<void> removeBookmark(String url) async {
    await _ensureInitialized();

    final List<BookmarkItem> bookmarks = await getBookmarks();
    bookmarks.removeWhere((BookmarkItem item) => item.url == url);

    // Save to preferences
    final List<String> bookmarksJson = bookmarks
        .map((BookmarkItem item) => jsonEncode(item.toJson()))
        .toList();

    await _prefs!.setStringList(AppConfig.bookmarkedUrlsKey, bookmarksJson);
  }

  /// Check if a URL is bookmarked
  Future<bool> isBookmarked(String url) async {
    final List<BookmarkItem> bookmarks = await getBookmarks();
    return bookmarks.any((BookmarkItem item) => item.url == url);
  }

  /// Clear all bookmarks
  Future<void> clearBookmarks() async {
    await _ensureInitialized();
    await _prefs!.remove(AppConfig.bookmarkedUrlsKey);
  }

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
}
