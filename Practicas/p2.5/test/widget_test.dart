import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:wear_ble_test/main.dart';
import 'package:wear_ble_test/providers/weather_provider.dart';

void main() {
  testWidgets('App renders home screen with title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Climate App'), findsOneWidget);
  });

  testWidgets('WeatherProvider initial state is correct',
      (WidgetTester tester) async {
    final provider = WeatherProvider();
    expect(provider.weather, isNull);
    expect(provider.isLoading, false);
    expect(provider.error, isNull);
    expect(provider.isConnected, false);
    expect(provider.isScanning, false);
  });
}
