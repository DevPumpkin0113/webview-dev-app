/// Represents a bookmarked URL with a custom name
class BookmarkItem {
  final String name;
  final String url;

  const BookmarkItem({
    required this.name,
    required this.url,
  });

  /// Creates a BookmarkItem from JSON
  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    return BookmarkItem(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  /// Converts this item to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookmarkItem && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}
