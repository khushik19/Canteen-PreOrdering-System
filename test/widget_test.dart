import 'package:flutter_test/flutter_test.dart';
import 'package:canteen_crave/src/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CanteenCraveApp());
    expect(find.byType(CanteenCraveApp), findsOneWidget);
  });
}
