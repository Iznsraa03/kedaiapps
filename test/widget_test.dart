import 'package:flutter_test/flutter_test.dart';
import 'package:kedaiapp/main.dart';

void main() {
  testWidgets('KedaiApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KedaiApp());
    expect(find.byType(KedaiApp), findsOneWidget);
  });
}
