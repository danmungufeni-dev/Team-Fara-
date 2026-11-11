import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padcare/app/app.dart';
import 'package:padcare/core/storage/local_storage.dart';

void main() {
  setUp(() async {
    await LocalStorage.init();
  });

  testWidgets('PadCareApp loads and renders dashboard', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: PadCareApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify app brand presence
    expect(find.text('PadCare Uganda'), findsOneWidget);
    expect(find.text('Discreet Pickup Guaranteed'), findsOneWidget);
  });
}
