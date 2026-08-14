import 'package:flutter_test/flutter_test.dart';

import 'package:wearable_app/main.dart';

void main() {
  testWidgets('Wearable app loads and shows the single Conectar button', (WidgetTester tester) async {
    await tester.pumpWidget(const WearableApp());
    expect(find.byTooltip('Conectar'), findsOneWidget);
    expect(find.textContaining('Toca Conectar'), findsOneWidget);
  });
}
