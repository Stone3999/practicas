// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:telefono_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://10.13.37.184:3000\nDEFAULT_RACK_ID=DC-A-RACK-01');

    // Build our app and trigger a frame.
    await tester.pumpWidget(const OmnirackApp());

    // Verify that it builds and shows the dashboard with a single Conectar button.
    expect(find.textContaining('OMNIRACK'), findsWidgets);
    expect(find.text('Conectar'), findsOneWidget);
  });
}
