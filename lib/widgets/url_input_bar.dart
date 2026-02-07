import 'package:flutter/material.dart';
import '../config/webview_config.dart';
import '../models/bookmark_item.dart';
import '../services/bookmark_service.dart';

/// URL input bar with bookmark management
class UrlInputBar extends StatefulWidget {
  final String currentUrl;
  final ValueChanged<String> onUrlSubmit;

  const UrlInputBar({
    super.key,
    required this.currentUrl,
    required this.onUrlSubmit,
  });

  @override
  State<UrlInputBar> createState() => _UrlInputBarState();
}

class _UrlInputBarState extends State<UrlInputBar> {
  late final TextEditingController _urlController;
  final FocusNode _focusNode = FocusNode();

  List<BookmarkItem> _bookmarks = [];
  bool _isCurrentUrlBookmarked = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.currentUrl);
    _loadBookmarks();
    _checkIfBookmarked();
  }

  @override
  void didUpdateWidget(UrlInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUrl != oldWidget.currentUrl) {
      _urlController.text = widget.currentUrl;
      _checkIfBookmarked();
    }
  }

  Future<void> _loadBookmarks() async {
    final List<BookmarkItem> bookmarks = await BookmarkService.instance
        .getBookmarks();
    setState(() {
      _bookmarks = bookmarks;
    });
  }

  Future<void> _checkIfBookmarked() async {
    if (widget.currentUrl.isEmpty) {
      setState(() {
        _isCurrentUrlBookmarked = false;
      });
      return;
    }

    final bool isBookmarked = await BookmarkService.instance.isBookmarked(
      widget.currentUrl,
    );
    setState(() {
      _isCurrentUrlBookmarked = isBookmarked;
    });
  }

  void _handleSubmit() {
    final String url = _urlController.text.trim();
    if (url.isNotEmpty) {
      widget.onUrlSubmit(url);
      _focusNode.unfocus();
    }
  }

  Future<void> _showBookmarksDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bookmarks'),
          content: SizedBox(
            width: double.maxFinite,
            child: _bookmarks.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No bookmarks yet'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _bookmarks.length,
                    itemBuilder: (BuildContext context, int index) {
                      final BookmarkItem item = _bookmarks[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.bookmark,
                          color: Colors.amber,
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          item.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await BookmarkService.instance.removeBookmark(
                              item.url,
                            );
                            await _loadBookmarks();
                            await _checkIfBookmarked();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              _showBookmarksDialog();
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          _urlController.text = item.url;
                          widget.onUrlSubmit(item.url);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleBookmark() async {
    if (widget.currentUrl.isEmpty) {
      _showSnackBar('No URL loaded');
      return;
    }

    if (_isCurrentUrlBookmarked) {
      // Remove bookmark
      await BookmarkService.instance.removeBookmark(widget.currentUrl);
      _showSnackBar('Bookmark removed');
    } else {
      // Add bookmark - show dialog to enter name
      await _showAddBookmarkDialog();
    }

    await _loadBookmarks();
    await _checkIfBookmarked();
  }

  Future<void> _showAddBookmarkDialog() async {
    final TextEditingController nameController = TextEditingController();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Bookmark'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Bookmark Name',
                  hintText: 'e.g., Local Dev Server',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 8.0),
              Text(
                widget.currentUrl,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && nameController.text.isNotEmpty) {
      final BookmarkItem bookmark = BookmarkItem(
        name: nameController.text.trim(),
        url: widget.currentUrl,
      );

      final bool success = await BookmarkService.instance.addBookmark(bookmark);

      if (success) {
        _showSnackBar('Bookmark added');
      } else {
        _showSnackBar('Failed to add bookmark');
      }
    }

    nameController.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: WebViewConfig.urlInputBarHeight,
      padding: EdgeInsets.all(WebViewConfig.toolbarPadding),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.bookmarks),
            onPressed: _showBookmarksDialog,
            tooltip: 'Bookmarks',
          ),
          Expanded(
            child: TextField(
              controller: _urlController,
              focusNode: _focusNode,
              scrollPadding: EdgeInsets.zero,
              maxLines: 1,
              expands: false,
              scrollPhysics: const ClampingScrollPhysics(),
              decoration: InputDecoration(
                hintText: 'Enter URL',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    WebViewConfig.inputBorderRadius,
                  ),
                ),
                suffixIcon: _urlController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20.0),
                        onPressed: () {
                          _urlController.clear();
                        },
                      )
                    : null,
                isDense: true,
              ),
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.url,
              onSubmitted: (_) => _handleSubmit(),
            ),
          ),
          const SizedBox(width: 4.0),
          IconButton(
            icon: Icon(
              _isCurrentUrlBookmarked ? Icons.star : Icons.star_outline,
              size: WebViewConfig.toolbarIconSize,
              color: _isCurrentUrlBookmarked ? Colors.amber : null,
            ),
            onPressed: _toggleBookmark,
            tooltip: _isCurrentUrlBookmarked
                ? 'Remove Bookmark'
                : 'Add Bookmark',
          ),
          const SizedBox(width: 4.0),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _handleSubmit,
            tooltip: 'Load',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
