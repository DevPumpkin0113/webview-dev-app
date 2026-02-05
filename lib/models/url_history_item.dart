/// Represents a single URL history item
class UrlHistoryItem {
  final String url;
  final DateTime timestamp;

  const UrlHistoryItem({
    required this.url,
    required this.timestamp,
  });

  /// Creates a UrlHistoryItem from JSON
  factory UrlHistoryItem.fromJson(Map<String, dynamic> json) {
    return UrlHistoryItem(
      url: json['url'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Converts this item to JSON
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UrlHistoryItem && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}
