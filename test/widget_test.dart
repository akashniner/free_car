import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_vehicle/main.dart';

void main() {
  testWidgets('Free Vehicle smoke test on desktop viewport', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FreeVehicleApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('FREE VEHICLE'), findsWidgets);
    expect(find.text('40 / 30 / 30 Financial Rule'), findsOneWidget);
    expect(find.text('60-Month Free Vehicle Journey'), findsOneWidget);
  });

  testWidgets('Free Vehicle smoke test on mobile viewport', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FreeVehicleApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('FREE VEHICLE'), findsWidgets);
  });
}
