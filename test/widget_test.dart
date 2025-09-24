import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadowing_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ProviderScope(child: ShadowingApp()));

    // Verify that the app title is present.
    expect(find.text('シャドーイング学習'), findsOneWidget);
    
    // Verify that the bottom navigation is present.
    expect(find.text('ホーム'), findsOneWidget);
    expect(find.text('コンテンツ'), findsOneWidget);
    expect(find.text('進捗'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });
}