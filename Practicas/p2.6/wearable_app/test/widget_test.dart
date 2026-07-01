import 'package:flutter_test/flutter_test.dart';

import 'package:wearable_app/main.dart';

void main() {
  testWidgets('Wearable app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const WearableApp());
    expect(find.text('Iniciar'), findsOneWidget);
    expect(find.text('bpm'), findsOneWidget);
  });
}
