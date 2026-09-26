import 'package:flutter_test/flutter_test.dart';
import 'package:grand_leone_casino/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GrandLeoneApp());
    expect(find.byType(GrandLeoneApp), findsOneWidget);
  });
}
