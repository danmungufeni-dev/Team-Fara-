import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padcare/features/dashboard/padcare_home_dashboard_screen.dart';

void main() {
  testWidgets('PadCareHomeDashboardScreen renders categories and hubs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PadCareHomeDashboardScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('PadCare'), findsWidgets);
    expect(find.text('Sanitary Pads'), findsOneWidget);
    expect(find.text('Reusable Kits'), findsOneWidget);
    expect(find.text('HerHelp Assistant'), findsWidgets);
    expect(find.text('Community Impact'), findsOneWidget);
  });
}
