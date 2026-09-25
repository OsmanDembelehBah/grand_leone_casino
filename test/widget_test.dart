import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grand_leone_casino/main.dart';

void main() {
  testWidgets('Grand Leone Casino UI load test', (WidgetTester tester) async {
    // Build the Grand Leone Casino application and trigger a frame.
    await tester.pumpWidget(const GrandLeoneApp());

    // Verify that the main title and section headers render correctly.
    expect(find.text('GRAND LEONE CASINO'), findsOneWidget);
    expect(find.text('Bartender Order Entry'), findsOneWidget);
    expect(find.text('LOG ORDER'), findsOneWidget);

    // Verify input fields and initial UI state.
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}