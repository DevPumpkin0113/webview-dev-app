import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_dev_app/main.dart';

void main() {
  testWidgets('WebViewDevApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const WebViewDevApp());

    // Verify that the URL input field exists
    expect(find.byType(TextField), findsOneWidget);

    // Verify that Load button exists
    expect(find.text('Load'), findsOneWidget);

    // Verify that Reload button exists
    expect(find.text('Reload'), findsOneWidget);
  });
}
